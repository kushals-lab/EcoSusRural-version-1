# EcoSusRural local debugging (Windows)

## Services and configuration

The Flutter client calls the Express backend in `backend/`. The separate FastAPI service in `ai_service/` handles optional sustainability scoring; it is not the main API. MongoDB stores Google accounts and dryer backups. Several existing routes still require PostgreSQL. Redis supports realtime chat fan-out.

Keep provider credentials only in `backend/.env.local` (ignored by Git). Use `backend/.env.example` for variable names. Do not pass Gemini, OpenWeather, mandi, MongoDB, or JWT secrets through Flutter `--dart-define`; those values become extractable from an app package. The web OAuth client ID is a public identifier and must match `GOOGLE_WEB_CLIENT_ID` on the backend.

Before uploading, run `node scripts/audit-secrets.cjs` from the project root. It checks source and documentation for known local credentials and common secret patterns, and reports tracked environment/signing files without displaying values. Generated output, dependencies, and local environment files are excluded from source scanning. The check is heuristic: review upload changes and use your Git host's secret scanning as well. `.gitignore` does not remove an existing tracked file or erase credentials from Git history.

Run `node scripts/audit-secrets.cjs --history` to also check existing commits for credentials known from the current local environment. On 24 October 2026 this found the mandi credential in the existing commit's backend environment, two mandi route files, and two reports. The current source and reports were cleaned and `backend/.env` was untracked, but the earlier commit remains. Rotate the exposed mandi key before uploading Git history; use a separately authorized history cleanup if the old value must also be removed from commits.

From PowerShell:

```powershell
Get-Service postgresql-x64-18
cd backend
npm.cmd ci
npm.cmd run build
npm.cmd test
npm.cmd start
```

`GET http://127.0.0.1:5000/health` shows process and database telemetry. `GET http://127.0.0.1:5000/ready` checks both MongoDB and PostgreSQL and returns 503 until both are available. PostgreSQL needs the actual local `PGUSER`, `PGPASSWORD`, `PGDATABASE`, and host/port values in local configuration. Do not reset the database to fix a connection error. Redis connection warnings mean realtime cross-process delivery is unavailable; they do not explain a MongoDB or PostgreSQL failure.

The optional Python service needs Python plus FastAPI, Pydantic, and Uvicorn in a separate virtual environment. Configure its token before network deployment; its `/compute` endpoint is independent of `/api/ai/answer`.

## Flutter and VS Code

Install the Flutter and Dart VS Code extensions. The checked-in `.vscode/launch.json` provides Android emulator debug/profile and desktop debug launches. Start the backend first, then select the Android emulator configuration and press F5. The emulator reaches the host through `10.0.2.2`; a physical phone needs a reachable HTTPS backend URL instead.

```powershell
flutter.bat doctor -v
flutter.bat pub get
flutter.bat analyze
flutter.bat test
flutter.bat build apk --debug
```

Use DevTools from the VS Code command palette while the app runs. Backend request failures can be correlated with its request ID and `/health` or `/ready`. Provider errors return controlled responses; do not print API keys or ID tokens while debugging. Weather and mandi screens label cached data and provider timestamps.

The current Android application ID is `com.example.eco_sus_rural`. Google account sign-in requires that exact package name and the debug/release signing SHA fingerprints to be registered as an Android OAuth client in the same Google project as the supplied web client ID. The web ID alone cannot prove an Android installation is registered. Test sign-in on a device or emulator with Google Play services. A release app also needs a real HTTPS `API_BASE_URL`, a final application ID, and a private release signing configuration; the current Gradle release configuration uses debug signing and is not suitable for Play Store publication.

Get the signing SHA-1 and SHA-256 from Android Studio's Gradle `signingReport` task for the relevant build variant. In Google Cloud Console, create an Android OAuth client using the application ID and those fingerprints in the same project as the web OAuth client. Once registered, launch the Android app through `.vscode/launch.json` and test a complete Google sign-in and `/auth/me` restore on an emulator with Google Play services or on a device.

## OneDrive build locks

This checkout is inside a OneDrive synced folder. Gradle and Flutter have both encountered locked generated files in `build/`. For a repeatable Android build, copy the Flutter source (`android/`, `lib/`, `assets/`, `pubspec.yaml`, `pubspec.lock`, and `analysis_options.yaml`) to an unsynced local development folder, run `flutter pub get`, and build there. Never copy `backend/.env.local` or other credentials into that build folder.
