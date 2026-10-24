'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const express = require('express');
const mongo = require('../src/db/mongodb');
const { memoryCollection } = require('./helpers/memoryCollection');

test('email OTP signs in, restores a Mongo session, and logout revokes it', async () => {
  const originalCollection = mongo.getCollection;
  const users = memoryCollection();
  const challenges = memoryCollection();
  const messages = [];
  let server;
  let originalValidation;
  let originalSend;
  let originalVerify;
  let emailValidation;
  let otpService;
  try {
    mongo.getCollection = async (name) => {
      if (name === 'users') return users;
      if (name === 'email_otps') return challenges;
      throw new Error('Unexpected collection');
    };
    const { createEmailOtpService } = require('../src/services/emailOtp');
    const service = createEmailOtpService({
      getCollection: mongo.getCollection, checkMail: () => {},
      sendEmail: async (email, otp) => messages.push({ email, otp }),
    });
    emailValidation = require('../dist/services/emailValidation.service').EmailValidationService;
    otpService = require('../dist/services/otp.service').OtpService;
    originalValidation = emailValidation.validateEmail;
    originalSend = otpService.generateAndSendOtp;
    originalVerify = otpService.verifyOtp;
    emailValidation.validateEmail = async (email) => ({ isValid: true, normalizedEmail: email.trim().toLowerCase() });
    otpService.generateAndSendOtp = service.generateAndSendOtp;
    otpService.verifyOtp = service.verifyOtp;
    const app = express();
    app.use(express.json());
    app.use('/auth', require('../src/routes/authRoutes'));
    server = app.listen(0, '127.0.0.1');
    await new Promise((resolve) => server.once('listening', resolve));
    const base = `http://127.0.0.1:${server.address().port}/auth`;
    const post = (path, body, token) => fetch(`${base}/${path}`, { method: 'POST',
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: JSON.stringify(body) });
    const email = 'farmer@example.org';
    const sent = await post('send-otp', { email });
    assert.equal(sent.status, 200);
    const sentBody = await sent.json();
    assert.equal(sentBody.success, true);
    assert.equal(JSON.stringify(sentBody).includes(messages[0].otp), false);
    const wrong = await post('verify-otp', { email, otp: '000000' });
    assert.equal(wrong.status, 401);
    assert.equal(users.documents.size, 0);
    const verified = await post('verify-otp', { email, otp: messages[0].otp });
    assert.equal(verified.status, 200);
    const session = await verified.json();
    assert.equal(session.user.role, 'buyer');
    assert.ok(session.user.uid.startsWith('email:'));
    assert.equal(users.documents.size, 1);
    const me = await fetch(`${base}/me`, { headers: { Authorization: `Bearer ${session.accessToken}` } });
    assert.equal(me.status, 200);
    assert.equal((await me.json()).user.email, email);
    const replay = await post('verify-otp', { email, otp: messages[0].otp });
    assert.equal(replay.status, 404);
    assert.equal((await post('logout', {}, session.accessToken)).status, 200);
    assert.equal((await fetch(`${base}/me`, { headers: { Authorization: `Bearer ${session.accessToken}` } })).status, 401);
  } finally {
    if (server) await new Promise((resolve) => server.close(resolve));
    mongo.getCollection = originalCollection;
    if (emailValidation) emailValidation.validateEmail = originalValidation;
    if (otpService) {
      otpService.generateAndSendOtp = originalSend;
      otpService.verifyOtp = originalVerify;
    }
  }
});
