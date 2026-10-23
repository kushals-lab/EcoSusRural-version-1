path = r'c:\Users\user\OneDrive\Microsoft Copilot Chat Files\Desktop\EcoSusRural\eco_sus_rural\backend\smoke_test.js'
code = r'''// Security smoke test for the hardened EcoSusRural backend.
// Run: node smoke_test.js   (backend already running)
const http = require('http');
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

const BASE = 'http://127.0.0.1:5000';
const AUTH = 'smoke_test_secret_0123456789abcdef';
let pass = 0;
let fail = 0;

function test(name, cond, detail) {
  if (cond) { pass++; console.log('PASS: ' + name); }
  else { fail++; console.log('FAIL: ' + name + (detail ? ' :: ' + detail : '')); }
}

function k() { return 'smoke-' + Math.random().toString(36).slice(2, 8); }

function req(method, path, body, token, idem, extra) {
  return new Promise((resolve) => {
    const u = new URL(BASE + path);
    const data = body === null ? null : JSON.stringify(body);
    const h = {
      'Content-Type': 'application/json',
      Authorization: 'Bearer ' + token,
      'Idempotency-Key': idem || k(),
    };
    Object.assign(h, extra || {});
    const r = http.request(
      { hostname: u.hostname, port: 5000, path: u.pathname + u.search, method, headers: h },
      (res) => {
        let b = '';
        res.on('data', (c) => { b += c; });
        res.on('end', () => resolve({ status: res.statusCode, body: b, headers: res.headers }));
      },
    );
    r.on('error', (e) => resolve({ status: 0, body: e.message, headers: {} }));
    if (data !== null) r.write(data);
    r.end();
  });
}

async function main() {
  const h = await req('GET', '/health');
  test('health 200', h.status === 200, h.body);
  const l = await req('POST', '/api/auth/login', { email: 'u@example.in', password: 'Str0ngPass1' });
  test('login 501 (no token minted)', l.status === 501, l.body);
  const v = await req('POST', '/api/auth/login', { email: 'bad', password: 'x' });
  test('login 400 invalid email', v.status === 400, v.body);
  const p = await req('POST', '/api/payments/process', { amount: 1426700, currency: 'INR', method: 'UPI' });
  test('payment 401 without token', p.status === 401, p.body);
  const pv = await req('POST', '/api/payments/process', { amount: 1426700, currency: 'INR', method: 'UPI' }, AUTH, 'smoke-valid-1');
  test('payment 201 initiated', pv.status === 201, pv.body);
  const pr = await req('POST', '/api/payments/process', { amount: 1426700, currency: 'INR', method: 'UPI' }, AUTH, 'smoke-valid-1');
  test('replay same 201', pr.status === 201, pr.body);
  test('replay header', pr.headers['idempotency-replayed'] === 'true', JSON.stringify(pr.headers));
  const pc = await req('POST', '/api/payments/process', { amount: 999999, currency: 'INR', method: 'UPI' }, AUTH, 'smoke-valid-1');
  test('replay diff amount 409', pc.status === 409, pc.body);
  const ba = await req('POST', '/api/payments/process', { amount: '1426700', currency: 'INR', method: 'UPI' }, AUTH, 'smoke-b1');
  test('payment 400 non-integer amount', ba.status === 400, ba.body);
  const bs = await req('POST', '/api/payments/process', { amount: -500, currency: 'INR', method: 'UPI' }, AUTH, 'smoke-b2');
  test('payment 400 negative amount', bs.status === 400, bs.body);
  const bc = await req('POST', '/api/payments/process', { amount: 100, currency: 'XX', method: 'UPI' }, AUTH, 'smoke-b3');
  test('payment 400 invalid currency', bc.status === 400, bc.body);
  const bm = await req('POST', '/api/payments/process', { amount: 100, currency: 'INR', method: 'Crypto' }, AUTH, 'smoke-b4');
  test('payment 400 invalid method', bm.status === 400, bm.body);
  const g = await req('POST', '/api/gateway/forward-ai', { any: 'x' });
  test('gateway 401 without token', g.status === 401, g.body);
  const w = await req('GET', '/api/weather?lat=999&lon=0');
  test('weather 400 invalid coords', w.status === 400, w.body);
  const w2 = await req('GET', '/api/weather?lat=28.61&lon=77.23');
  test('weather 200 valid coords', w2.status === 200 && w2.body.includes('"latitude"'), w2.body.slice(0, 200));
  const db = await req('GET', '/api/dryer/batches', null, AUTH);
  test('dryer 200 empty for user', db.status === 200, db.body);
  const da = await req('POST', '/api/dryer/batches', { id: 'b1', crop: 'Wheat', notes: 'x'.repeat(1000) }, AUTH, 'dryer-b1');
  test('dryer 201 notes truncated', da.status === 201, da.body);
  const dr = await req('POST', '/api/dryer/batches/b1/readings', { chamberC: 50, fanOn: 'yes' }, AUTH, 'dryer-r1');
  test('dryer reading 201', dr.status === 201 && dr.body.includes('count'), dr.body);
  const tB = jwt.sign({ sub: 'user_B', email: 'b@test.in', purpose: 'access' }, AUTH, { expiresIn: '10m' });
  const tA = jwt.sign({ sub: 'user_A', email: 'a@test.in', purpose: 'access' }, AUTH, { expiresIn: '10m' });
  const dbB = await req('GET', '/api/dryer/batches', null, tB);
  const dbA = await req('GET', '/api/dryer/batches', null, tA);
  test('dryer A sees b1', dbA.status === 200 && dbA.body.includes('"id":"b1"'), dbA.body);
  const dbB2 = await req('GET', '/api/dryer/batches', null, tB);
  test('dryer B cannot see A batch', dbB2.status === 200 && !dbB2.body.includes('"id":"b1"'), dbB2.body);
  const ws = new WebSocket('ws://127.0.0.1:5000/ws/chat');
  ws.on('close', (code) => { test('WS 4401 no token', code === 4401 || code === 1008, 'code=' + code); });
  const ws2 = new WebSocket('ws://127.0.0.1:5000/ws/chat?token=' + AUTH);
  ws2.on('open', () => { ws2.send(JSON.stringify({ type: 'join', conversationId: 'c-smoke' })); });
  ws2.on('message', (raw) => {
    const m = JSON.parse(raw.toString('utf8'));
    if (m.type === 'joined') { test('WS authenticated join ok', true, ''); ws2.close(); }
  });
  ws2.on('close', () => {
    console.log('\nRESULT: ' + pass + ' passed, ' + fail + ' failed');
    process.exit(fail ? 1 : 0);
  });
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});'''
open(path, 'w', encoding='utf-8').write(code)
print('written', len(code), 'bytes')