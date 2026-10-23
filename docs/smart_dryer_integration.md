# Smart Solar Dryer integration (EcoSusRural feature)

## Where it lives

- Feature: `lib/features/smart_dryer/` (domain/data/providers/
  screens/widgets). No new packages; reuses Riverpod, ScreenUtil,
  SharedPreferences, http, existing theme/auth/storage/RBAC.
- Entry points: dashboard agriculture grid (`Smart Dryer` tile),
  Services Hub, Farmer Processing Hub section, RBAC universal list.
- Backend (optional backup): `GET/POST /api/dryer/batches`,
  `POST /api/dryer/batches/:id/readings`. Local-first still works.

## Run

`cd eco_sus_rural; flutter pub get; flutter run -d windows`
(or Android device). Backend: `cd backend; npm install; npm start`.

## Test without hardware

Open Smart Dryer -> Connect -> Demo -> pick `Demo Solar Dryer`.
DEMO MODE banner shows; simulated fan/fault/disconnect available via
`simulate_fault` / `simulate_disconnect` commands in code.

## Wi-Fi test

Connect ESP32 AP, set device address to its IP (default
`http://192.168.4.1`), pick Wi-Fi transport, Connect.

## Files changed

- `lib/features/dashboard/screens/main_dashboard_screen.dart`
- `lib/features/services_hub/services_hub_screen.dart`
- `lib/features/marketplace/screens/farmer_processing_hub_screen.dart`
- `lib/core/permission/permission_types.dart`
- `lib/core/localization/language_provider.dart`
- `backend/src/server.js`

## New files

- 8 domain/data/provider/widget files + 8 screens under
  `lib/features/smart_dryer/`
- 3 tests: calculations, protocol, access+demo
- `backend/src/routes/dryerRoutes.js`
- `docs/smart_dryer_protocol.md`, `docs/smart_dryer_firmware.md`

## Limits / next steps

- BLE is a stub until `flutter_blue_plus` is added (spec in docs).
- PDF export not bundled (no pdf dep); CSV copy included.
- Backend store is in-memory; move to Mongo/Postgres + JWT check.
- Profiles are conservative defaults, not lab-validated; high-temp
  profile flagged experimental.
- Hardware safety (cutout, fusing, isolation) must be verified on
  the physical build; app never overrides controller interlocks.
