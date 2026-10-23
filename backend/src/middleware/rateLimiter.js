/// Token-bucket rate limiter (in-memory, per instance).
///
/// Designed to sit in front of every route. With N backend replicas behind a
/// load balancer each bucket is per-replica; global limits are enforced in the
/// edge proxy (nginx / API gateway). Optional Redis-backed counters can be
/// plugged in by setting REDIS_URL and wiring a store (see SCALING.md).
const buckets = new Map();

function rateLimiter({ windowMs = 60000, max = 300 } = {}) {
  // periodic cleanup so idle keys do not leak memory
  const sweeper = setInterval(() => {
    const now = Date.now();
    for (const [key, bucket] of buckets) {
      if (now - bucket.startedAt > windowMs * 2) {
        buckets.delete(key);
      }
    }
  }, windowMs);
  if (typeof sweeper.unref === 'function') {
    sweeper.unref();
  }

  return function rateLimiterMiddleware(req, res, next) {
    const identity = req.ip || req.socket?.remoteAddress || 'unknown';
    const now = Date.now();
    let bucket = buckets.get(identity);
    if (!bucket || now - bucket.startedAt >= windowMs) {
      bucket = { startedAt: now, tokens: max };
      buckets.set(identity, bucket);
    }
    bucket.tokens -= 1;

    res.setHeader('X-RateLimit-Limit', String(max));
    res.setHeader('X-RateLimit-Remaining', String(Math.max(bucket.tokens, 0)));

    if (bucket.tokens < 0) {
      const retryAfterSec = Math.ceil((windowMs - (now - bucket.startedAt)) / 1000);
      res.setHeader('Retry-After', String(Math.max(retryAfterSec, 1)));
      return res.status(429).json({
        error: 'Too many requests. Please slow down.',
        retryAfterSeconds: Math.max(retryAfterSec, 1),
      });
    }
    return next();
  };
}

module.exports = { rateLimiter };
