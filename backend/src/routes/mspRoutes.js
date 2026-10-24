const express = require('express');
const axios = require('axios');
const {saveSnapshot} = require('../services/priceHistory');
const router = express.Router();
const SOURCE = 'https://www.tnagrisnet.tn.gov.in/home/msp/en';
let cache = null, pending = null;
const clean = s => s.replace(/<[^>]*>/g, ' ').replace(/&nbsp;|&#160;/g, ' ').replace(/\s+/g, ' ').trim();
function parseMsp(html) {
  const season = clean(html).match(/Minimum Support Price\s*[-–]\s*(20\d{2}-\d{2,4})/i)?.[1];
  if (!season || !/Quantity\s*\(Quintal\)/i.test(clean(html))) throw new Error('MSP source format changed');
  const records = [];
  for (const row of html.matchAll(/<tr\b[^>]*>([\s\S]*?)<\/tr>/gi)) {
    const cells = [...row[1].matchAll(/<td\b[^>]*>([\s\S]*?)<\/td>/gi)].map(m => clean(m[1]));
    if (cells.length !== 4 || !/^\d+$/.test(cells[0])) continue;
    if (/sugarcane/i.test(cells[1])) continue; // FRP is not MSP.
    const quantity = Number(cells[2].replace(/,/g,'')), price = Number(cells[3].replace(/,/g,''));
    if (quantity !== 1 || !Number.isFinite(price) || price <= 0) throw new Error('Invalid MSP record');
    records.push({commodity: cells[1], msp: price, season, crop_season: 'Published marketing year', unit: 'INR/quintal', source: SOURCE});
  }
  if (!records.length) throw new Error('No verified MSP rows');
  return {records, effective_season: season, source: SOURCE, source_reported_at: null};
}
async function refresh() {
  if (pending) return pending;
  pending = (async () => {
    const response = await axios.get(SOURCE, {timeout: 15000, maxContentLength: 2000000,
      headers: cache?.etag ? {'If-None-Match': cache.etag} : {}, validateStatus: s => s === 200 || s === 304});
    if (response.status === 304 && cache) { cache.checkedAt = Date.now(); return cache; }
    const data = {...parseMsp(response.data), last_synced_at: new Date().toISOString()};
    data.history_persisted = await saveSnapshot('msp', SOURCE, data);
    cache = {...data, checkedAt: Date.now(), etag: response.headers.etag};
    return cache;
  })().finally(() => { pending = null; });
  return pending;
}
router.get('/', async (req, res) => {
  try {
    const fresh = !cache || Date.now() - cache.checkedAt > 86400000;
    const data = fresh ? await refresh() : cache;
    res.json({...data, cache_status: fresh ? 'fresh' : 'backend_cache'});
  } catch (_) {
    if (cache) return res.json({...cache, cache_status: 'stale_backend_cache'});
    res.status(503).json({error: 'Official MSP source unavailable', source: SOURCE, records: []});
  }
});
// Once used, check at the source's daily cadence, not on every screen rebuild.
setInterval(() => { if (cache) refresh().catch(() => {}); }, 86400000).unref();
module.exports = router;
module.exports.parseMsp = parseMsp;
