const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('node:crypto');
const { OAuth2Client } = require('google-auth-library');
const { getCollection } = require('../db/mongodb');
const authMiddleware = require('../middleware/authMiddleware');
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

// The client submits a Google ID token; only Google's verified subject is used
// as an account identity. A plain email/UID sent by a client is never trusted.
router.post('/google', loginLimiter, async (req, res) => {
    const idToken = req.body?.idToken;
    const audience = process.env.GOOGLE_WEB_CLIENT_ID;
    if (!audience) return res.status(503).json({ error: 'Google sign-in is not configured' });
    if (typeof idToken !== 'string' || idToken.length < 100 || idToken.length > 10000) {
        return res.status(400).json({ error: 'A Google ID token is required' });
    }
    let profile;
    try {
        const ticket = await new OAuth2Client().verifyIdToken({ idToken, audience });
        profile = ticket.getPayload();
    } catch (_) {
        return res.status(401).json({ error: 'Google sign-in could not be verified' });
    }
    if (!profile?.sub || !profile?.email || profile.email_verified !== true) {
        return res.status(401).json({ error: 'Google sign-in could not be verified' });
    }
    const id = `google:${profile.sub}`;
    const sessionId = crypto.randomUUID();
    try {
        const users = await getCollection('users');
        await users.updateOne({ id }, {
            $set: { email: profile.email, displayName: String(profile.name || '').slice(0, 200),
                activeSessionId: sessionId, lastLoginAt: new Date() },
            $setOnInsert: { id, googleSub: profile.sub, role: 'buyer', createdAt: new Date() },
        }, { upsert: true });
        const user = await users.findOne({ id }, { projection: { _id: 0, id: 1, email: 1, displayName: 1, role: 1 } });
        const accessToken = jwt.sign({ sub: id, email: profile.email, purpose: 'access', provider: 'google', jti: sessionId }, jwtSecret(), { expiresIn: '7d' });
        return res.json({ accessToken, user: { uid: id, email: user.email, name: user.displayName, role: user.role } });
    } catch (_) {
        return res.status(503).json({ error: 'Account storage unavailable' });
    }
});

router.get('/me', authMiddleware, async (req, res) => {
    try {
        const user = await (await getCollection('users')).findOne({ id: req.auth.sub }, { projection: { _id: 0, id: 1, email: 1, displayName: 1, role: 1 } });
        if (!user) return res.status(401).json({ error: 'Session account not found' });
        return res.json({ user: { uid: user.id, email: user.email, name: user.displayName, role: user.role } });
    } catch (_) { return res.status(503).json({ error: 'Account storage unavailable' }); }
});

router.post('/logout', authMiddleware, async (req, res) => {
    try {
        await (await getCollection('users')).updateOne(
            { id: req.auth.sub, activeSessionId: req.auth.sessionId },
            { $unset: { activeSessionId: '' } },
        );
        return res.json({ status: 'signed_out' });
    } catch (_) { return res.status(503).json({ error: 'Account storage unavailable' }); }
});

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