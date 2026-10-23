/**
 * EcoBharat Pay Payment Routes
 * Feature: Payment processing, UPI & wallet payment integration with rate-limiting
 * Original: backend/src/routes/paymentRoutes.js
 */
const express = require('express');
const router = express.Router();
const rateLimit = require('express-rate-limit');
const paymentController = require('../controllers/paymentControllers');
const authMiddleware = require('../middleware/authMiddleware');

/// Financial endpoints get their own tight budget, separate from the
/// global limiter, keyed per authenticated user where possible.
const paymentLimiter = rateLimit({
    windowMs: 60 * 1000,
    max: 20,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => (req.auth && req.auth.sub) || req.ip,
    message: { error: 'Too many payment requests. Please slow down.' },
});

// Auth first, then rate limit (so the limiter can key on the verified user).
router.post('/process', authMiddleware, paymentLimiter, paymentController.processPayment);

module.exports = router;
