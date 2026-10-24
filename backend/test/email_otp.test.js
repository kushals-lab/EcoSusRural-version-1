'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createEmailOtpService } = require('../src/services/emailOtp');
const { assertMailConfigured } = require('../src/services/mailDelivery');
const { memoryCollection } = require('./helpers/memoryCollection');

function fixture(overrides = {}) {
  const records = memoryCollection();
  const messages = [];
  let time = Date.UTC(2026, 9, 25);
  const service = createEmailOtpService({
    getCollection: async (name) => { assert.equal(name, 'email_otps'); return records; },
    checkMail: () => {},
    now: () => new Date(time),
    generateOtp: () => '583194',
    getSecret: () => Buffer.alloc(32, 37),
    sendEmail: async (email, otp) => { messages.push({ email, otp }); },
    ...overrides,
  });
  return { service, records, messages, advance: (seconds) => { time += seconds * 1000; } };
}

test('email OTP stores a hash and expiry, and returns no code to the client', async () => {
  const { service, records, messages } = fixture();
  const response = await service.generateAndSendOtp(' Farmer@Example.org ');
  assert.equal(response.success, true);
  assert.equal(response.expiresInSeconds, 300);
  assert.equal(JSON.stringify(response).includes(messages[0].otp), false);
  const record = records.documents.get('farmer@example.org');
  assert.equal(JSON.stringify(record).includes(messages[0].otp), false);
  assert.equal(record.hash.length, 64);
  assert.equal(record.status, 'sent');
  assert.equal(record.expiresAt - record.createdAt, 300000);
  assert.deepEqual(records.indexes, [[{ expiresAt: 1 }, { expireAfterSeconds: 0 }]]);
});

test('concurrent send requests reserve only one email and enforce cooldown', async () => {
  const { service, messages } = fixture();
  const results = await Promise.all(Array.from({ length: 8 }, () => service.generateAndSendOtp('farmer@example.org')));
  assert.equal(results.filter((result) => result.success).length, 1);
  assert.equal(messages.length, 1);
  assert.ok(results.filter((result) => !result.success).every((result) => result.cooldownSeconds === 60));
});

test('a resend invalidates the previous code', async () => {
  let sequence = 0;
  const f = fixture({ generateOtp: () => ['583194', '725093'][sequence++] });
  await f.service.generateAndSendOtp('farmer@example.org');
  f.advance(61);
  await f.service.generateAndSendOtp('farmer@example.org');
  assert.equal((await f.service.verifyOtp('farmer@example.org', '583194')).reason, 'INVALID_OTP');
  assert.equal((await f.service.verifyOtp('farmer@example.org', '725093')).success, true);
});

test('an expired code is rejected before MongoDB TTL cleanup runs', async () => {
  const f = fixture();
  await f.service.generateAndSendOtp('farmer@example.org');
  f.advance(300);
  assert.equal((await f.service.verifyOtp('farmer@example.org', '583194')).reason, 'NOT_FOUND_OR_EXPIRED');
});

test('three wrong codes lock the challenge, including for the correct code', async () => {
  const { service } = fixture();
  await service.generateAndSendOtp('farmer@example.org');
  for (const remaining of [2, 1, 0]) {
    assert.equal((await service.verifyOtp('farmer@example.org', '000000')).remainingAttempts, remaining);
  }
  assert.equal((await service.verifyOtp('farmer@example.org', '583194')).reason, 'MAX_ATTEMPTS_EXCEEDED');
});

test('only one concurrent verification succeeds and consumed codes cannot replay', async () => {
  const { service, records } = fixture();
  await service.generateAndSendOtp('farmer@example.org');
  const results = await Promise.all(Array.from({ length: 8 }, () => service.verifyOtp('farmer@example.org', '583194')));
  assert.equal(results.filter((result) => result.success).length, 1);
  assert.equal((await service.verifyOtp('farmer@example.org', '583194')).success, false);
  assert.equal(records.documents.get('farmer@example.org').hash, undefined);
});

test('SMTP failure removes its challenge and permits a retry', async () => {
  let failing = true;
  const f = fixture({ sendEmail: async () => { if (failing) throw new Error('mail unavailable'); } });
  await assert.rejects(f.service.generateAndSendOtp('farmer@example.org'));
  assert.equal(f.records.documents.size, 0);
  assert.equal((await f.service.verifyOtp('farmer@example.org', '583194')).success, false);
  failing = false;
  assert.equal((await f.service.generateAndSendOtp('farmer@example.org')).success, true);
});

test('missing mail configuration fails before saving any OTP', async () => {
  const original = process.env.SMTP_PASS;
  try {
    delete process.env.SMTP_PASS;
    const f = fixture({ checkMail: assertMailConfigured });
    await assert.rejects(f.service.generateAndSendOtp('farmer@example.org'), { code: 'MAIL_NOT_CONFIGURED' });
    assert.equal(f.records.documents.size, 0);
  } finally {
    if (original === undefined) delete process.env.SMTP_PASS;
    else process.env.SMTP_PASS = original;
  }
});
