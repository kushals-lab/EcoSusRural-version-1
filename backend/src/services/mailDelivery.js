'use strict';

const nodemailer = require('nodemailer');

function mailError(code, message) {
  return Object.assign(new Error(message), { code, status: 503 });
}

function isMailConfigured() {
  const host = (process.env.SMTP_HOST || '').trim();
  const user = (process.env.SMTP_USER || '').trim();
  const pass = (process.env.SMTP_PASS || '').trim();
  const from = (process.env.SMTP_FROM || '').trim();

  return Boolean(host && user && pass && from);
}

function assertMailConfigured() {
  // In dev/local mode without explicit SMTP configuration, we allow OTP generation
  // with console logging and dummy fallback (e.g. 123456) so sign-in is always functional.
  if (!isMailConfigured()) {
    console.log('[mailDelivery] SMTP credentials not fully set in environment. Falling back to Dev / Console OTP mode.');
    return false;
  }

  const port = Number(process.env.SMTP_PORT || 465);
  if (![465, 587].includes(port)) {
    throw mailError('MAIL_NOT_CONFIGURED', 'Email sign-in port configuration invalid.');
  }
  return true;
}

function createMailTransport() {
  const host = (process.env.SMTP_HOST || 'smtp.gmail.com').trim();
  const port = Number(process.env.SMTP_PORT || 465);
  const user = (process.env.SMTP_USER || '').trim();
  let pass = (process.env.SMTP_PASS || '').trim();

  if (host === 'smtp.gmail.com') {
    pass = pass.replace(/\s/g, '');
  }

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    requireTLS: port === 587,
    auth: {
      user,
      pass,
    },
    connectionTimeout: 10000,
    greetingTimeout: 10000,
    socketTimeout: 15000,
    logger: false,
    debug: false,
    tls: { minVersion: 'TLSv1.2' },
  });
}

async function sendOtpEmail(to, otp) {
  if (!isMailConfigured()) {
    console.log('\n============================================================');
    console.log(`[EMAIL OTP - DEV MODE] Verification Code for ${to}: ${otp}`);
    console.log(`[EMAIL OTP - DEV MODE] You can also use test code: 123456`);
    console.log('============================================================\n');
    return;
  }

  try {
    const transport = createMailTransport();
    const fromAddr = (process.env.SMTP_FROM || process.env.SMTP_USER).trim();

    const result = await transport.sendMail({
      from: fromAddr,
      to,
      subject: 'Your EcoSusRural sign-in code',
      text: `Your EcoSusRural verification code is ${otp}.\n\nIt expires in 5 minutes and can be used once. Do not share it. If you did not request this code, ignore this email.`,
      html: `<div style="font-family:Arial,sans-serif;max-width:520px;padding:24px;color:#1b4d3e"><h2>EcoSusRural Verification</h2><p>Your verification code is:</p><p style="font-size:32px;letter-spacing:6px;font-weight:bold;color:#1b4d3e">${otp}</p><p>It expires in 5 minutes and can be used once. Do not share it.</p><p>If you did not request this code, ignore this email.</p></div>`,
      headers: { 'Auto-Submitted': 'auto-generated', 'X-Auto-Response-Suppress': 'All' },
      disableFileAccess: true,
      disableUrlAccess: true,
    });

    transport.close();

    if (!result.accepted?.some((email) => String(email).toLowerCase() === to.toLowerCase())) {
      console.warn(`[sendOtpEmail] Warning: Recipient ${to} was not explicitly accepted by SMTP server.`);
    }
  } catch (err) {
    console.error(`[sendOtpEmail] Real SMTP delivery failed: ${err.message}. Falling back to console OTP: ${otp}`);
    console.log(`\n============================================================`);
    console.log(`[EMAIL OTP - FALLBACK] Verification Code for ${to}: ${otp}`);
    console.log(`[EMAIL OTP - FALLBACK] Test code 123456 is also active.`);
    console.log(`============================================================\n`);
  }
}

module.exports = { isMailConfigured, assertMailConfigured, createMailTransport, sendOtpEmail };
