'use strict';

const nodemailer = require('nodemailer');

function mailError(code, message) {
  return Object.assign(new Error(message), { code, status: 503 });
}

function assertMailConfigured() {
  const required = ['SMTP_HOST', 'SMTP_USER', 'SMTP_PASS', 'SMTP_FROM'];
  if (required.some((name) => !process.env[name]?.trim())) {
    throw mailError('MAIL_NOT_CONFIGURED', 'Email sign-in is temporarily unavailable.');
  }
  if (![465, 587].includes(Number(process.env.SMTP_PORT || 465))) {
    throw mailError('MAIL_NOT_CONFIGURED', 'Email sign-in is temporarily unavailable.');
  }
}

function createMailTransport() {
  assertMailConfigured();
  const port = Number(process.env.SMTP_PORT || 465);
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST.trim(), port, secure: port === 465, requireTLS: port === 587,
    auth: {
      user: process.env.SMTP_USER.trim(),
      pass: process.env.SMTP_HOST.trim() === 'smtp.gmail.com'
        ? process.env.SMTP_PASS.replace(/\s/g, '') : process.env.SMTP_PASS,
    },
    connectionTimeout: 10000, greetingTimeout: 10000, socketTimeout: 15000,
    logger: false, debug: false, tls: { minVersion: 'TLSv1.2' },
  });
}

async function sendOtpEmail(to, otp) {
  const transport = createMailTransport();
  try {
    const result = await transport.sendMail({
      from: process.env.SMTP_FROM, to, subject: 'Your EcoSusRural sign-in code',
      text: `Your EcoSusRural verification code is ${otp}.\n\nIt expires in 5 minutes and can be used once. Do not share it. If you did not request this code, ignore this email.`,
      html: `<div style="font-family:Arial,sans-serif;max-width:520px;padding:24px;color:#1b4d3e"><h2>EcoSusRural verification</h2><p>Your verification code is:</p><p style="font-size:32px;letter-spacing:6px;font-weight:bold">${otp}</p><p>It expires in 5 minutes and can be used once. Do not share it.</p><p>If you did not request this code, ignore this email.</p></div>`,
      headers: { 'Auto-Submitted': 'auto-generated', 'X-Auto-Response-Suppress': 'All' },
      disableFileAccess: true, disableUrlAccess: true,
    });
    if (!result.accepted?.some((email) => String(email).toLowerCase() === to.toLowerCase())) {
      throw new Error('Recipient not accepted');
    }
  } catch (_) {
    // SMTP errors can contain addresses or credentials. Do not return or log them.
    throw mailError('MAIL_DELIVERY_UNAVAILABLE', 'The email could not be sent. Please try again later.');
  } finally { transport.close(); }
}

module.exports = { assertMailConfigured, createMailTransport, sendOtpEmail };
