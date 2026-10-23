export interface EmailValidationResult {
  isValid: boolean;
  normalizedEmail?: string;
  error?: string;
  code?: 'INVALID_SYNTAX' | 'DISPOSABLE_DOMAIN' | 'NO_MX_RECORDS' | 'DNS_LOOKUP_TIMEOUT' | 'INTERNAL_ERROR';
}

export interface StoredOtpRecord {
  hash: string;
  salt: string;
  attempts: number;
  createdAt: number;
}

export interface SendOtpResult {
  success: boolean;
  message: string;
  cooldownSeconds?: number;
}

export interface VerifyOtpResult {
  success: boolean;
  message: string;
  remainingAttempts?: number;
  verificationToken?: string;
  reason?: 'NOT_FOUND_OR_EXPIRED' | 'MAX_ATTEMPTS_EXCEEDED' | 'INVALID_OTP' | 'INTERNAL_ERROR';
}

export interface SendOtpRequestBody {
  email: string;
}

export interface VerifyOtpRequestBody {
  email: string;
  otp: string;
}
