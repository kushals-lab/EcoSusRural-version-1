/// Security headers + request correlation IDs.
///
/// Adds hardening headers to every response and attaches an X-Request-Id so a
/// request can be traced across the app, backend gateway, and AI service.
const crypto = require('crypto');

function securityHeaders(req, res, next) {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  res.setHeader('X-DNS-Prefetch-Control', 'off');
  res.setHeader('Permissions-Policy', 'geolocation=(self), camera=(), microphone=()');
  next();
}

function requestId(req, res, next) {
  const incoming = req.headers['x-request-id'];
  const id = (typeof incoming === 'string' && incoming.length > 0 && incoming.length <= 128)
    ? incoming
    : crypto.randomUUID();
  req.requestId = id;
  res.setHeader('X-Request-Id', id);
  next();
}

module.exports = { securityHeaders, requestId };
