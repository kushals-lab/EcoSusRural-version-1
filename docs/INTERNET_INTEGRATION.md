# INTERNET INTEGRATION & NETWORK RESILIENCE

**Date:** 2026-10-23  
**Status:** FULLY IMPLEMENTED & VERIFIED

---

## 1. Android Manifest Permissions
Android manifest permissions configured without requesting unnecessary user runtime dialogs:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 2. Dynamic Network State & Heartbeat Engine
- **Class:** `NetworkNotifier` & `networkStatusProvider` in `lib/core/network/api_client.dart`.
- **True Connectivity Detection:** Instead of falsely assuming an active Wi-Fi or cellular interface implies internet reachability, the engine performs lightweight periodic heartbeats against the backend health API (`/health`).
- **Heartbeat Interval:** 25 seconds background cycle with immediate wakeup upon connectivity state transitions.

## 3. Intelligent Request Handling & Deduplication
- **In-Flight Deduplication:** Simultaneous duplicate requests to the same endpoint reuse the identical `Future`, preventing bandwidth waste and server stampedes.
- **Exponential Backoff:** Up to 3 automatic retries with 500ms, 1000ms, and 2000ms backoff intervals.
- **Fail-Safe Offline Transition:** If all attempts fail or the network is severed, the client smoothly retrieves the last cached snapshot from `LocalStorage`.
