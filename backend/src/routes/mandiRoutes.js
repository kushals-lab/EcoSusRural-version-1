const express = require('express');
const axios = require('axios');
const {saveSnapshot} = require('../services/priceHistory');
const db = require('../db/postgres');
const router = express.Router();
const cache = new Map(), pending = new Map();
const TTL = 60 * 60 * 1000;
const source = 'https://data.gov.in/resource/current-daily-price-various-commodities-various-markets-mandi';
let blockedUntil = 0;
function filters(query) {
  const result = {limit: Math.min(Math.max(parseInt(query.limit,10) || 50,1),100),
    offset: Math.min(Math.max(parseInt(query.offset,10) || 0,0),100000)};
  for (const key of ['state','district','commodity']) if (query[key]) result[key] = String(query[key]).slice(0,100);
  return result;
}
async function fetchPrices(query) {
  const key = JSON.stringify(query);
  if (pending.has(key)) return pending.get(key);
  pending.set(key, (async () => {
    const apiKey = process.env.DATA_GOV_MANDI_API_KEY;
    if (!apiKey) throw new Error('not configured');
    if (Date.now() < blockedUntil) throw new Error('rate limited');
    const resource = process.env.DATA_GOV_MANDI_RESOURCE_ID || '9ef84268-d588-465a-a308-a864a43d0070';
    if (!/^[a-f0-9-]{36}$/.test(resource)) throw new Error('Invalid resource');
    const params = {'api-key': apiKey, format: 'json', limit: query.limit, offset: query.offset};
    for (const key of ['state','district','commodity']) if (query[key]) params['filters['+key+']'] = query[key];
    const {data} = await axios.get('https://api.data.gov.in/resource/'+resource, {params, timeout: 15000});
    if (!Array.isArray(data.records)) throw new Error('Invalid mandi response');
    const records = data.records.map(r => ({...r, unit: 'INR/quintal'}));
    const payload = {records, total: data.total, count: records.length, source,
      source_reported_at: data.updated_date || null, last_synced_at: new Date().toISOString()};
    payload.history_persisted = await saveSnapshot('mandi', source, payload);
    if (cache.size >= 100) cache.delete(cache.keys().next().value);
    cache.set(key, {payload, query, at: Date.now()});
    return payload;
  })().catch(error => {
    if (error.response?.status === 429) blockedUntil = Date.now()+60000;
    throw error;
  }).finally(() => pending.delete(key)));
  return pending.get(key);
}
router.get('/prices', async (req,res) => {
  const query = filters(req.query), key = JSON.stringify(query), saved = cache.get(key);
  if (saved && Date.now()-saved.at < TTL) return res.json({...saved.payload, is_live:false, cache_status:'backend_cache'});
  try { res.json({...await fetchPrices(query), is_live:false, is_fresh_fetch:true, cache_status:'fresh'}); }
  catch (_) {
    if (saved) return res.json({...saved.payload, is_live:false, cache_status:'stale_backend_cache'});
    const rateLimited = Date.now() < blockedUntil;
    if (rateLimited) res.set('Retry-After','60');
    res.status(rateLimited ? 429 : 503).json({error: 'Official mandi data unavailable or provider key missing', checked_at:new Date().toISOString(), source});
  }
});
router.get('/history', async (req,res) => {
  try {
    const {rows} = await db.query("SELECT payload,fetched_at FROM official_price_snapshots WHERE dataset='mandi' ORDER BY fetched_at DESC LIMIT 30");
    res.json({records: rows, source});
  } catch (_) { res.status(503).json({error:'Historical price storage unavailable'}); }
});
setInterval(async () => {
  for (const saved of [...cache.values()]) {
    if (Date.now()-saved.at >= TTL) {
      try { await fetchPrices(saved.query); } catch (_) { break; }
    }
  }
}, TTL).unref();
module.exports = router;
module.exports.filters = filters;
module.exports.fetchPrices = fetchPrices;
