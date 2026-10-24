/// Bearer-token authentication middleware.
///
/// Verifies the `Authorization: Bearer <jwt>` header with the shared
/// JWT_SECRET (see security/secrets.js). On success attaches
/// `req.auth = { sub, email, purpose }`; on failure returns 401/403.
/// Rejects token types that are not access tokens (e.g. OTP verification
/// tokens carry purpose=email_verification and cannot be used as sessions).
const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../security/secrets');
const { getCollection } = require('../db/mongodb');

async function authMiddleware(req, res, next) {
    const header = req.headers['authorization'] || '';
    const [scheme, token] = header.split(' ');

    if (scheme !== 'Bearer' || !token) {
        return res.status(401).json({ error: 'Missing or malformed Authorization header' });
    }

    try {
        const payload = jwt.verify(token, jwtSecret());
        if (payload.purpose && payload.purpose !== 'access') {
            return res.status(403).json({ error: 'Token not valid for this operation' });
        }
        if (payload.provider === 'google' || payload.provider === 'email_otp') {
            if (typeof payload.jti !== 'string') return res.status(401).json({ error: 'Invalid session' });
            let user;
            try {
                user = await (await getCollection('users')).findOne({ id: payload.sub }, { projection: { activeSessionId: 1 } });
            } catch (_) { return res.status(503).json({ error: 'Session storage unavailable' }); }
            if (user?.activeSessionId !== payload.jti) return res.status(401).json({ error: 'Session expired' });
        }
        req.auth = { sub: payload.sub, email: payload.email, purpose: payload.purpose || 'access', sessionId: payload.jti };
        next();
    } catch (err) {
        const message =
            err && err.name === 'TokenExpiredError' ? 'Token expired' : 'Invalid token';
        return res.status(401).json({ error: message });
    }
}

module.exports = authMiddleware;
