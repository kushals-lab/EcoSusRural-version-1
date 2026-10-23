/// EcoSusRural Core Package
///
/// Provides shared infrastructure: networking, dependency injection,
/// storage, security, localization, theming, error handling, and more.
///
/// Import the barrel file to access all core modules:
/// ```dart
/// import 'core.dart';
/// ```
library core;

// ── Configuration ──────────────────────────────────────────────────────────
export 'core/config/app_config.dart';

// ── Dependency Injection ────────────────────────────────────────────────────
export 'core/di/injection.dart';

// ── Networking / API Client ────────────────────────────────────────────────
export 'core/network/api_client.dart';

// ── Storage & Offline Cache ────────────────────────────────────────────────
export 'core/storage/local_storage.dart';

// ── Security / DRM ─────────────────────────────────────────────────────────
export 'core/security/drm_services.dart';

// ── Localization ───────────────────────────────────────────────────────────
export 'core/localization/language_provider.dart';

// ── Theme & Accessibility ──────────────────────────────────────────────────
export 'core/theme/app_theme.dart';

// ── Error Handling ─────────────────────────────────────────────────────────
export 'core/error/failures.dart';

// ── FFI / Native Utilities ──────────────────────────────────────────────────
export 'core/ffi/native_compressor.dart';

// ── Orchestration ──────────────────────────────────────────────────────────
export 'core/orchestrator/app_orchestrator.dart';