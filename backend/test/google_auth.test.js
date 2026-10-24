'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const express = require('express');
const { OAuth2Client } = require('google-auth-library');
const mongo = require('../src/db/mongodb');

test('verified Google sign-in issues a session and a later login revokes it', async () => {
  const verifyOriginal = OAuth2Client.prototype.verifyIdToken;
  const collectionOriginal = mongo.getCollection;
  const clientIdOriginal = process.env.GOOGLE_WEB_CLIENT_ID;
  const jwtOriginal = process.env.JWT_SECRET;
  const users = new Map();
  let server;
  try {
    process.env.GOOGLE_WEB_CLIENT_ID = 'test-client.apps.googleusercontent.com';
    process.env.JWT_SECRET = 'test-only-jwt-secret-that-is-long-enough-for-signing';
    OAuth2Client.prototype.verifyIdToken = async ({ idToken, audience }) => {
      assert.equal(audience, process.env.GOOGLE_WEB_CLIENT_ID);
      if (idToken !== 'v'.repeat(150)) throw new Error('invalid test token');
      return { getPayload: () => ({ sub: 'account-123', email: 'farmer@example.org', email_verified: true, name: 'Test Farmer' }) };
    };
    mongo.getCollection = async (name) => {
      assert.equal(name, 'users');
      return {
        updateOne: async (filter, update) => {
          const existing = users.get(filter.id);
          if (filter.activeSessionId && existing?.activeSessionId !== filter.activeSessionId) return;
          const next = { ...(existing || update.$setOnInsert || {}), ...(update.$set || {}) };
          if (update.$unset?.activeSessionId !== undefined) delete next.activeSessionId;
          users.set(filter.id, next);
        },
        findOne: async (filter) => users.get(filter.id) || null,
      };
    };
    const app = express();
    app.use(express.json());
    app.use('/auth', require('../src/routes/authRoutes'));
    server = app.listen(0, '127.0.0.1');
    await new Promise((resolve) => server.once('listening', resolve));
    const base = `http://127.0.0.1:${server.address().port}/auth`;
    const login = () => fetch(`${base}/google`, { method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken: 'v'.repeat(150) }) });
    const first = await (await login()).json();
    assert.equal(first.user.uid, 'google:account-123');
    assert.equal(first.user.role, 'buyer');
    const me = (token) => fetch(`${base}/me`, { headers: { Authorization: `Bearer ${token}` } });
    assert.equal((await me(first.accessToken)).status, 200);
    const second = await (await login()).json();
    assert.equal((await me(first.accessToken)).status, 401);
    assert.equal((await me(second.accessToken)).status, 200);
    const logout = await fetch(`${base}/logout`, { method: 'POST', headers: { Authorization: `Bearer ${second.accessToken}` } });
    assert.equal(logout.status, 200);
    assert.equal((await me(second.accessToken)).status, 401);
  } finally {
    if (server) await new Promise((resolve) => server.close(resolve));
    OAuth2Client.prototype.verifyIdToken = verifyOriginal;
    mongo.getCollection = collectionOriginal;
    if (clientIdOriginal === undefined) delete process.env.GOOGLE_WEB_CLIENT_ID;
    else process.env.GOOGLE_WEB_CLIENT_ID = clientIdOriginal;
    if (jwtOriginal === undefined) delete process.env.JWT_SECRET;
    else process.env.JWT_SECRET = jwtOriginal;
  }
});
