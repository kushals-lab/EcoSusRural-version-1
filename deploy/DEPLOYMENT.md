# Running EcoSusRural

A Flutter app (Windows / Android / iOS) with a small Node.js (Express) backend
and an optional Python FastAPI AI service. Everything is designed to be built
and run by a small team on standard free toolchains — no paid developer
accounts, code-signing certificates, or cloud-specific SDKs required.

## Prerequisites

- Flutter SDK (stable channel)
- Windows builds: Visual Studio 2022 with "Desktop development with C++"
- Android builds: Android Studio / Android SDK
- iOS builds: macOS with Xcode
- Backend: Node.js 20+

## Run the app in development

```bash
cd eco_sus_rural
flutter pub get

flutter run -d windows   # Windows
flutter run -d <device>  # Android / iOS device or emulator
```

That's it — no signing step. Debug builds are signed automatically with the
debug key (Android) or not signed at all (Windows). Release signing is only
needed when publishing to the Play Store / App Store, where you use the
store's normal process.

## Run the backend

```bash
cd eco_sus_rural/backend
npm install
npm start                # serves http://localhost:5000
```

Or with Docker (see `deploy/docker-compose.yml`):

```bash
cd eco_sus_rural/deploy
docker compose up -d --build
```

## Point the app at your backend

The app reads its endpoints from environment/config (see `.env.example`):
`API_BASE_URL` (default `http://127.0.0.1:5000/api`) and `AI_SERVICE_URL`
(default `http://127.0.0.1:8000`). On the Android emulator use
`http://10.0.2.2:5000/api` to reach your host machine.

## Phone login (development)

OTP login runs fully on device — after requesting a code, enter the
universal development code `123456`. See the README for how to wire a real
SMS gateway later.

## Troubleshooting

- **OneDrive sync errors during Windows builds** (`The cloud operation was
  unsuccessful` / MSB6003): this project folder lives inside OneDrive, which
  can lock files mid-build. Pause OneDrive while building, exclude the
  `build/` folder from sync, or move the project out of OneDrive.
- If plugins are added later whose Windows CMake scripts fetch nuget.exe
  (e.g. `permission_handler`, `geolocator`), either accept that build step or
  vendor the needed Windows headers — the rest of this project needs no
  nuget at all.

