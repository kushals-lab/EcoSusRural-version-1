const express = require('express');
const db = require('../db/postgres');
const auth = require('../middleware/authMiddleware');
const router = express.Router();
router.use(auth);
router.use((req, res, next) => {
  if (typeof req.auth.sub !== 'string' || !req.auth.sub || req.auth.sub.length > 200) return res.status(403).json({error: 'Account identity required'});
  next();
});
router.get('/locations', async (req, res) => {
  try { const {rows} = await db.query('SELECT purpose, preference, updated_at FROM account_location_preferences WHERE account_id=$1', [req.auth.sub]); res.json({records: rows}); }
  catch (_) { res.status(503).json({error: 'Account storage unavailable'}); }
});
router.post('/locations', async (req, res) => {
  const {purpose, preference} = req.body;
  if (!['weather','farm','business','market'].includes(purpose) || !preference || typeof preference !== 'object' || JSON.stringify(preference).length > 4000) return res.status(400).json({error: 'Invalid location'});
  for (const [key, max] of [['latitude',90],['longitude',180]]) {
    if (preference[key] != null && (typeof preference[key] !== 'number' || !Number.isFinite(preference[key]) || Math.abs(preference[key]) > max)) return res.status(400).json({error: 'Invalid coordinates'});
  }
  try {
    await db.query('INSERT INTO account_location_preferences(account_id,purpose,preference) VALUES($1,$2,$3::jsonb) ON CONFLICT(account_id,purpose) DO UPDATE SET preference=EXCLUDED.preference, updated_at=now()', [req.auth.sub,purpose,JSON.stringify(preference)]);
    res.json({status: 'saved'});
  } catch (_) { res.status(503).json({error: 'Account storage unavailable'}); }
});
router.post('/reminders', async (req, res) => {
  const {id, metadata} = req.body;
  if (!/^[\w-]{1,80}$/.test(String(id)) || !metadata || JSON.stringify(metadata).length > 10000) return res.status(400).json({error: 'Invalid reminder metadata'});
  try {
    await db.query('INSERT INTO account_reminders(account_id,reminder_id,metadata) VALUES($1,$2,$3::jsonb) ON CONFLICT(account_id,reminder_id) DO UPDATE SET metadata=EXCLUDED.metadata,updated_at=now()', [req.auth.sub,String(id),JSON.stringify(metadata)]);
    res.json({status: 'saved', device_scheduling: 'local_only'});
  } catch (_) { res.status(503).json({error: 'Reminder sync unavailable'}); }
});
router.post('/drafts', async (req, res) => {
  const {id, payload} = req.body;
  if (!/^[\w-]{1,80}$/.test(String(id)) || !payload || typeof payload.title !== 'string' || !payload.title.trim() || payload.title.length > 255 || !Number.isFinite(payload.price) || payload.price < 0 || JSON.stringify(payload).length > 20000) return res.status(400).json({error: 'Invalid product draft'});
  try {
    const seller = await db.query('SELECT role FROM users WHERE id=$1', [req.auth.sub]);
    if (!['seller','organization','farmer'].includes(seller.rows[0]?.role)) return res.status(403).json({error: 'Verified seller account required'});
    await db.query('INSERT INTO product_listing_drafts(account_id,draft_id,payload) VALUES($1,$2,$3::jsonb) ON CONFLICT(account_id,draft_id) DO UPDATE SET payload=EXCLUDED.payload,updated_at=now()', [req.auth.sub,String(id),JSON.stringify(payload)]);
    res.json({status: 'pending_review', id});
  } catch (_) { res.status(503).json({error: 'Draft sync unavailable'}); }
});
router.post('/grievances', async (req, res) => {
  const {id, payload} = req.body;
  const required = ['name','mobile','commodity','market','transactionDate','description','category'];
  if (!/^[\w-]{1,80}$/.test(String(id)) || !payload || required.some(k => typeof payload[k] !== 'string' || !payload[k].trim()) || JSON.stringify(payload).length > 20000 || !Number.isFinite(payload.priceReceived) || payload.priceReceived < 0) return res.status(400).json({error: 'Complete the required grievance fields'});
  try {
    await db.query('INSERT INTO private_grievances(account_id,submission_id,payload) VALUES($1,$2,$3::jsonb) ON CONFLICT DO NOTHING', [req.auth.sub,String(id),JSON.stringify(payload)]);
    res.json({status: 'received_by_ecosusrural', official_submission: false, id});
  } catch (_) { res.status(503).json({error: 'Secure grievance storage unavailable; use the official portal'}); }
});
module.exports = router;
