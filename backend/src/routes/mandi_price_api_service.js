/**
 * Mandi Price API Service
 * Feature: Live Mandi Commodity Prices Integration (data.gov.in)
 * Original: backend/src/routes/mandiRoutes.js
 */
const express = require('express');
const router = express.Router();
const axios = require('axios');

const apiKey = process.env.DATA_GOV_MANDI_API_KEY || '';
const resourceId = process.env.DATA_GOV_MANDI_RESOURCE_ID || '9ef84268-d588-465a-a308-a864a43d0070';
const BASE_URL = 'https://api.data.gov.in/resource';

let mandiCache = {
    timestamp: 0,
    data: null,
};
const CACHE_TTL_MS = 15 * 60 * 1000; // 15 minutes cache to prevent hitting rate limits

router.get('/prices', async (req, res) => {
    try {
        const { state, commodity, district, limit = 50, offset = 0 } = req.query;

        // Check cache if no specific query filters
        const now = Date.now();
        if (!state && !commodity && !district && mandiCache.data && (now - mandiCache.timestamp < CACHE_TTL_MS)) {
            return res.json({
                status: 'success',
                source: 'cached',
                count: mandiCache.data.length,
                records: mandiCache.data.slice(Number(offset), Number(offset) + Number(limit)),
            });
        }

        let queryUrl = `${BASE_URL}/${resourceId}?api-key=${apiKey}&format=json&limit=${limit}&offset=${offset}`;

        if (state) {
            queryUrl += `&filters[state]=${encodeURIComponent(state)}`;
        }
        if (commodity) {
            queryUrl += `&filters[commodity]=${encodeURIComponent(commodity)}`;
        }
        if (district) {
            queryUrl += `&filters[district]=${encodeURIComponent(district)}`;
        }

        const response = await axios.get(queryUrl, { timeout: 12000 });

        if (response.data && response.data.records) {
            // Update cache for general requests
            if (!state && !commodity && !district) {
                mandiCache = {
                    timestamp: now,
                    data: response.data.records,
                };
            }

            return res.json({
                status: 'success',
                source: 'live_data_gov_in',
                updated_date: response.data.updated_date,
                total: response.data.total,
                count: response.data.count,
                records: response.data.records,
            });
        }

        return res.status(502).json({ error: 'Unexpected response from mandi data provider' });
    } catch (error) {
        console.error('Mandi API Error:', error.message);
        return res.status(500).json({
            error: 'Failed to fetch current mandi prices',
            details: error.message,
        });
    }
});

module.exports = router;
