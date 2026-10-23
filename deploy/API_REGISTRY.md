# EcoSusRural — Complete API Registry

This document lists every external API the EcoSusRural super-app uses, where to obtain it, its purpose, authentication method, and whether it is required.

---

## Required APIs

| # | API | Provider | Base URL | Purpose | Auth | How to Obtain |
|---|-----|----------|----------|---------|------|---------------|
| 1 | **Open-Meteo Weather** | Open-Meteo (free) / custom provider | `https://api.open-meteo.com/v1/forecast` | Weather, crop advisory, village forecast | None (free tier) or `WEATHER_API_KEY` | **Open-Meteo: no signup needed** — call endpoint directly (keyless). For other providers (OpenWeatherMap, WeatherAPI, TomTom, etc.): sign up at provider → get API key → set `WEATHER_API_KEY` env var. Header-based auth supported via `WEATHER_API_HEADER` env var (format: `Header-Name: value`). |
| 2 | **Google Maps / Mapbox** | Google Cloud / Mapbox | `https://maps.googleapis.com/maps/api` | Maps, geocoding, places, ETA estimation, live ride tracking | API_KEY | Google Cloud Console → APIs & Services → Credentials → Create API Key. Enable Maps SDK, Directions API, Geocoding API, Places API. |
| 3 | **Firebase Auth** | Firebase (Google) | `https://identitytoolkit.googleapis.com` | Phone OTP login, user authentication | Firebase SDK | Firebase Console → Create project → Enable Phone Authentication. Download google-services.json (Android) and GoogleService-Info.plist (iOS). |
| 4 | **Firebase Cloud Firestore** | Firebase (Google) | `https://firestore.googleapis.com` | Real-time data sync for chat, orders, marketplace, user profiles | Firebase SDK | Firebase Console → Firestore Database → Create database. Set security rules for authenticated access. |
| 5 | **Firebase Cloud Messaging (FCM)** | Firebase (Google) | `https://fcm.googleapis.com` | Push notifications for rides, payments, messages, offers | Firebase SDK | Firebase Console → Cloud Messaging → Enable. Use the same Firebase project as Auth. |
| 6 | **Firebase Cloud Storage** | Firebase (Google) | `https://firebasestorage.googleapis.com` | Image/video/media uploads for chat, content, marketplace, profile photos | Firebase SDK | Firebase Console → Storage → Get started. Set security rules for authenticated uploads. |
| 7 | **UPI / Razorpay / Cashfree** | Razorpay / Cashfree | `https://api.razorpay.com/v1` | Payments, QR scan, wallet, transfers, subscriptions | API_KEY + Secret | Sign up at razorpay.com → Dashboard → API Keys → Generate Key ID and Key Secret. |
| 8 | **Rapido / Ola / Uber Partner API** | Ride-hailing partners | Partner endpoints | Cab/bike booking, live driver tracking, fare estimation | OAuth / API_KEY | Apply at rapido.biz / developer.ola.com / developer.uber.com. |
| 9 | **ConfirmTKT / IRCTC** | ConfirmTKT / IRCTC | `https://api.confirmtkt.com` | Train booking, PNR status, seat availability | API_KEY | Sign up at confirmtkt.com → API → Get API key. |
| 10 | **BookMyShow** | BookMyShow | `https://api.bookmyshow.com` | Movies, events, shows booking, ticket management | API_KEY | Contact BookMyShow business development at business.bookmyshow.com. |

---

## Optional APIs

| # | API | Provider | Base URL | Purpose | Auth | How to Obtain |
|---|-----|----------|----------|---------|------|---------------|
| 15 | **Government Schemes (data.gov.in)** | data.gov.in / NITI Aayog | `https://api.data.gov.in` | MSP, government schemes, farmer advisory data | API_KEY (free) | Sign up at data.gov.in → My Account → API Key. |
| 16 | **Telegram Bot / WhatsApp Business** | Telegram / WhatsApp Business API | `https://api.telegram.org` | Chat bot, order updates, notifications | BOT_TOKEN | Telegram: Message @BotFather → /newbot → Get token. |

---

## Permission Summary

The app requests the following Android/iOS permissions at runtime (using `permission_handler`):

