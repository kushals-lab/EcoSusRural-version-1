"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("../controllers/auth.controller");
const authRateLimiter_1 = require("../middleware/authRateLimiter");
const router = (0, express_1.Router)();
/**
 * @route   POST /api/v1/auth/send-otp (or /api/auth/send-otp)
 * @desc    Validate email domain/MX and dispatch secure 6-digit OTP
 * @access  Public (Rate-limited)
 */
router.post('/send-otp', authRateLimiter_1.sendOtpRateLimiter, auth_controller_1.AuthController.sendOtp);
/**
 * @route   POST /api/v1/auth/verify-otp (or /api/auth/verify-otp)
 * @desc    Verify OTP with brute-force protection and receive verification token
 * @access  Public (Rate-limited)
 */
router.post('/verify-otp', authRateLimiter_1.verifyOtpRateLimiter, auth_controller_1.AuthController.verifyOtp);
exports.default = router;
