'use strict';

const axios = require('axios');

function keys() {
  return [...new Set((process.env.OPENWEATHER_API_KEYS || '')
    .split(',').map((key) => key.trim()).filter(Boolean))];
}

function weatherCode(id) {
  if (id >= 200 && id < 300) return 95;
  if (id >= 300 && id < 400) return 51;
  if (id >= 500 && id < 600) return id >= 502 ? 65 : 61;
  if (id >= 600 && id < 700) return 71;
  if (id >= 700 && id < 800) return 45;
  if (id === 800) return 0;
  if (id === 801) return 1;
  if (id === 802) return 2;
  if (id >= 803 && id < 900) return 3;
  return null;
}

async function fetchCurrent(lat, lon) {
  for (const key of keys()) {
    try {
      const { data } = await axios.get('https://api.openweathermap.org/data/2.5/weather', {
        params: { lat, lon, appid: key, units: 'metric' }, timeout: 10000,
      });
      if (!Number.isFinite(data?.main?.temp) || !Number.isFinite(data?.dt)) return null;
      return {
        time: data.dt,
        temperature_2m: data.main.temp,
        apparent_temperature: data.main.feels_like ?? null,
        relative_humidity_2m: data.main.humidity ?? null,
        wind_speed_10m: Number.isFinite(data.wind?.speed) ? Math.round(data.wind.speed * 3.6 * 10) / 10 : null,
        wind_direction_10m: data.wind?.deg ?? null,
        precipitation: data.rain?.['1h'] ?? null,
        weather_code: weatherCode(data.weather?.[0]?.id),
        surface_pressure: data.main.grnd_level ?? null,
      };
    } catch (error) {
      // Retry using a distinct key only for key-specific or quota failures.
      if (![401, 403, 429].includes(error.response?.status)) return null;
    }
  }
  return null;
}

module.exports = { fetchCurrent, keys, weatherCode };
