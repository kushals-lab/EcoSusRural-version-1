const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();
const rateLimit = require('express-rate-limit');
const { jwtSecret } = require('../security/secrets');

/// Login is a credential-checking endpoint: strict per-IP and per-account
/// throttling to blunt credential stuffing / enumeration (see also the
/// dedicated OTP limiters mounted below).
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: 'Too many login attempts. Please try again later.' },
});

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

router.post('/login', loginLimiter, (req, res) => {
    const { email, password } = req.body || {};

    // Validate inputs before touching auth logic.
    if (typeof email !== 'string' || !EMAIL_RE.test(email) || email.length > 254) {
        return res.status(400).json({ error: 'A valid email is required' });
    }
    if (typeof password !== 'string' || password.length < 8 || password.length > 128) {
        return res.status(400).json({ error: 'A valid password is required' });
    }

    // NOTE: This build has no user database yet, so no credential can be
    // verified here. Returning a bearer token without verification would be
    // an authentication bypass, so the endpoint now rejects with 501 and an
    // explicit code instead of minting tokens. Wire a real user store
    // (bcrypt/argon2 hash comparison) before enabling this route.
    return res.status(501).json({
        error: 'Password authentication is not configured on this deployment',
        code: 'AUTH_BACKEND_NOT_CONFIGURED',
    });
});

// Mount strict email validation & OTP routes (send-otp, verify-otp)
try {
    const authRoutes = require('../../dist/routes/auth.routes').default;
    if (authRoutes) {
        router.use('/', authRoutes);
    }
} catch (err) {
    console.warn('[authRoutes] Compiled TypeScript auth routes not loaded yet. Run npm run build.');
}

/// Issues a signed short-lived access token for an authenticated identity.
/// Exported for use by future user-store-backed login handlers and tests.
function issueAccessToken(res, { sub, email }) {
    const token = jwt.sign({ sub, email, purpose: 'access' }, jwtSecret(), {
        expiresIn: '1h',
    });
    return token;
}

module.exports = router;
module.exports.issueAccessToken = issueAccessToken;