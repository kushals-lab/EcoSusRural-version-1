// Persistent, user-scoped solar-dryer backups in MongoDB Atlas.
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { getCollection } = require('../db/mongodb');

let indexesReady;
async function batchesCollection() {
  const collection = await getCollection('dryer_batches');
  if (!indexesReady) indexesReady = collection.createIndex({ ownerId: 1, id: 1 }, { unique: true });
  await indexesReady;
  return collection;
}

function sanitizeBatch(body, ownerId) {
  return { id: String(body.id).slice(0, 64), crop: typeof body.crop === 'string' ? body.crop.slice(0, 64) : '',
    notes: typeof body.notes === 'string' ? body.notes.slice(0, 512) : '', ownerId, updatedAt: new Date().toISOString() };
}
function sanitizeReading(body) {
  const num = (value, low, high) => {
    const number = typeof value === 'number' ? value : Number(value);
    return Number.isFinite(number) && number >= low && number <= high ? number : null;
  };
  return { collectorC: num(body.collectorC, -40, 250), chamberC: num(body.chamberC, -40, 250),
    ambientC: num(body.ambientC, -40, 80), chamberRh: num(body.chamberRh, 0, 100), ambientRh: num(body.ambientRh, 0, 100),
    airflow: num(body.airflow, 0, 1000), fanOn: body.fanOn === true, fanPwm: num(body.fanPwm, 0, 255),
    state: typeof body.state === 'string' ? body.state.slice(0, 32) : '', recordedAt: new Date().toISOString() };
}

router.get('/batches', authMiddleware, async (req, res) => {
  try {
    const batches = await (await batchesCollection()).find({ ownerId: req.auth.sub }, { projection: { _id: 0 } }).sort({ updatedAt: -1 }).toArray();
    res.json({ batches });
  } catch (_) { res.status(503).json({ error: 'Dryer backup storage unavailable' }); }
});
router.post('/batches', authMiddleware, async (req, res) => {
  const body = req.body;
  if (!body || typeof body.id !== 'string' || body.id.length === 0 || body.id.length > 64) return res.status(400).json({ error: 'id (string, <=64 chars) required' });
  try {
    const record = sanitizeBatch(body, req.auth.sub);
    await (await batchesCollection()).updateOne({ ownerId: req.auth.sub, id: record.id }, { $set: record, $setOnInsert: { readings: [] } }, { upsert: true });
    res.json({ ok: true, id: record.id });
  } catch (_) { res.status(503).json({ error: 'Dryer backup storage unavailable' }); }
});
router.post('/batches/:id/readings', authMiddleware, async (req, res) => {
  const id = String(req.params.id).slice(0, 64);
  try {
    const result = await (await batchesCollection()).findOneAndUpdate({ ownerId: req.auth.sub, id },
      { $push: { readings: { $each: [sanitizeReading(req.body || {})], $slice: -2000 } }, $set: { updatedAt: new Date().toISOString() } },
      { returnDocument: 'after', projection: { readings: { $slice: -2000 } } });
    if (!result) return res.status(404).json({ error: 'batch not found' });
    res.json({ ok: true, count: result.readings?.length || 0 });
  } catch (_) { res.status(503).json({ error: 'Dryer backup storage unavailable' }); }
});
module.exports = router;
