'use strict';

const crypto = require('node:crypto');
const { DryerModel } = require('../../../simulator/dryer-model');
const LIFETIME_MS = 60 * 60 * 1000;

function createDryerSessions({ now = Date.now, tickAutomatically = true, maxSessions = 20 } = {}) {
  const sessions = new Map();
  const missing = () => Object.assign(new Error('Simulation expired or not found. Create a new session in the HTML simulator.'), { status: 404 });
  function tick() {
    const at = now();
    for (const [id, session] of sessions) {
      if (at >= session.expiresAt) { sessions.delete(id); continue; }
      session.model.advance(Math.max(0, (at - session.lastTick) / 1000));
      session.lastTick = at;
    }
  }
  const timer = tickAutomatically ? setInterval(tick, 1000) : null;
  timer?.unref();
  function get(id) {
    const session = sessions.get(id);
    if (!session || now() >= session.expiresAt) { sessions.delete(id); throw missing(); }
    return session;
  }
  function snapshot(session) {
    return { sessionId: session.id, pairingCode: session.code, expiresAt: new Date(session.expiresAt).toISOString(),
      lastAppSeenAt: session.lastAppSeenAt ? new Date(session.lastAppSeenAt).toISOString() : null,
      ...session.model.snapshot(), updatedAt: new Date(session.lastTick).toISOString() };
  }
  return {
    create() {
      tick();
      if (sessions.size >= maxSessions) throw Object.assign(new Error('Simulation capacity reached. Try again later.'), { status: 429 });
      let code;
      do { code = String(crypto.randomInt(100000, 1000000)); } while ([...sessions.values()].some((session) => session.code === code));
      const id = crypto.randomBytes(18).toString('base64url');
      const session = { id, code, model: new DryerModel(), lastTick: now(), expiresAt: now() + LIFETIME_MS, lastAppSeenAt: null };
      sessions.set(id, session);
      return snapshot(session);
    },
    pair(code) {
      const session = [...sessions.values()].find((entry) => entry.code === code && now() < entry.expiresAt);
      if (!session) throw missing();
      session.lastAppSeenAt = now();
      return snapshot(session);
    },
    read(id) { return snapshot(get(id)); },
    telemetry(id) {
      const session = get(id);
      session.lastAppSeenAt = now();
      return session.model.telemetry(new Date(session.lastTick).toISOString());
    },
    command(id, cmd, args) {
      const session = get(id);
      const result = session.model.command(cmd, args);
      return { ...result, snapshot: snapshot(session) };
    },
    tick,
    close() { if (timer) clearInterval(timer); sessions.clear(); },
  };
}

module.exports = { createDryerSessions };
