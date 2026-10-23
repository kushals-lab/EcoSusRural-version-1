/**
 * Solar Dryer Telemetry Routes
 * Feature: Smart Solar Dryer Monitoring, Batch Recording & Telemetry
 * Original: backend/src/routes/dryerRoutes.js
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');

// In-memory store for the first integration; swap for Mongo/Postgres later.
// Keyed as `${userId}:${batchId}` so ownership is enforced at the data layer.
const batches = new Map();

function batchKey(userId, batchId) {
    return `${userId}:${batchId}`;
}

/// Whitelist-only projection of an incoming batch object.
function sanitizeBatch(body, userId) {
    const out = {
        id: String(body.id).slice(0, 64),
        crop: typeof body.crop === 'string' ? body.crop.slice(0, 64) : '',
        notes: typeof body.notes === 'string' ? body.notes.slice(0, 512) : '',
        ownerId: userId,
        updatedAt: new Date().toISOString(),
    };
    return out;
}

/// Whitelist-only projection of a reading (numeric sensor payload).
function sanitizeReading(body) {
    const num = (v, lo, hi) => {
        const n = typeof v === 'number' ? v : Number(v);
        return Number.isFinite(n) && n >= lo && n <= hi ? n : null;
    };
    return {
        collectorC: num(body.collectorC, -40, 250),
        chamberC: num(body.chamberC, -40, 250),
        ambientC: num(body.ambientC, -40, 80),
        chamberRh: num(body.chamberRh, 0, 100),
        ambientRh: num(body.ambientRh, 0, 100),
        airflow: num(body.airflow, 0, 1000),
        fanOn: body.fanOn === true,
        fanPwm: num(body.fanPwm, 0, 255),
        state: typeof body.state === 'string' ? body.state.slice(0, 32) : '',
        recordedAt: new Date().toISOString(),
    };
}

router.get('/batches', authMiddleware, (req, res) => {
    const prefix = `${req.auth.sub}:`;
    const mine = [];
    for (const [key, value] of batches) {
        if (key.startsWith(prefix)) mine.push(value);
    }
    res.json({ batches: mine });
});

router.post('/batches', authMiddleware, (req, res) => {
    const b = req.body;
    if (!b || typeof b.id !== 'string' || b.id.length === 0 || b.id.length > 64) {
        return res.status(400).json({ error: 'id (string, <=64 chars) required' });
    }
    const record = sanitizeBatch(b, req.auth.sub);
    batches.set(batchKey(req.auth.sub, record.id), record);
    res.json({ ok: true, id: record.id });
});

router.post('/batches/:id/readings', authMiddleware, (req, res) => {
    const id = String(req.params.id).slice(0, 64);
    const key = batchKey(req.auth.sub, id);
    const b = batches.get(key);
    // 404 for both "missing" and "belongs to someone else" — no existence
    // oracle for other users' resources.
    if (!b) return res.status(404).json({ error: 'batch not found' });

    b.readings = b.readings || [];
    b.readings.push(sanitizeReading(req.body || {}));
    if (b.readings.length > 2000) b.readings = b.readings.slice(-2000);
    res.json({ ok: true, count: b.readings.length });
});

module.exports = router;
