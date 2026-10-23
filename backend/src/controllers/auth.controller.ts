import { Request, Response } from 'express';
import { EmailValidationService } from '../services/emailValidation.service';
import { OtpService } from '../services/otp.service';
import { SendOtpRequestBody, VerifyOtpRequestBody } from '../types/auth.types';

export class AuthController {
  /**
   * POST /api/v1/auth/send-otp
   * Validates syntax, blocks disposable emails, performs DNS MX lookup, and dispatches OTP.
   */
  public static async sendOtp(req: Request<{}, {}, SendOtpRequestBody>, res: Response): Promise<void> {
    try {
      const { email } = req.body;

      if (!email) {
        res.status(400).json({
          success: false,
          message: 'The "email" field is required in the request body.',
        });
        return;
      }

      // Step 1: Strict Email Validation & MX Verification
      const validationResult = await EmailValidationService.validateEmail(email);

      if (!validationResult.isValid || !validationResult.normalizedEmail) {
        const statusCode = validationResult.code === 'INVALID_SYNTAX' ? 400 : 422;
        res.status(statusCode).json({
          success: false,
          error: validationResult.error,
          code: validationResult.code,
        });
        return;
      }

      // Step 2: Generate & Dispatch OTP
      const dispatchResult = await OtpService.generateAndSendOtp(validationResult.normalizedEmail);

      if (!dispatchResult.success) {
        res.status(429).json({
          success: false,
          message: dispatchResult.message,
          cooldownSeconds: dispatchResult.cooldownSeconds,
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: dispatchResult.message,
        email: validationResult.normalizedEmail,
        cooldownSeconds: dispatchResult.cooldownSeconds,
      });
    } catch (error: any) {
      console.error('[AuthController.sendOtp] Internal error:', error);
      res.status(500).json({
        success: false,
        message: 'An internal server error occurred while processing your request.',
      });
    }
  }

  /**
   * POST /api/v1/auth/verify-otp
   * Verifies 6-digit numeric OTP with brute-force lockout and returns a JWT verification token.
   */
  public static async verifyOtp(req: Request<{}, {}, VerifyOtpRequestBody>, res: Response): Promise<void> {
    try {
      const { email, otp } = req.body;

      if (!email || typeof email !== 'string') {
        res.status(400).json({
          success: false,
          message: 'The "email" field is required and must be a string.',
        });
        return;
      }

      if (!otp || typeof otp !== 'string' || !/^\d{6}$/.test(otp.trim())) {
        res.status(400).json({
          success: false,
          message: 'The "otp" field must be a 6-digit numeric string.',
        });
        return;
      }

      const normalizedEmail = email.trim().toLowerCase();
      const trimmedOtp = otp.trim();

      const verificationResult = await OtpService.verifyOtp(normalizedEmail, trimmedOtp);

      if (!verificationResult.success) {
        let statusCode = 400;

        switch (verificationResult.reason) {
          case 'NOT_FOUND_OR_EXPIRED':
            statusCode = 404;
            break;
          case 'MAX_ATTEMPTS_EXCEEDED':
            statusCode = 423; // Locked
            break;
          case 'INVALID_OTP':
            statusCode = 401; // Unauthorized
            break;
          case 'INTERNAL_ERROR':
            statusCode = 500;
            break;
        }

        res.status(statusCode).json({
          success: false,
          message: verificationResult.message,
          reason: verificationResult.reason,
          remainingAttempts: verificationResult.remainingAttempts,
        });
        return;
      }

      res.status(200).json({
        success: true,
        message: verificationResult.message,
        verificationToken: verificationResult.verificationToken,
      });
    } catch (error: any) {
      console.error('[AuthController.verifyOtp] Internal error:', error);
      res.status(500).json({
        success: false,
        message: 'An internal server error occurred during OTP verification.',
      });
    }
  }
}
