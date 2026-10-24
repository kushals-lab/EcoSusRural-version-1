const express = require('express');
const axios = require('axios');
const router = express.Router();
const cache = new Map();
router.get('/search', async (req, res) => {
  const name = String(req.query.q || '').trim().slice(0, 100);
  if (name.length < 2) return res.json({results: []});
  const key = name.toLowerCase();
  const saved = cache.get(key);
  if (saved && Date.now() - saved.at < 86400000) return res.json(saved.data);
  try {
    const {data} = await axios.get('https://geocoding-api.open-meteo.com/v1/search',
      {params: {name, count: 10, language: 'en', format: 'json'}, timeout: 10000});
    const result = {results: data.results || [], source: 'Open-Meteo / GeoNames'};
    if (cache.size >= 300) cache.delete(cache.keys().next().value);
    cache.set(key, {at: Date.now(), data: result});
    return res.json(result);
  } catch (_) { return res.status(502).json({error: 'Location search unavailable; enter your address manually'}); }
});
module.exports = router;
