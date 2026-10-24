const express = require('express');
const db = require('../db/postgres');
const {catalog, checks} = require('../services/schemeLinks');
const router = express.Router();
router.get('/links', (req,res) => res.json({records: catalog.map(r => ({...r, ...checks.get(r.id)}))}));
router.get('/', async (req,res) => {
  try {
    const {rows} = await db.query('SELECT * FROM scheme_directory ORDER BY name');
    const records = rows.map(r => {
      const age = r.last_verified_at ? Date.now()-new Date(r.last_verified_at).getTime() : Infinity;
      return {...r, application_status: age < 0 || age > 7*86400000 ? 'unknown' : r.application_status};
    });
    res.json(records);
  } catch (_) { res.status(503).json({error: 'Scheme directory unavailable; use reviewed information links'}); }
});
module.exports = router;
