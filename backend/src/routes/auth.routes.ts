import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { sendOtpRateLimiter, verifyOtpRateLimiter } from '../middleware/authRateLimiter';

const router = Router();

/**
 * @route   POST /api/v1/auth/send-otp (or /api/auth/send-otp)
 * @desc    Validate email domain/MX and dispatch secure 6-digit OTP
 * @access  Public (Rate-limited)
 */
router.post('/send-otp', sendOtpRateLimiter, AuthController.sendOtp);

/**
 * @route   POST /api/v1/auth/verify-otp (or /api/auth/verify-otp)
 * @desc    Verify OTP with brute-force protection and receive verification token
 * @access  Public (Rate-limited)
 */
router.post('/verify-otp', verifyOtpRateLimiter, AuthController.verifyOtp);

export default router;
