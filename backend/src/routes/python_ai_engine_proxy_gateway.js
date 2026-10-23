/**
 * Python AI Engine Proxy Gateway
 * Feature: Forwarding requests securely from Node Express to FastAPI Python AI engine
 * Original: backend/src/routes/apiGateway.js
 */
const express = require('express');
const router = express.Router();
const axios = require('axios');
const rateLimit = require('express-rate-limit');
const config = require('../config');
const authMiddleware = require('../middleware/authMiddleware');

/// AI proxy budget: cheap enough for rural 2G users (one request per
/// couple of seconds), tight enough to stop quota-draining abuse.
const aiLimiter = rateLimit({
    windowMs: 60 * 1000,
    max: 30,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => (req.auth && req.auth.sub) || req.ip,
    message: { error: 'Too many AI requests. Please wait and try again.' },
});

router.post('/forward-ai', authMiddleware, aiLimiter, async (req, res) => {
    try {
        // The upstream URL is fixed (server config) — never client-supplied,
        // which prevents SSRF / proxy abuse. Only a JSON object body is
        // forwarded, bounded by the global 256 kB body limit.
        const payload = req.body;
        if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
            return res.status(400).json({ error: 'Request body must be a JSON object' });
        }

        const aiUrl = `${config.aiServiceUrl}${config.aiServiceComputePath}`;
        const headers = config.aiServiceToken
            ? { Authorization: `Bearer ${config.aiServiceToken}` }
            : undefined;
        const response = await axios.post(aiUrl, payload, {
            headers,
            timeout: 20000,
            maxContentLength: 256 * 1024,
            validateStatus: (status) => status < 500,
        });
        res.status(response.status).json({ gatewayStatus: 'Success', aiResult: response.data });
    } catch (error) {
        console.error('AI forward failed:', error.message);
        res.status(502).json({ error: 'AI microservice unreachable' });
    }
});

module.exports = router;
