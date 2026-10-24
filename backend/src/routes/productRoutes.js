const express = require('express');
const db = require('../db/postgres');
const router = express.Router();
router.get('/', async (req,res) => {
  try {
    const {rows} = await db.query("SELECT id,title,category,price,stock_quantity,updated_at FROM products WHERE approval_status='approved' ORDER BY updated_at DESC LIMIT 100");
    res.json({records: rows, last_fetched_at: new Date().toISOString(), source: 'EcoSusRural approved listings'});
  } catch (_) { res.status(503).json({error: 'Product catalog unavailable'}); }
});
module.exports = router;
