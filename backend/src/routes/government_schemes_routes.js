/**
 * Government Schemes Routes
 * Feature: Government subsidy, grant, and support schemes listing
 * Original: backend/src/routes/schemeRoutes.js
 */
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
    res.json([
        { id: "1", name: "Organic Subsidy Scheme", amount: 5000 },
        { id: "2", name: "Solar Irrigation Grant", amount: 12000 }
    ]);
});

module.exports = router;
