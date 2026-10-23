/// Current weather + 7-day forecast via the configured Open-Meteo endpoint.
/// Same provider family the app already uses (keyless). Coordinates are
/// validated as bounded floats before they touch the upstream URL.
'use strict';

const axios = require('axios');
const config = require('../../config');

function _clamp(n, lo, hi, fallback) {
  const v = Number.parseFloat(n);
  return Number.isFinite(v) && v >= lo && v <= hi ? v : fallback;
}

async function getForecast({ lat, lon }) {
  const la = _clamp(lat, -90, 90, Number(config.defaultLatitude));
  const lo = _clamp(lon, -180, 180, Number(config.defaultLongitude));
  const url = `${config.weatherApiBaseUrl}?latitude=${la}&longitude=${lo}`
    + '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code'
    + '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum'
    + '&timezone=Asia%2FKolkata&forecast_days=7';
  const r = await axios.get(url, { timeout: 15000 });
  return {
    lat: la, lon: lo,
    current: r.data.current || null,
    daily: r.data.daily || null,
    source: 'Open-Meteo Forecast (NWP models)',
    kind: 'model_forecast',
    fetchedAt: new Date().toISOString(),
  };
}

module.exports = { getForecast };