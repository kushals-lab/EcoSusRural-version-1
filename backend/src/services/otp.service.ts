import { SendOtpResult, VerifyOtpResult } from '../types/auth.types';

// Works from both src/ and compiled dist/. MongoDB stores challenges;
// email verification does not depend on Redis being available.
const emailOtp = require('../../src/services/emailOtp');

export class OtpService {
  public static generateSecureOtp(): string {
    return emailOtp.generateSecureOtp();
  }

  public static generateAndSendOtp(email: string): Promise<SendOtpResult> {
    return emailOtp.generateAndSendOtp(email);
  }

  public static verifyOtp(email: string, otp: string): Promise<VerifyOtpResult> {
    return emailOtp.verifyOtp(email, otp);
  }
}
