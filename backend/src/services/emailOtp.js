'use strict';

const crypto = require('node:crypto');
const jwt = require('jsonwebtoken');
const mongo = require('../db/mongodb');
const mail = require('./mailDelivery');
const { jwtSecret } = require('../security/secrets');

const TTL_SECONDS = 300;
const COOLDOWN_SECONDS = 60;
const MAX_ATTEMPTS = 3;
const generateSecureOtp = () => crypto.randomInt(100000, 1000000).toString();

function createEmailOtpService({
  getCollection = mongo.getCollection, checkMail = mail.assertMailConfigured,
  sendEmail = mail.sendOtpEmail, now = () => new Date(), generateOtp = generateSecureOtp,
  getSecret = () => crypto.createHmac('sha256', jwtSecret()).update('EcoSusRural/email-otp/v1').digest(),
} = {}) {
  let indexes;
  async function collection() {
    const records = await getCollection('email_otps');
    if (!indexes) {
      indexes = records.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 })
        .catch((error) => { indexes = undefined; throw error; });
    }
    await indexes;
    return records;
  }
  function hash(email, otp, salt) {
    return crypto.createHmac('sha256', getSecret()).update(`${email}:${otp}:${salt}`).digest('hex');
  }
  const expired = () => ({ success: false, reason: 'NOT_FOUND_OR_EXPIRED',
    message: 'The code has expired or was already used. Request a new code.' });

  async function generateAndSendOtp(email) {
    checkMail(); // Missing SMTP must not create a challenge or pretend to send mail.
    email = email.trim().toLowerCase();
    const records = await collection();
    const at = now();
    const otp = generateOtp();
    const salt = crypto.randomBytes(16).toString('hex');
    const challengeId = crypto.randomUUID();
    const record = { challengeId, hash: hash(email, otp, salt), salt, attempts: 0,
      status: 'pending', createdAt: at, expiresAt: new Date(at.getTime() + TTL_SECONDS * 1000),
      cooldownUntil: new Date(at.getTime() + COOLDOWN_SECONDS * 1000) };
    try {
      await records.findOneAndUpdate({ _id: email, cooldownUntil: { $lte: at } },
        { $set: record }, { upsert: true, returnDocument: 'after', includeResultMetadata: false });
    } catch (error) {
      if (error.code !== 11000) throw error;
      const existing = await records.findOne({ _id: email });
      const remaining = Math.max(1, Math.ceil(((existing?.cooldownUntil?.getTime() || at.getTime()) - at.getTime()) / 1000));
      return { success: false, message: 'Please wait before requesting another code.', cooldownSeconds: remaining };
    }
    try {
      await sendEmail(email, otp);
      await records.updateOne({ _id: email, challengeId, status: 'pending' }, { $set: { status: 'sent' } });
    } catch (error) {
      await records.deleteOne({ _id: email, challengeId, status: 'pending' });
      throw error;
    }
    return { success: true, message: 'A verification code has been sent to your email.',
      cooldownSeconds: COOLDOWN_SECONDS, expiresInSeconds: TTL_SECONDS };
  }

  async function verifyOtp(email, otp) {
    email = email.trim().toLowerCase();
    const records = await collection();
    const record = await records.findOne({ _id: email });
    const at = now();
    if (!record || record.expiresAt <= at || record.status !== 'sent') return expired();
    if (record.attempts >= MAX_ATTEMPTS) return { success: false, reason: 'MAX_ATTEMPTS_EXCEEDED',
      message: 'Too many incorrect attempts. Request a new code.', remainingAttempts: 0 };
    const candidate = hash(email, otp, record.salt);
    const valid = crypto.timingSafeEqual(Buffer.from(candidate, 'hex'), Buffer.from(record.hash, 'hex'));
    const eligible = { _id: email, challengeId: record.challengeId, status: 'sent',
      attempts: { $lt: MAX_ATTEMPTS }, expiresAt: { $gt: at } };
    if (!valid) {
      const updated = await records.findOneAndUpdate(eligible, { $inc: { attempts: 1 } },
        { returnDocument: 'after', includeResultMetadata: false });
      if (!updated) return expired();
      const remaining = Math.max(0, MAX_ATTEMPTS - updated.attempts);
      return { success: false, reason: remaining ? 'INVALID_OTP' : 'MAX_ATTEMPTS_EXCEEDED',
        message: remaining ? 'Incorrect code. Please try again.' : 'Too many incorrect attempts. Request a new code.',
        remainingAttempts: remaining };
    }
    const consumed = await records.findOneAndUpdate({ ...eligible, hash: candidate },
      { $set: { status: 'consumed' }, $unset: { hash: '', salt: '' } },
      { returnDocument: 'after', includeResultMetadata: false });
    if (!consumed) return expired();
    const verificationToken = jwt.sign({ email, purpose: 'email_verification', verifiedAt: at.getTime() },
      jwtSecret(), { expiresIn: '15m' });
    return { success: true, message: 'Email address verified.', verificationToken };
  }
  return { generateAndSendOtp, verifyOtp };
}

module.exports = { ...createEmailOtpService(), createEmailOtpService, generateSecureOtp };
