# EcoSusRural

A cross-platform rural commerce and empowerment ecosystem — Flutter app
(Windows / Android / iOS) + Node.js (Express) backend + optional Python
FastAPI AI service.

Built to be maintained by a small team with free, standard toolchains:
no code-signing certificates, no Microsoft/Azure SDKs, no nuget, no
cloud-locked services.

## Prerequisites

- Flutter SDK (stable channel)
- Windows builds: Visual Studio 2022+ with "Desktop development with C++"
- Android builds: Android Studio / Android SDK
- iOS builds: macOS with Xcode
- Backend: Node.js 20+

## Run the app

```bash
cd eco_sus_rural
flutter pub get

flutter run -d windows   # Windows desktop
flutter run -d <device>  # Android / iOS device or emulator
```

Release builds need no special signing for local use:

```bash
flutter build windows    # build\windows\x64\runner\Release\
flutter build apk        # build\app\outputs\flutter-apk\
flutter build ipa        # requires macOS + Xcode
```

## Troubleshooting: "App failed to start" on Windows

```
Unable to start executable "build\windows\x64\runner\Debug\eco_sus_rural.exe"
ProcessException: An Application Control policy has blocked this file
App failed to start
```

Windows 11 **Smart App Control** (Settings > Privacy & security > Windows
Security > App & browser control > Smart App Control) blocks unsigned binaries
that Microsoft's app intelligence service cannot classify, and our runner is
unsigned. A freshly linked build can therefore be refused (Code Integrity event
ID 3077 / 3118, policy `WindowsLockdownPolicy`), while the very same binary
starts a moment later once Windows has a verdict for it.

Fixes, in order of effort:

1. Run it again (`flutter run -d windows`, or press F5 again in VS Code).
2. `powershell -ExecutionPolicy Bypass -File scripts\run_windows.ps1` — builds,
   probes the runner and waits until Smart App Control lets it start, then
   attaches `flutter run`. `-DiagnoseOnly` prints the Smart App Control state
   and the recent block events for this app.
3. If it keeps failing, set Smart App Control **Off**. It has no per-app
   exclusions and switching it off is a one-way operation (turning it back on
   needs a Windows reinstall/reset). This is Microsoft's documented answer for
   developer machines:
   <https://learn.microsoft.com/windows/apps/develop/smart-app-control/overview>

Profile and release builds are unsigned as well, so the same applies to them.

## Phone login (development)

The OTP login flow runs fully on device. After requesting a code, enter the
universal development code **123456** to sign in. To plug in a real SMS
provider later, send the generated code from
`lib/features/auth/providers/auth_provider.dart` to your gateway and verify
server-side.

## Run the backend

```bash
cd eco_sus_rural/backend
npm install
npm start        # http://localhost:5000  (health: /health, API: /api)
```

Or with Docker — see `deploy/DEPLOYMENT.md` and `deploy/docker-compose.yml`.

## Configuration

The app reads its endpoints from environment-backed settings (see
`.env.example`):

- `API_BASE_URL` — backend base URL (default `http://127.0.0.1:5000/api`;
  use `http://10.0.2.2:5000/api` on the Android emulator)
- `AI_SERVICE_URL` — Python AI service (default `http://127.0.0.1:8000`)
- `WEATHER_API_BASE_URL`, `AI_SERVICE_TOKEN`, `AUTH_TOKEN` — see
  `backend/.env.example` and `ai_service/.env.example`

