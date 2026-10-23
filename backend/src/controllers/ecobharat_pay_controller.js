/// Payment processing — hardened contract.
///
/// SECURITY MODEL (EcoBharatPay integration pending):
///   * The route requires a verified Bearer token (see paymentRoutes.js).
///   * Amounts are integer minor units (paise) with an explicit currency;
///     the server never trusts free-form client strings for money.
///   * Idempotency-Key is mandatory: replays of the same key return the
///     stored result instead of re-processing, and the same key cannot be
///     reused with a different payload.
///   * Status is 'initiated', never 'PAID': settlement must come from the
///     payment provider's signed webhook, never from a client claim.

const crypto = require('crypto');

/// key -> { fingerprint, response } (in-memory; swap for Redis when scaling
/// to multiple replicas — see docs/DEPLOYMENT notes).
const idempotencyStore = new Map();
const IDEMPOTENCY_TTL_MS = 24 * 60 * 60 * 1000;

function pruneIdempotency() {
    const now = Date.now();
    for (const [key, entry] of idempotencyStore) {
        if (now - entry.createdAt > IDEMPOTENCY_TTL_MS) {
            idempotencyStore.delete(key);
        }
    }
}

const CURRENCY_RE = /^[A-Z]{3}$/;

exports.processPayment = (req, res) => {
    const { amount, currency, method } = req.body || {};

    // ── Idempotency-Key: required, bounded, payload-bound ──────────────────
    const idemKey = req.headers['idempotency-key'];
    if (typeof idemKey !== 'string' || idemKey.length < 8 || idemKey.length > 128) {
        return res.status(400).json({
            error: 'Idempotency-Key header is required (8-128 chars)',
            code: 'IDEMPOTENCY_KEY_REQUIRED',
        });
    }

    // ── Validate money as integer minor units ──────────────────────────────
    if (!Number.isSafeInteger(amount) || amount <= 0 || amount > 100_000_000_00) {
        return res.status(400).json({
            error: 'amount must be a positive integer in minor units (paise)',
            code: 'INVALID_AMOUNT',
        });
    }
    if (typeof currency !== 'string' || !CURRENCY_RE.test(currency)) {
        return res.status(400).json({
            error: 'currency must be a 3-letter ISO code (e.g. INR)',
            code: 'INVALID_CURRENCY',
        });
    }
    const allowedMethods = ['UPI', 'Card', 'NetBanking', 'COD', 'Wallet'];
    if (!allowedMethods.includes(method)) {
        return res.status(400).json({
            error: `method must be one of: ${allowedMethods.join(', ')}`,
            code: 'INVALID_METHOD',
        });
    }

    // Fingerprint binds the key to THIS payload: replay with a different
    // amount/beneficiary must fail, not silently succeed.
    const fingerprint = crypto
        .createHash('sha256')
        .update(JSON.stringify({ amount, currency, method, sub: req.auth && req.auth.sub }))
        .digest('hex');

    pruneIdempotency();
    const existing = idempotencyStore.get(idemKey);
    if (existing) {
        if (existing.fingerprint !== fingerprint) {
            return res.status(409).json({
                error: 'Idempotency-Key reused with a different payload',
                code: 'IDEMPOTENCY_KEY_CONFLICT',
            });
        }
        // Same payload: return the stored result (safe replay).
        res.set('Idempotency-Replayed', 'true');
        return res.status(existing.response.statusCode).json(existing.response.body);
    }

    // ── Create the payment intent (no provider call yet) ───────────────────
    const body = {
        status: 'initiated',
        // Settlement is confirmed ONLY by the provider's signed webhook.
        transactionId: `pi_${crypto.randomUUID()}`,
        amount,
        currency,
        method,
        createdAt: new Date().toISOString(),
    };
    const response = { statusCode: 201, body };
    idempotencyStore.set(idemKey, { fingerprint, response, createdAt: Date.now() });
    res.status(201).json(body);
};

/// Test/ops helper — clears the in-memory idempotency store.
exports._resetIdempotencyStore = () => idempotencyStore.clear();