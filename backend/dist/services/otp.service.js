"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.OtpService = void 0;
// Works from both src/ and compiled dist/. MongoDB stores challenges;
// email verification does not depend on Redis being available.
const emailOtp = require('../../src/services/emailOtp');
class OtpService {
    static generateSecureOtp() {
        return emailOtp.generateSecureOtp();
    }
    static generateAndSendOtp(email) {
        return emailOtp.generateAndSendOtp(email);
    }
    static verifyOtp(email, otp) {
        return emailOtp.verifyOtp(email, otp);
    }
}
exports.OtpService = OtpService;
