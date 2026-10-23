import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { redis } from '../config/redis';
import { mailerTransporter } from '../config/mailer';
import { SendOtpResult, StoredOtpRecord, VerifyOtpResult } from '../types/auth.types';

export class OtpService {
  private static readonly OTP_TTL_SECONDS = 300; // 5 minutes
  private static readonly COOLDOWN_SECONDS = 60; // 1 minute dispatch throttle
  private static readonly MAX_VERIFICATION_ATTEMPTS = 3;
  private static readonly REDIS_PREFIX = 'otp:record:';
  private static readonly COOLDOWN_PREFIX = 'otp:cooldown:';

  /// Resolves a secret from the environment with fail-closed behaviour:
  /// production ABORTS on a missing/short secret (a public fallback would
  /// make OTP hashes and JWTs forgeable); development falls back to a
  /// random per-process value so tokens are never derived from a constant
  /// committed to the repository.
  private static resolveSecret(name: string): string {
    const value = (process.env[name] || '').trim();
    const isProd =
      process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'prod';
    if (isProd) {
      if (value.length < 32) {
        throw new Error(
          `[OtpService] ${name} must be set to at least 32 characters in production. ` +
            `Generate one with: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`
        );
      }
      return value;
    }
    if (value.length >= 16) return value;
    return crypto.randomBytes(32).toString('hex');
  }

  private static _hmacSecret?: string;
  private static _jwtSecret?: string;

  private static get HMAC_SECRET(): string {
    if (!this._hmacSecret) this._hmacSecret = this.resolveSecret('OTP_HMAC_SECRET');
    return this._hmacSecret;
  }

  private static get JWT_SECRET(): string {
    if (!this._jwtSecret) this._jwtSecret = this.resolveSecret('JWT_SECRET');
    return this._jwtSecret;
  }

  /**
   * Generates a cryptographically secure 6-digit numeric OTP.
   * crypto.randomInt uniformly samples [100000, 1000000), avoiding modulo bias.
   */
  public static generateSecureOtp(): string {
    return crypto.randomInt(100000, 1000000).toString();
  }

  /**
   * Creates an HMAC-SHA256 hash using a per-record salt to protect stored OTPs at rest.
   */
  private static hashOtp(otp: string, salt: string): string {
    return crypto
      .createHmac('sha256', this.HMAC_SECRET)
      .update(`${otp}:${salt}`)
      .digest('hex');
  }

  /**
   * Constant-time comparison between stored and candidate hashes.
   */
  private static isConstantTimeMatch(candidateHash: string, storedHash: string): boolean {
    const candidateBuffer = Buffer.from(candidateHash, 'hex');
    const storedBuffer = Buffer.from(storedHash, 'hex');

    if (candidateBuffer.length !== storedBuffer.length) {
      return false;
    }

    return crypto.timingSafeEqual(candidateBuffer, storedBuffer);
  }

  /**
   * Generates OTP, stores hashed record in Redis with 5-min TTL, and sends email.
   */
  public static async generateAndSendOtp(email: string): Promise<SendOtpResult> {
    const cooldownKey = `${this.COOLDOWN_PREFIX}${email}`;
    const otpKey = `${this.REDIS_PREFIX}${email}`;

    // 1. Check dispatch cooldown (anti-spam / anti-drain)
    const activeCooldown = await redis.ttl(cooldownKey);
    if (activeCooldown > 0) {
      return {
        success: false,
        message: `Please wait ${activeCooldown} seconds before requesting a new OTP.`,
        cooldownSeconds: activeCooldown,
      };
    }

    // 2. Generate secure code and salt
    const plainOtp = this.generateSecureOtp();
    const salt = crypto.randomBytes(16).toString('hex');
    const hashedOtp = this.hashOtp(plainOtp, salt);

    const record: StoredOtpRecord = {
      hash: hashedOtp,
      salt,
      attempts: 0,
      createdAt: Date.now(),
    };

    // 3. Atomically persist OTP with 5-minute TTL and set 60-second cooldown
    const pipeline = redis.pipeline();
    pipeline.set(otpKey, JSON.stringify(record), 'EX', this.OTP_TTL_SECONDS);
    pipeline.set(cooldownKey, 'active', 'EX', this.COOLDOWN_SECONDS);
    await pipeline.exec();

    // 4. Dispatch Email
    await this.dispatchEmail(email, plainOtp);

    return {
      success: true,
      message: 'A 6-digit verification code has been dispatched to your email.',
      cooldownSeconds: this.COOLDOWN_SECONDS,
    };
  }

