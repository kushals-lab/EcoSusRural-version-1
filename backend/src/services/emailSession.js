'use strict';

const crypto = require('node:crypto');
const jwt = require('jsonwebtoken');
const { getCollection } = require('../db/mongodb');
const { jwtSecret } = require('../security/secrets');

async function createEmailSession(email) {
  email = email.trim().toLowerCase();
  // Stable email identity; existing Google accounts are not automatically merged.
  const id = `email:${crypto.createHash('sha256').update(email).digest('hex')}`;
  const sessionId = crypto.randomUUID();
  const users = await getCollection('users');
  await users.updateOne({ _id: id }, {
    $set: { email, emailVerified: true, activeSessionId: sessionId, lastLoginAt: new Date() },
    $setOnInsert: { id, role: 'buyer', displayName: '', createdAt: new Date() },
  }, { upsert: true });
  const user = await users.findOne({ id }, { projection: { _id: 0, email: 1, displayName: 1, role: 1 } });
  const accessToken = jwt.sign({ sub: id, email, purpose: 'access', provider: 'email_otp', jti: sessionId },
    jwtSecret(), { expiresIn: '7d' });
  return { accessToken, user: { uid: id, email: user.email, name: user.displayName, role: user.role } };
}

module.exports = { createEmailSession };