| Permission | Android Permission | iOS Info.plist Key | When Requested | Skippable |
|------------|-------------------|-------------------|----------------|-----------|
| Location | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | `NSLocationWhenInUseUsageDescription` | Ride booking, weather, marketplace | Yes (manual entry fallback) |
| Camera | `CAMERA` | `NSCameraUsageDescription` | QR scan, profile photos, content creation | Yes |
| Microphone | `RECORD_AUDIO` | `NSMicrophoneUsageDescription` | Voice messages, audio notes, video recording | Yes |
| Notifications | `POST_NOTIFICATIONS` (Android 13+) | (iOS automatic) | Ride ETA, payments, messages, offers | Yes |
| Phone State | `READ_PHONE_STATE` | (not needed) | OTP auto-fill, device binding | Yes |
| Storage | `READ/WRITE_EXTERNAL_STORAGE` | `NSPhotoLibraryUsageDescription` | Download media, upload photos | Yes |
| Contacts | `READ_CONTACTS` | `NSContactsUsageDescription` | Easy messaging/billing/payment find | Yes |
| Bluetooth | `BLUETOOTH`, `BLUETOOTH_CONNECT` | `NSBluetoothAlwaysUsageDescription` | Proximity pairing | Yes |

**Skipable permissions:** When denied, features degrade gracefully (e.g., location denied → manual address entry).

---

## Language Support (100+ Languages)

- **22 Official Indian languages** (8th Schedule of Constitution)
- **40 Regional Indian languages** (one per state minimum)
- **38 Foreign languages** (all major world languages)

### Language Handling Architecture

1. **Primary dictionary** (`_localizedStrings`): Full translations for top languages
2. **Dialect fallback** (`kDialectToParent`): Regional dialects fall back to parent language
3. **English fallback**: Missing translations fall back to English
4. **Glossary** (`_fallbackGlossary`): Word-level explanations for missing terms
5. **Inline explanation UI**: Tappable underlined terms show explanations in bottom sheet

### Word-Level Fallback

When a translation key is missing:
1. Check primary dictionary → if found, use it
2. Check parent dialect → if found, use parent's translation
3. Check English → if found, use English
4. Check glossary → show short explanation in user's language
5. Show the key itself (with underline to indicate missing translation)

This ensures **no app function breaks** even when a translation is missing.

---

## Environment Variables

```bash
WEATHER_API_BASE_URL=https://api.open-meteo.com/v1/forecast
WEATHER_API_KEY=                             # optional — set for providers that require auth
WEATHER_API_HEADER=                           # optional — e.g. "Authorization: Bearer xxx"
DEFAULT_LATITUDE=21.5999
DEFAULT_LONGITUDE=71.2162
GOOGLE_MAPS_API_KEY=your_key_here
BACKEND_PORT=5000
API_BASE_URL=http://127.0.0.1:5000/api
AUTH_TOKEN=your_jwt_secret
AI_SERVICE_URL=https://generativelanguage.googleapis.com
AI_SERVICE_TOKEN=your_token_here
```

---

## Android Manifest Permissions

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

---

## iOS Info.plist Permissions

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to match you with the nearest partner and show ETA.</string>
<key>NSCameraUsageDescription</key>
<string>Camera is used to scan QR codes, take profile photos, and create content.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone is used for voice messages and audio notes.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is used to upload and download media.</string>
<key>NSContactsUsageDescription</key>
<string>Contacts access helps you find friends and share payments easily.</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth is used for proximity features.</string>
```
| 11 | **YouTube Data API** | Google | `https://www.googleapis.com/youtube/v3` | Long-form video hosting, streaming, thumbnails | API_KEY | Google Cloud Console → Enable YouTube Data API v3 → Create API Key. |
| 12 | **Twilio / MSG91** | Twilio / MSG91 | `https://api.twilio.com` | SMS OTP, transaction alerts, notifications | API_KEY + SID/Token | Sign up at twilio.com or msg91.com → Get Account SID and Auth Token. |
| 13 | **Gemini / OpenAI** | Google / OpenAI | `https://generativelanguage.googleapis.com` | AI assistant, expert advice, translations | API_KEY | Google AI Studio (aistudio.google.com) → API Keys → Create API key. |
| 14 | **OpenStreetMap / Nominatim** | OpenStreetMap | `https://nominatim.openstreetmap.org` | Offline maps, geocoding, reverse geocoding | None (fair-use) | No signup needed. Respect usage policy (max 1 request/second). |