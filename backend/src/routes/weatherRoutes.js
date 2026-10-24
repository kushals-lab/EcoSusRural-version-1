const express = require('express');
const axios = require('axios');
const config = require('../config');
const { fetchCurrent } = require('../services/openWeatherCurrent');
const router = express.Router();
const cache = new Map();
const pending = new Map();
const TTL = 10 * 60 * 1000;
let rateLimitedUntil = 0;
router.get('/', async (req, res) => {
  const lat = Number(req.query.lat ?? config.defaultLatitude);
  const lon = Number(req.query.lon ?? config.defaultLongitude);
  if (!Number.isFinite(lat) || lat < -90 || lat > 90 || !Number.isFinite(lon) || lon < -180 || lon > 180) {
    return res.status(400).json({error: 'lat/lon must be valid coordinates'});
  }
  const key = lat.toFixed(2) + ',' + lon.toFixed(2);
  const saved = cache.get(key);
  const reply = (data, status) => res.json({...data, cache_status: status,
    is_live: status === 'fresh', server_time: new Date().toISOString()});
  if (saved && Date.now() - Date.parse(saved.last_fetched_at) < TTL) return reply(saved, 'backend_cache');
  try {
    if (Date.now() < rateLimitedUntil) throw new Error('rate limited');
    if (!pending.has(key)) {
      pending.set(key, (async () => {
        const endpoint = new URL(config.weatherApiBaseUrl);
        if (endpoint.protocol !== 'https:') throw new Error('Weather requires HTTPS');
        const params = {
          latitude: Number(lat.toFixed(2)), longitude: Number(lon.toFixed(2)),
          current: 'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,wind_direction_10m,precipitation,weather_code,surface_pressure',
          daily: 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,sunrise,sunset,uv_index_max,relative_humidity_2m_mean',
          hourly: 'visibility', timezone: 'auto', forecast_days: 7, timeformat: 'unixtime'
        };
        const [{data}, providerCurrent] = await Promise.all([
          axios.get(endpoint.toString(), {params, timeout: 15000}),
          fetchCurrent(lat, lon),
        ]);
        if (!data.daily || !Array.isArray(data.daily.time) || !data.current) throw new Error('Invalid weather response');
        const current = providerCurrent || data.current;
        const result = {...data, current,
          source: providerCurrent ? 'OpenWeather (current) + Open-Meteo (7-day forecast)' : 'Open-Meteo',
          observation_kind: providerCurrent ? 'provider current conditions + model forecast' : 'model estimate',
          source_reported_at: new Date(current.time * 1000).toISOString(),
          last_fetched_at: new Date().toISOString()};
        if (cache.size >= 300) cache.delete(cache.keys().next().value);
        cache.set(key, result);
        return result;
      })().finally(() => pending.delete(key)));
    }
    return reply(await pending.get(key), 'fresh');
  } catch (error) {
    if (error.response?.status === 429) rateLimitedUntil = Date.now() + 60000;
    if (saved) return reply(saved, 'stale_backend_cache');
    if (Date.now() < rateLimitedUntil) res.set('Retry-After', '60');
    return res.status(Date.now() < rateLimitedUntil ? 429 : 502).json({error: 'Weather unavailable', checked_at: new Date().toISOString()});
  }
});
module.exports = router;
