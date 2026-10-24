# EcoSusRural engineering status — 24 October 2026

## A. Project health

| Area | Verified result |
| --- | --- |
| Flutter | `flutter doctor -v` and `flutter analyze` passed after the final code edit. All 118 widget/unit tests passed. |
| Express backend | TypeScript build and 19 Node tests passed. Backend started and served weather, mandi, AI, and auth routes. |
| MongoDB Atlas | Ping succeeded; `/ready` reported MongoDB available. Google account records use MongoDB. |
| PostgreSQL | Windows service runs, but the app has no usable local PostgreSQL credentials. `/ready` correctly returns 503. Routes backed by PostgreSQL remain unverified. |
| Redis | Local Redis refused connections. Realtime cross-process chat is degraded. |
| FastAPI scoring service | Python was not on PATH; service and its tests could not be run. |
| Provider APIs | Government mandi, Gemini model, and both OpenWeather keys responded successfully to direct checks. Backend weather, mandi, and general AI routes returned useful responses. |
| Android | Debug, profile, and release APKs plus release AAB built from an isolated source copy outside OneDrive. No Android device or emulator was available for a runtime sign-in test. |
| Performance | No controlled device frame-time or load benchmark was run; no numerical performance improvement is claimed. |

## B. Significant problems found and C. corrections

| Severity | Problem and affected area | Correction or current state |
| --- | --- | --- |
| High | MongoDB success could mask unavailable PostgreSQL (`backend/src/server.js`). | `/ready` now checks both stores and returns 503 until both work. PostgreSQL credentials still need to be supplied locally. |
| High | Local phone OTP and old legal copy could imply stronger authentication or guarantees than implemented (`lib/features/auth/providers/auth_provider.dart`, `lib/core/localization/language_provider.dart`). | Google token verification and revocable sessions added; unsupported legal claims corrected. Phone OTP remains a local demo and cannot authorize backend requests. |
| High | Google account sign-in had no verified backend flow (`backend/src/routes/authRoutes.js`, `backend/src/middleware/authMiddleware.js`). | Backend verifies Google's ID token audience and verified email, stores the account in MongoDB, signs a revocable session JWT, and supports `/auth/me` and logout. Flutter stores the token in secure storage. Android OAuth registration and device test remain. |
| Medium | Market data was described as live although government records can be delayed (`backend/src/routes/mandiRoutes.js`, `lib/features/schemes/screens/live_mandi_prices_screen.dart`). | Backend and UI now distinguish fresh fetches from live reporting and show record dates. |
| Medium | Provider keys were not wired to server-side routes (`backend/src/ai/adapters/textProvider.js`, `backend/src/services/openWeatherCurrent.js`, `backend/src/routes/weatherRoutes.js`). | Gemini, mandi, and OpenWeather integrations added behind the backend. Seven-day forecast remains sourced from Open-Meteo. The two Gemini values supplied were identical and therefore provide one distinct key. |
| Medium | Provider errors could expose internal exception text (`backend/src/ai/gateway.js`). | AI gateway now returns a stable generic error code. |
| Medium | Generated files in the OneDrive checkout were locked during Gradle builds (`build/`). | An isolated source copy in local Temp was used for build verification. Workspace-generated files were not broadly deleted. |
| Medium | Redis and Python services are unavailable locally. | Documented as unmet runtime dependencies; no success claim for affected workflows. |
| Low | Flutter analyzer and stale UI test failures. | Fixed screen issues and updated relevant widget tests for actual weather/reminder behavior. |

## D. Principal files changed

Backend: `backend/src/server.js`, `backend/src/routes/authRoutes.js`, `backend/src/middleware/authMiddleware.js`, `backend/src/routes/mandiRoutes.js`, `backend/src/routes/weatherRoutes.js`, `backend/src/ai/answerEngine.js`, `backend/src/ai/gateway.js`, `backend/src/ai/adapters/textProvider.js`, `backend/src/services/openWeatherCurrent.js`, `backend/package.json`, `backend/.env.example`, and backend tests.

Flutter/Android: `lib/features/auth/providers/auth_provider.dart`, `lib/features/auth/screens/phone_login_screen.dart`, `lib/core/config/app_config.dart`, `lib/core/localization/language_provider.dart`, `lib/features/weather/screens/weather_screen.dart`, `lib/features/schemes/screens/live_mandi_prices_screen.dart`, `lib/core/permission/location_permission.dart`, `android/app/src/debug/AndroidManifest.xml`, `android/app/src/profile/AndroidManifest.xml`, `.vscode/launch.json`, dependency manifests, and affected tests. The wider working tree also contains changes from earlier EcoSusRural work; review `git diff` before making a commit.

## E. Test and build results

- `flutter doctor -v`: pass.
- `flutter analyze`: pass after the final phone OTP guard edit.
- `flutter test --reporter compact`: 118 passed.
- `npm.cmd run build`: pass.
- `npm.cmd test`: 19 passed, including Google session replacement/logout and database readiness.
- MongoDB ping: pass. Backend `/ready`: 503, reporting MongoDB available and PostgreSQL unavailable.
- Backend weather: 200 with current conditions and seven forecast days. Mandi: 200 with reported price records. General AI: model response succeeded. Invalid Google ID token: rejected.
- Android debug, profile, and release APKs and release AAB: built successfully in isolated local copy. In-place OneDrive build failed because Gradle could not modify locked generated files. A copy of the debug-signed release APK is at `build/verified/EcoSusRural-internal-test.apk`; its copy hash was checked.
- Android device/emulator workflow, FastAPI pytest, PostgreSQL integration, Redis realtime, payments, and load tests: not run or not verifiable in the current environment.

## F. Performance

No reproducible frame-time, memory, network-latency, or throughput baseline was available. Existing widgets and API paths were inspected and targeted failures fixed, but no quantified speed claim is made.

## G. Security findings

Provider credentials remain in Git-ignored `backend/.env.local`, not the Flutter binary. The Google web OAuth client ID is a public identifier. Google sign-in rejects unverifiable tokens, checks the email verification flag, and revokes a prior session on a new login. Release builds still use the debug signing key and are unsuitable for store publication. The locally generated phone OTP is a demo flow. Credentials shared through chat should be rotated before production deployment.

## H. Remaining work and I. readiness

**Classification: NOT READY for production.** The application is buildable and useful for local development, but PostgreSQL-backed routes cannot pass readiness, Redis and FastAPI are unavailable, Android Google sign-in has not been registered/tested on a device, and release signing is provisional. Payment and logistics flows need provider configuration and human end-to-end verification. A controlled pilot needs these dependencies plus HTTPS deployment, integration tests against a separate test database, and device/load checks.

The current Android package/application ID is `com.example.eco_sus_rural`. Register that package and the actual signing SHA fingerprint as an Android OAuth client in the same Google project as the supplied web client ID for device sign-in. Select a permanent package ID before Play Store publication, then re-register OAuth and create a private release signing configuration.
