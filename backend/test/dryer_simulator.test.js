'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const express = require('express');
const { DryerModel } = require('../../simulator/dryer-model');
const { createDryerSessions } = require('../src/simulation/dryerSessions');
const { createDryerSimulator } = require('../src/routes/dryerSimulatorRoutes');

function loadedModel({ sunlight = 850, crop = 'mango', count = 1 } = {}) {
  const model = new DryerModel();
  model.command('environment', { sunlight, ambientC: 28, ambientRh: 55, speed: 300 });
  model.command('door', { open: true });
  for (let id = 1; id <= count; id++) {
    assert.equal(model.command('pull_tray', { trayId: id }).accepted, true);
    assert.equal(model.command('load_tray', { trayId: id, crop, massKg: .3 }).accepted, true);
    assert.equal(model.command('insert_tray', { trayId: id }).accepted, true);
  }
  model.command('door', { open: false });
  return model;
}

test('reference cabinet has six trays and enforces loading and door interlocks', () => {
  const m = new DryerModel();
  assert.equal(m.snapshot().trays.length, 6);
  assert.equal(m.command('start').accepted, false);
  assert.equal(m.command('pull_tray', { trayId: 1 }).accepted, false);
  m.command('door', { open: true });
  assert.equal(m.command('load_tray', { trayId: 1, crop: 'mango', massKg: .3 }).accepted, false);
  m.command('pull_tray', { trayId: 1 });
  assert.equal(m.command('door', { open: false }).accepted, false);
  assert.equal(m.command('load_tray', { trayId: 1, crop: 'mango', massKg: -1 }).accepted, false);
  assert.equal(m.command('load_tray', { trayId: 1, crop: 'mango', massKg: .3 }).accepted, true);
  assert.equal(m.command('start').accepted, false);
  m.command('insert_tray', { trayId: 1 });
  m.command('door', { open: false });
  assert.equal(m.command('start').accepted, true);
});

test('opening the door pauses the fan and evaporation until explicitly restarted', () => {
  const m = loadedModel();
  m.command('start');
  for (let i = 0; i < 10; i++) m.advance(1);
  assert.ok(m.snapshot().waterRemovedKg > 0);
  m.command('door', { open: true });
  const before = m.snapshot();
  m.advance(1);
  const after = m.snapshot();
  assert.equal(after.state, 'paused');
  assert.equal(after.fanOn, false);
  assert.equal(after.airflow, 0);
  assert.equal(after.waterRemovedKg, before.waterRemovedKg);
  assert.equal(after.evapKgPerHour, 0);
  m.command('door', { open: false });
  assert.equal(m.snapshot().state, 'paused');
});

test('sunlight increases temperature and water removal; night supplies no solar energy', () => {
  const day = loadedModel({ sunlight: 1000 });
  const night = loadedModel({ sunlight: 0 });
  day.command('start'); night.command('start');
  for (let i = 0; i < 20; i++) { day.advance(1); night.advance(1); }
  assert.ok(day.snapshot().chamberC > night.snapshot().chamberC);
  assert.ok(day.snapshot().waterRemovedKg > 0);
  assert.equal(night.snapshot().waterRemovedKg, 0);
});

test('mass is conserved, water never becomes negative and target is not overshot', () => {
  const m = loadedModel({ count: 6 });
  m.command('start');
  for (let i = 0; i < 1000 && m.snapshot().state === 'running'; i++) {
    m.advance(1);
    for (const tray of m.trays) {
      assert.ok(tray.waterKg >= 0);
      assert.ok(Math.abs(tray.dryKg + tray.waterKg + tray.evaporatedKg - tray.initialKg) < 1e-9);
    }
  }
  const s = m.snapshot();
  assert.equal(s.state, 'completed');
  assert.ok(Math.abs(s.initialMassKg - s.currentMassKg - s.waterRemovedKg) <= .0002);
  assert.equal(s.moisturePct, 15);
  assert.equal(s.progress, 1);
});

test('tray removal and reinsertion preserve the fruit; unloading clears only that tray', () => {
  const m = loadedModel({ count: 2 });
  m.command('start'); m.advance(1); m.command('door', { open: true });
  const other = structuredClone(m.trays[1]);
  const mass = m.snapshot().trays[0].massKg;
  m.command('pull_tray', { trayId: 1 });
  assert.equal(m.snapshot().trays[0].massKg, mass);
  assert.equal(m.command('unload_tray', { trayId: 1 }).accepted, true);
  assert.equal(m.snapshot().trays[0].loaded, false);
  assert.deepEqual(m.trays[1], other);
});

test('pairing delivers the same state and model values to browser and app', () => {
  let now = 10000;
  const sessions = createDryerSessions({ now: () => now, tickAutomatically: false });
  const browser = sessions.create();
  assert.match(browser.pairingCode, /^\d{6}$/);
  const phone = sessions.pair(browser.pairingCode);
  assert.equal(phone.sessionId, browser.sessionId);
  sessions.command(browser.sessionId, 'door', { open: true });
  sessions.command(browser.sessionId, 'pull_tray', { trayId: 2 });
  sessions.command(browser.sessionId, 'load_tray', { trayId: 2, crop: 'tomato', massKg: .5 });
  const state = sessions.read(browser.sessionId);
  const telemetry = sessions.telemetry(phone.sessionId);
  assert.equal(telemetry.simulated, true);
  assert.equal(telemetry.source, 'html_simulator');
  assert.deepEqual(telemetry.data.simulation.trays, state.trays);
  assert.equal(telemetry.data.simulation.doorOpen, true);
  assert.equal(telemetry.data.simulation.trays[1].cropName, 'Tomato');
  now += 3600000;
  sessions.tick();
  assert.throws(() => sessions.read(browser.sessionId), { status: 404 });
  assert.throws(() => sessions.pair(browser.pairingCode), { status: 404 });
  sessions.close();
});

test('simulator HTTP endpoints pair and synchronize commands without hardware routes', async () => {
  const sessions = createDryerSessions({ tickAutomatically: false });
  const simulator = createDryerSimulator({ sessions });
  const app = express(); app.use(express.json());
  app.use('/api/dryer-simulator', simulator.api); app.use('/dryer-simulator', simulator.site);
  const server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  const post = (path, body) => fetch(`${base}/api/dryer-simulator${path}`, { method: 'POST',
    headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  try {
    assert.equal((await fetch(`${base}/dryer-simulator/`)).status, 200);
    const session = await (await post('/sessions', {})).json();
    assert.equal((await post('/pair', { code: 'bad' })).status, 400);
    const paired = await (await post('/pair', { code: session.pairingCode })).json();
    assert.equal(paired.sessionId, session.sessionId);
    const denied = await post(`/sessions/${session.sessionId}/commands`, { cmd: 'start', seq: 1 });
    assert.equal(denied.status, 409);
    assert.equal((await denied.json()).accepted, false);
    await post(`/sessions/${session.sessionId}/commands`, { cmd: 'door', args: { open: true }, seq: 2 });
    const reading = await (await fetch(`${base}/api/dryer-simulator/sessions/${session.sessionId}/telemetry`)).json();
    assert.equal(reading.data.simulation.doorOpen, true);
    assert.equal((await fetch(`${base}/api/dryer-simulator/sessions/not-a-session/telemetry`)).status, 404);
  } finally {
    simulator.close();
    await new Promise((resolve) => server.close(resolve));
  }
});
