const crypto = require('node:crypto');
const db = require('../db/postgres');
async function saveSnapshot(dataset, source, payload) {
  const stable = JSON.stringify(payload.records || []);
  const hash = crypto.createHash('sha256').update(stable).digest('hex');
  try {
    await db.query('INSERT INTO official_price_snapshots(dataset,content_hash,source_url,payload) VALUES($1,$2,$3,$4::jsonb) ON CONFLICT DO NOTHING',
      [dataset, hash, source, JSON.stringify(payload)]);
    return true;
  } catch (_) { return false; }
}
module.exports = {saveSnapshot};
