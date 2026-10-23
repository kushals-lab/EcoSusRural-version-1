"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const emailValidation_service_1 = require("../services/emailValidation.service");
const otp_service_1 = require("../services/otp.service");
class AuthController {
    /**
     * POST /api/v1/auth/send-otp
     * Validates syntax, blocks disposable emails, performs DNS MX lookup, and dispatches OTP.
     */
    static async sendOtp(req, res) {
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
            const validationResult = await emailValidation_service_1.EmailValidationService.validateEmail(email);
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
            const dispatchResult = await otp_service_1.OtpService.generateAndSendOtp(validationResult.normalizedEmail);
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
        }
        catch (error) {
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
    static async verifyOtp(req, res) {
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
            const verificationResult = await otp_service_1.OtpService.verifyOtp(normalizedEmail, trimmedOtp);
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
        }
        catch (error) {
            console.error('[AuthController.verifyOtp] Internal error:', error);
            res.status(500).json({
                success: false,
                message: 'An internal server error occurred during OTP verification.',
            });
        }
    }
}
exports.AuthController = AuthController;
