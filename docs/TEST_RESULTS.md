# TEST RESULTS REPORT: AUTOMATIC CONNECTIVITY, GPS, OFFLINE & POSTGRESQL

**Test Date:** 2026-10-23  
**Flutter Engine:** 3.47.7 (Stable) / Dart 3.13.5  
**Backend:** Node.js v24.19.0 / Express 5.2.1

---

## 1. Test Execution Matrix

| Test ID | Condition Tested | Result | Evidence / Notes |
|---|---|---|---|
| **T01** | Flutter Codebase Health | **PASSED** | `flutter analyze` completed with 0 errors and 0 warnings. |
| **T02** | Flutter Unit/Widget Suite | **PASSED** | 90 tests executed via `flutter test --dart-define=ECSUS_DEV_LOGIN=true`: **90 passed, 0 failed**. |
| **T03** | Backend Automated Tests | **PASSED** | 16 tests across 8 suites executed via `node --test`: **16 passed, 0 failed**. |
| **T04** | Live Mandi API Fetching | **PASSED** | Retrieved 17,458 active records via Ministry of Agriculture endpoint (`data.gov.in`). |
| **T05** | Live Gemini AI Key | **PASSED** | Google AI Studio endpoint returned valid model listing (HTTP 200). |
| **T06** | Live Weather Integration | **PASSED** | Open-Meteo returned 7-day forecast series (HTTP 200). |
| **T07** | PostgreSQL 18 Service Check | **PASSED** | Service `postgresql-x64-18` detected running on port 5432 (PID 7784). |
| **T08** | Offline Resilience & Caching | **PASSED** | `LocalStorage` caches JSON models with ISO timestamps; `ApiClient` serves cached data when offline. |
| **T09** | Location Permission Handling | **PASSED** | Coarse & fine location permissions added to `AndroidManifest.xml`; graceful manual selection fallback active. |
