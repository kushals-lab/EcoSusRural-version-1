import rateLimit from 'express-rate-limit';

export const sendOtpRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15-minute sliding window
  max: 5, // Maximum 5 OTP dispatches per IP per window
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many OTP requests from this IP address. Please try again after 15 minutes.',
  },
});

export const verifyOtpRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15-minute sliding window
  max: 15, // Maximum 15 attempts total per IP per window
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many verification attempts from this IP address. Please try again later.',
  },
});
