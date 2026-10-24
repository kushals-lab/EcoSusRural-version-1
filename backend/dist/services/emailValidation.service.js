"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmailValidationService = void 0;
const promises_1 = __importDefault(require("dns/promises"));
class EmailValidationService {
    /**
     * RFC 5322 compliant regex with length constraints:
     * Total length <= 254 chars, local-part <= 64 chars, domain labels <= 63 chars.
     */
    static EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;
    /**
     * Comprehensive disposable and temporary email domains list.
     * Can be extended or loaded into memory from a curated feed.
     */
    static DISPOSABLE_DOMAINS = new Set([
        'mailinator.com',
        'guerrillamail.com',
        'guerrillamailblock.com',
        'guerrillamail.net',
        'guerrillamail.org',
        'sharklasers.com',
        'grr.la',
        'pokemail.net',
        'spam4.me',
        'tempmail.com',
        'temp-mail.org',
        '10minutemail.com',
        '10minutemail.net',
        'yopmail.com',
        'yopmail.fr',
        'yopmail.net',
        'throwawaymail.com',
        'trashmail.com',
        'trashmail.net',
        'trashmail.me',
        'dispostable.com',
        'maildrop.cc',
        'inboxkitten.com',
        'getairmail.com',
        'mytemp.email',
        'fakemailgenerator.com',
        'emailondeck.com',
        'mohmal.com',
        'burnermail.io',
        'crazymailing.com',
        'nada.ltd',
        'getnada.com',
        'dropmail.me',
        'generator.email',
        'armyspy.com',
        'cuvox.de',
        'dayrep.com',
        'fleckens.hu',
        'gustr.com',
        'jourrapide.com',
        'rhyta.com',
        'superrito.com',
        'teleworm.us',
    ]);
    /**
     * Validates syntax, disposable blocklist, and performs real DNS MX record resolution.
     */
    static async validateEmail(email) {
        if (!email || typeof email !== 'string') {
            return {
                isValid: false,
                error: 'Email address must be a valid non-empty string.',
                code: 'INVALID_SYNTAX',
            };
        }
        const trimmed = email.trim();
        // Enforce overall length constraints
        if (trimmed.length < 5 || trimmed.length > 254) {
            return {
                isValid: false,
                error: 'Email address length violates RFC standards (max 254 characters).',
                code: 'INVALID_SYNTAX',
            };
        }
        // Syntax validation
        if (!this.EMAIL_REGEX.test(trimmed)) {
            return {
                isValid: false,
                error: 'Email format does not adhere to standard syntax requirements.',
                code: 'INVALID_SYNTAX',
            };
        }
        const [localPart, domainPart] = trimmed.split('@');
        if (localPart.length > 64) {
            return {
                isValid: false,
                error: 'Email local-part exceeds maximum limit of 64 characters.',
                code: 'INVALID_SYNTAX',
            };
        }
        const normalizedDomain = domainPart.toLowerCase();
        const normalizedEmail = `${localPart.toLowerCase()}@${normalizedDomain}`;
        // Disposable Domain Check (both exact match and wildcard/subdomain matching)
        if (this.isDisposableDomain(normalizedDomain)) {
            return {
                isValid: false,
                error: 'Disposable and throwaway email addresses are not permitted.',
                code: 'DISPOSABLE_DOMAIN',
            };
        }
        // Real DNS MX Record Lookup
        const mxValid = await this.verifyMxRecords(normalizedDomain);
        if (!mxValid.hasRecords) {
            return {
                isValid: false,
                error: mxValid.error || 'The domain does not have active mail servers configured to receive emails.',
                code: mxValid.code || 'NO_MX_RECORDS',
            };
        }
        return {
            isValid: true,
            normalizedEmail,
        };
    }
    /**
     * Recursively checks if the domain or any of its parent domains match the disposable list.
     */
    static isDisposableDomain(domain) {
        if (this.DISPOSABLE_DOMAINS.has(domain)) {
            return true;
        }
        const parts = domain.split('.');
        while (parts.length > 2) {
            parts.shift();
            const parentDomain = parts.join('.');
            if (this.DISPOSABLE_DOMAINS.has(parentDomain)) {
                return true;
            }
        }
        return false;
    }
    /**
     * Resolves MX records using Node.js dns.promises with timeout protection.
     * Handles RFC 7505 "Null MX" detection.
     */
    static async verifyMxRecords(domain) {
        const DNS_TIMEOUT_MS = 3500;
        try {
            const recordsPromise = promises_1.default.resolveMx(domain);
            const timeoutPromise = new Promise((_, reject) => {
                setTimeout(() => reject(new Error('DNS_TIMEOUT')), DNS_TIMEOUT_MS);
            });
            const records = await Promise.race([recordsPromise, timeoutPromise]);
            if (!records || records.length === 0) {
                return {
                    hasRecords: false,
                    error: `No MX records found for domain "${domain}".`,
                    code: 'NO_MX_RECORDS',
                };
            }
            // Check RFC 7505 Null MX record (priority 0 and exchange "." or empty string)
            const hasValidExchange = records.some((record) => {
                const exchange = record.exchange ? record.exchange.trim() : '';
                return exchange !== '' && exchange !== '.';
            });
            if (!hasValidExchange) {
                return {
                    hasRecords: false,
                    error: `Domain "${domain}" declares an RFC 7505 Null MX record and explicitly rejects all incoming mail.`,
                    code: 'NO_MX_RECORDS',
                };
            }
            return { hasRecords: true };
        }
        catch (err) {
            if (err.message === 'DNS_TIMEOUT') {
                return {
                    hasRecords: false,
                    error: `DNS MX lookup timed out for domain "${domain}".`,
                    code: 'DNS_LOOKUP_TIMEOUT',
                };
            }
            // Standard Node.js DNS error codes: ENOTFOUND, ENODATA, ESERVFAIL, EREFUSED
            return {
                hasRecords: false,
                error: `Domain "${domain}" does not exist or has no verifiable mail servers (DNS error: ${err.code || 'UNKNOWN'}).`,
                code: 'NO_MX_RECORDS',
            };
        }
    }
}
exports.EmailValidationService = EmailValidationService;
