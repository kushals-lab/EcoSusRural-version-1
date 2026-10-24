// Send a real OTP using server-side configuration. Never prints the code or secrets.
'use strict';

const path = require('node:path');
require('../backend/node_modules/dotenv').config({ path: path.join(__dirname, '../backend/.env.local') });
require('../backend/node_modules/dotenv').config({ path: path.join(__dirname, '../backend/.env') });
const { EmailValidationService } = require('../backend/dist/services/emailValidation.service');
const { generateAndSendOtp } = require('../backend/src/services/emailOtp');
const { closeMongo } = require('../backend/src/db/mongodb');

(async () => {
  const result = await EmailValidationService.validateEmail(process.argv[2]);
  if (!result.isValid) {
    console.log(`OTP not sent: ${result.code || 'INVALID_EMAIL'}`);
    process.exitCode = 1;
    return;
  }
  const sent = await generateAndSendOtp(result.normalizedEmail);
  if (!sent.success) {
    console.log(`OTP not sent: wait ${sent.cooldownSeconds} seconds before retrying.`);
    process.exitCode = 1;
    return;
  }
  console.log('SMTP provider accepted the OTP email. Check the recipient inbox and spam folder.');
  console.log('The code expires in 5 minutes. It is never printed in terminal output.');
})().catch((error) => {
  const allowedCodes = ['MAIL_NOT_CONFIGURED', 'MAIL_DELIVERY_UNAVAILABLE'];
  console.log(`OTP not sent: ${allowedCodes.includes(error.code) ? error.code : 'SERVICE_UNAVAILABLE'}`);
  process.exitCode = 1;
}).finally(closeMongo);
