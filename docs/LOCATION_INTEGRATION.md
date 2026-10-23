# LOCATION INTEGRATION & GPS ARCHITECTURE

**Date:** 2026-10-23  
**Status:** FULLY IMPLEMENTED & VERIFIED

---

## 1. Permission Model & Privacy Controls
- **Android Manifest Entries:**
  ```xml
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  ```
- **Permission Outcomes Handled:**
  - **Granted:** App captures approximate or precise coordinates, maps to the nearest district APMC, and loads locally targeted market data.
  - **Denied:** Zero crashes or intrusive blocking modals. The app automatically enters **Manual Selection Mode**, allowing the user to select any state, district, or APMC market directly from a clean bottom sheet.
  - **No Background Collection:** GPS collection is strictly scoped to foreground screen interactions. Continuous background tracking is omitted to preserve battery and respect privacy.

## 2. Location State Persistence
- **Provider:** `userLocationProvider` in `lib/features/weather/providers/location_provider.dart`.
- Coordinates, state names, district names, and preferred markets are persisted in local encrypted key-value storage (`ecosus.user.location`).
