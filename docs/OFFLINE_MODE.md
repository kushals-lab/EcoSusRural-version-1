# OFFLINE-FIRST ARCHITECTURE & CACHING

**Date:** 2026-10-23  
**Status:** FULLY IMPLEMENTED & VERIFIED

---

## 1. Storage Architecture
- **Layer:** `LocalStorage` in `lib/core/storage/local_storage.dart`.
- **Hybrid Mechanism:** High-speed in-memory Map combined with persistent device storage via `SharedPreferences`.
- **Structured Storage:** Every saved JSON model contains:
  - `cachedAt`: ISO-8601 timestamp representing exact time of retrieval.
  - `data`: Complete response payload.

## 2. Offline UX & Data Honesty
- **`OfflineStatusBar` (`lib/core/widgets/offline_status_bar.dart`):** Unobtrusive top banner indicating that cached information is being displayed, with a manual 'Retry' trigger.
- **Timestamp Transparency:** The app never claims cached data is live. When offline, market cards and weather panels explicitly label data as `"Offline Cache: Saved on [Timestamp]"`.
- **Financial Safety Guarantee:** Non-idempotent operations (payment authorization, orders, balance debits) are **never queued for automatic blind replay**. Replays require conscious user confirmation when connectivity returns.
