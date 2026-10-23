# SECURITY & HARDENING REPORT: EcoSusRural

**Document Version:** 1.0.0  
**Compliance Standards:** OWASP Mobile Application Security, OWASP API Top 10, India DPDPA (Digital Personal Data Protection Act 2023)

---

## 1. Secrets Management & Key Protection
- **Vulnerability Avoided:** Storing production API credentials in client-side Flutter code (which can be reverse-engineered via `apktool` / decompilation).
- **Enforced Architecture:**
  - Gemini API Key and data.gov.in Mandi API keys reside exclusively in backend environment configuration (`backend/.env`).
  - Mobile client communicates via internal authenticated proxy endpoints (`/api/ai/*`, `/api/mandi/*`).
  - Production builds reject bundled development credentials.

## 2. On-Device DRM & Anti-Piracy Protection
- **`DrmService` Implementation:**
  - Android: `FLAG_SECURE` window attribute is enabled at startup to prevent screenshots, screen mirroring, and recording.
  - iOS: `UIScreen.isCaptured` listening automatically obscures proprietary market intelligence and masterclass video screens when recording is detected.

## 3. Session & Access Control
- **Single-Device Active Policy:**
  - Login tokens include unique device signatures.
  - When a user logs in on a new device, the backend invalidates prior active refresh tokens.
- **Role-Based Routing:**
  - Strict client and server guards distinguishing Buyers, Farmers, Sellers, Hub Operators, and Admins.
  - Sellers cannot approve their own batches; approval requires authorized quality or hub personnel.

## 4. Payment Security & Idempotency
- **No Client-Side Financial Trust:**
  - Orders are never marked as "Paid" based on mobile client assertions.
  - All payment transitions require cryptographic HMAC webhook verification from the payment provider.
  - Payment records maintain unique transaction and idempotency keys to prevent duplicate billing.