  /**
   * Verifies user-submitted OTP with timing-safe checks and brute-force protection.
   */
  public static async verifyOtp(email: string, candidateOtp: string): Promise<VerifyOtpResult> {
    const otpKey = `${this.REDIS_PREFIX}${email}`;
    const rawRecord = await redis.get(otpKey);

    if (!rawRecord) {
      return {
        success: false,
        reason: 'NOT_FOUND_OR_EXPIRED',
        message: 'The OTP has expired or does not exist. Please request a new code.',
      };
    }

    let record: StoredOtpRecord;
    try {
      record = JSON.parse(rawRecord) as StoredOtpRecord;
    } catch {
      await redis.del(otpKey);
      return {
        success: false,
        reason: 'INTERNAL_ERROR',
        message: 'Stored OTP record was corrupted. Please request a new code.',
      };
    }

    // Check if max attempts already exceeded
    if (record.attempts >= this.MAX_VERIFICATION_ATTEMPTS) {
      await redis.del(otpKey);
      return {
        success: false,
        reason: 'MAX_ATTEMPTS_EXCEEDED',
        message: 'Maximum verification attempts exceeded. Code has been revoked. Request a new OTP.',
        remainingAttempts: 0,
      };
    }

    const candidateHash = this.hashOtp(candidateOtp, record.salt);
    const isValid = this.isConstantTimeMatch(candidateHash, record.hash);

    if (!isValid) {
      record.attempts += 1;
      const remainingAttempts = Math.max(0, this.MAX_VERIFICATION_ATTEMPTS - record.attempts);

      if (remainingAttempts === 0) {
        // Invalidate record immediately upon reaching 3 failed attempts
        await redis.del(otpKey);
        return {
          success: false,
          reason: 'MAX_ATTEMPTS_EXCEEDED',
          message: 'Incorrect OTP. You have exhausted all attempts. Code has been revoked.',
          remainingAttempts: 0,
        };
      }

      // Update attempt count while preserving the remaining Redis TTL
      const remainingTtl = await redis.ttl(otpKey);
      if (remainingTtl > 0) {
        await redis.set(otpKey, JSON.stringify(record), 'EX', remainingTtl);
      }

      return {
        success: false,
        reason: 'INVALID_OTP',
        message: `Incorrect OTP. You have ${remainingAttempts} attempt(s) remaining.`,
        remainingAttempts,
      };
    }

    // OTP is valid: Delete key immediately to prevent replay attacks
    const cooldownKey = `${this.COOLDOWN_PREFIX}${email}`;
    await redis.del(otpKey, cooldownKey);

    // Issue an authorization token proving email possession (valid for 15 minutes)
    const verificationToken = jwt.sign(
      {
        email,
        purpose: 'email_verification',
        verifiedAt: Date.now(),
      },
      this.JWT_SECRET,
      { expiresIn: '15m' }
    );

    return {
      success: true,
      message: 'Email address successfully verified.',
      verificationToken,
    };
  }

  /**
   * Internal Nodemailer email dispatcher with security headers & responsive HTML.
   */
  private static async dispatchEmail(to: string, otp: string): Promise<void> {
    const sender = process.env.SMTP_FROM || '"Security Team" <no-reply@yourdomain.com>';

    const htmlContent = `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 540px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 8px;">
        <h2 style="color: #0f172a; margin-top: 0;">Verification Code</h2>
        <p style="color: #475569; font-size: 15px; line-height: 1.5;">Please use the following single-use verification code to complete your request:</p>
        <div style="background-color: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 6px; padding: 18px; text-align: center; margin: 24px 0;">
          <span style="font-size: 32px; font-weight: 700; letter-spacing: 6px; color: #1e293b; font-family: monospace;">${otp}</span>
        </div>
        <p style="color: #64748b; font-size: 13px; line-height: 1.5;">This code will expire in <strong>5 minutes</strong>. If you did not initiate this request, you can safely ignore this email.</p>
        <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 24px 0;" />
        <p style="color: #94a3b8; font-size: 12px; margin-bottom: 0;">Automated message. Please do not reply directly to this email.</p>
      </div>
    `;

    const textContent = `Your verification code is: ${otp}\n\nThis code will expire in 5 minutes. If you did not request this, please ignore this email.`;

    await mailerTransporter.sendMail({
      from: sender,
      to,
      subject: `Your Verification Code: ${otp}`,
      text: textContent,
      html: htmlContent,
      headers: {
        'X-Priority': '1',
        'X-Auto-Response-Suppress': 'OOF, AutoReply',
      },
    });
  }
}
