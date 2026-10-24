'use strict';

const path = require('node:path');
const express = require('express');
const rateLimit = require('express-rate-limit');
const { createDryerSessions } = require('../simulation/dryerSessions');

function createDryerSimulator({ sessions = createDryerSessions() } = {}) {
  const api = express.Router();
  const site = express.Router();
  const enabled = (req, res, next) => {
    const production = ['production', 'prod'].includes(process.env.NODE_ENV);
    if (production && process.env.ENABLE_DRYER_SIMULATOR !== 'true') return res.status(404).json({ error: 'Not found' });
    res.setHeader('Cache-Control', 'no-store');
    next();
  };
  api.use(enabled);
  site.use(enabled);
  const limited = rateLimit({ windowMs: 60000, max: 20, standardHeaders: true, legacyHeaders: false });
  const handle = (fn) => (req, res) => {
    try { fn(req, res); }
    catch (error) { res.status(error.status || 500).json({ error: error.status ? error.message : 'Simulation unavailable.' }); }
  };
  api.post('/sessions', limited, handle((req, res) => res.status(201).json(sessions.create())));
  api.post('/pair', limited, handle((req, res) => {
    if (typeof req.body?.code !== 'string' || !/^\d{6}$/.test(req.body.code)) return res.status(400).json({ error: 'Enter the six-digit pairing code from the HTML simulator.' });
    res.json(sessions.pair(req.body.code));
  }));
  api.get('/sessions/:id', handle((req, res) => res.json(sessions.read(req.params.id))));
  api.get('/sessions/:id/telemetry', handle((req, res) => res.json(sessions.telemetry(req.params.id))));
  api.post('/sessions/:id/commands', handle((req, res) => {
    const body = req.body;
    if (!body || typeof body.cmd !== 'string' || body.cmd.length > 40 || (body.args != null && (typeof body.args !== 'object' || Array.isArray(body.args)))) {
      return res.status(400).json({ error: 'A simulation command and object arguments are required.' });
    }
    const result = sessions.command(req.params.id, body.cmd, body.args || {});
    res.status(result.accepted ? 200 : 409).json({ v: '1', type: 'ack', seq: body.seq, ...result });
  }));
  site.use(express.static(path.resolve(__dirname, '../../../simulator'), { index: 'index.html', dotfiles: 'deny' }));
  return { api, site, close: sessions.close };
}

module.exports = { createDryerSimulator };
