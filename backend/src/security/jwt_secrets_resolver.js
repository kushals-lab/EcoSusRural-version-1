/// Centralised JWT secret resolution for the JS half of the backend.
///
/// SECURITY CONTRACT:
///   * In production (NODE_ENV === 'production') JWT_SECRET is MANDATORY.
///     A missing secret aborts startup — fail closed, never fall back to a
///     publicly-known constant (that would allow token forgery).
///   * In development, if JWT_SECRET is unset, a random per-boot secret is
///     generated so tokens cannot be forged from the public repository, and
///     restarts invalidate old dev tokens (acceptable for local work).
const crypto = require('crypto');

let cachedSecret = null;

function jwtSecret() {
  if (cachedSecret) return cachedSecret;

  const fromEnv = (process.env.JWT_SECRET || '').trim();
  const isProd =
    process.env.NODE_ENV === 'production' ||
    process.env.NODE_ENV === 'prod';

  if (isProd) {
    if (fromEnv.length < 32) {
      // Refuse to boot with a weak/missing signing key in production.
      throw new Error(
        '[secrets] JWT_SECRET must be set to at least 32 characters in production. ' +
          'Generate one with: node -e "console.log(require(\'crypto\').randomBytes(32).toString(\'hex\'))"',
      );
    }
    cachedSecret = fromEnv;
    return cachedSecret;
  }

  // Development / test: env value if provided, otherwise random per process.
  cachedSecret = fromEnv.length >= 16 ? fromEnv : crypto.randomBytes(32).toString('hex');
  return cachedSecret;
}

module.exports = { jwtSecret };
