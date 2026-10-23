const express = require('express');
const router = express.Router();
const axios = require('axios');
const config = require('../config');

// Weather endpoint uses the configured Open-Meteo base URL and fallback
// default coordinates; the coordinates remain environment-overridable.
let cache = { key: null, data: null, fetchedAt: 0 };
const CACHE_TTL_MS = 10 * 60 * 1000;

router.get('/', async (req, res) => {
    try {
        // Validate coordinates as bounded floats before they touch the
        // upstream URL (prevents query-param injection and junk traffic).
        const lat = Number.parseFloat(req.query.lat ?? config.defaultLatitude);
        const lon = Number.parseFloat(req.query.lon ?? config.defaultLongitude);
        if (!Number.isFinite(lat) || lat < -90 || lat > 90 ||
            !Number.isFinite(lon) || lon < -180 || lon > 180) {
            return res.status(400).json({ error: 'lat/lon must be valid coordinates' });
        }
        const cacheKey = `${lat},${lon}`;

        const now = Date.now();
        if (cache.key === cacheKey && cache.data && now - cache.fetchedAt < CACHE_TTL_MS) {
            return res.json(cache.data);
        }

        let url = `${config.weatherApiBaseUrl}?latitude=${lat}&longitude=${lon}`
            + '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code'
            + '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum'
            + '&timezone=Asia/Kolkata'
            + '&forecast_days=7';

        // Append API key if configured (supports both Open-Meteo and other weather providers)
        if (config.weatherApiKey) {
            url += `&api_key=${encodeURIComponent(config.weatherApiKey)}`;
        }

        const headers = {};
        if (config.weatherApiHeader) {
            const [headerName, headerValue] = config.weatherApiHeader.split(':', 2);
            if (headerName && headerValue) {
                headers[headerName.trim()] = headerValue.trim();
            }
        }

        const response = await axios.get(url, { timeout: 15000, headers });

        cache = { key: cacheKey, data: response.data, fetchedAt: now };
        res.json(response.data);
    } catch (error) {
        console.error('Weather API error:', error.message);
        res.status(502).json({ error: 'Weather service unreachable' });
    }
});

module.exports = router;