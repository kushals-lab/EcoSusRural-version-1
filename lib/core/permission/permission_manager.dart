/// Runtime permission manager for EcoSusRural.
/// Handles checking, requesting, and explaining permissions in the user's language.
library permission_manager;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../translation/translation_repository.dart';
import 'location_permission.dart';
import 'permission_types.dart';

/// Result of a permission request.
class PermissionRequestResult {
  final AppPermission permission;
  final PermissionStatus status;
  final bool granted;

  const PermissionRequestResult({
    required this.permission,
    required this.status,
    required this.granted,
  });
}

/// Manages runtime permissions with localized explanations.
class PermissionManager {
  PermissionManager._();
  static final PermissionManager instance = PermissionManager._();

  /// Current status of a permission.
  ///
  /// The app bundles no native hardware consumers (there is no camera,
  /// microphone, or GPS plugin), so most permissions are reported as granted.
  /// Location is the exception: the user answers it explicitly through the
  /// consent sheet (allow every time / only while using the app / ask every
  /// time / deny) and that stored choice is reported here.
  Future<PermissionStatus> statusOf(AppPermission permission) async {
    if (permission == AppPermission.location ||
        permission == AppPermission.backgroundLocation) {
      final mode = await LocationPermissionStore.load();
      switch (mode) {
        case LocationAccessMode.allowEveryTime:
        case LocationAccessMode.allowWhileUsingApp:
          return PermissionStatus.granted;
        case LocationAccessMode.deny:
          return PermissionStatus.permanentlyDenied;
        case LocationAccessMode.askEveryTime:
        case LocationAccessMode.notAsked:
          return PermissionStatus.denied;
      }
    }
    return PermissionStatus.granted;
  }

  /// Check if a permission is granted.
  Future<bool> isGranted(AppPermission permission) async {
    final status = await statusOf(permission);
    return status.isGranted || status.isLimited;
  }

  /// Request a single permission.
  Future<PermissionRequestResult> request(AppPermission permission) async {
    final status = await statusOf(permission);
    return PermissionRequestResult(
      permission: permission,
      status: status,
      granted: status.isGranted || status.isLimited,
    );
  }

  /// Check all required permissions for a feature.
  Future<Map<AppPermission, bool>> checkFeature(String featureKey) async {
    final feature = FeaturePermissionRegistry.forFeature(featureKey);
    if (feature == null) return {};
    final result = <AppPermission, bool>{};
    for (final p in feature.requiredPermissions) {
      result[p] = await isGranted(p);
    }
    return result;
  }

  /// Request all required permissions for a feature, returning which were granted.
  Future<Map<AppPermission, PermissionRequestResult>> requestFeature(
    String featureKey,
  ) async {
    final feature = FeaturePermissionRegistry.forFeature(featureKey);
    if (feature == null) return {};
    final result = <AppPermission, PermissionRequestResult>{};
    for (final p in feature.requiredPermissions) {
      result[p] = await request(p);
    }
    return result;
  }

  /// Open app settings so the user can manually grant a permission.
  ///
  /// No-op today: with no native permission consumers there is nothing to
  /// grant in system settings. Returns true to keep callers flowing.
  Future<bool> openSettings() async => true;

  /// Shows a localized "why we need this" pre-prompt before the OS dialog.
  ///
  /// Returns true when the user agrees to continue to the system dialog.
  /// All strings come from the current language pack so the explanation
  /// itself is always in the user's selected language.
  Future<bool> showRationale(
    BuildContext context, {
    required String featureKey,
    String? languageCode,
  }) async {
    final feature = FeaturePermissionRegistry.forFeature(featureKey);
    if (feature == null) return true;
    // Resolve language code from the nearest provider scope when available.
    // Falls back to the explicitly passed code, then English.
    String code = (languageCode ?? 'en').trim().toLowerCase();
    final fallback = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_language');
      code = (saved?.trim().toLowerCase()) ?? fallback;
      if (code.isEmpty) code = fallback;
    } catch (_) {
      code = fallback;
    }

    String t(String key, String fallback) {
      final v = TranslationRepository.instance.snapshot(code)[key];
      if (v != null && v.isNotEmpty && v != key) return v;
      return fallback;
    }

    // Collect every permission the feature touches (required + optional).
    final allPermissions = feature.requiredPermissions +
        feature.optionalPermissions;
    final names = allPermissions
        .map((p) => _localizedPermissionName(p, code))
        .toSet()
        .join(', ');
    final skippable = feature.optionalPermissions.isNotEmpty;
    // Guard against stale BuildContext after the async gap.
    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${feature.featureTitle} — ${t('permWhyTitle', 'why we ask')}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(feature.whyNeeded),
              const SizedBox(height: 8),
              Text('${t('permUses', 'Uses')}: $names.'),
              if (feature.locationIsEssential)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(t(
                    'permMapNote',
                    'A live map is shown so you can drop a pin — even when booking for someone else.',
                  )),
                ),
              if (skippable)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(t(
                    'permOptionalNote',
                    'Some of these are optional and can be skipped — the feature still works.',
                  )),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('permNotNow', 'Not now')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('permContinue', 'Continue')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Localized display name for a permission (falls back to English label).
  String _localizedPermissionName(AppPermission p, String code) {
    const fallback = {
      AppPermission.location: 'Location',
      AppPermission.camera: 'Camera',
      AppPermission.microphone: 'Microphone',
      AppPermission.notifications: 'Notifications',
      AppPermission.phone: 'Phone',
      AppPermission.storage: 'Storage',
      AppPermission.contacts: 'Contacts',
      AppPermission.bluetooth: 'Bluetooth',
      AppPermission.sensors: 'Sensors',
      AppPermission.advertisingId: 'Advertising ID',
      AppPermission.backgroundLocation: 'Background location',
      AppPermission.nearbyDevices: 'Nearby devices',
      AppPermission.pictureInPicture: 'Picture-in-picture',
    };
    // Keys like permLocation / permCamera live in the language packs.
    final key =
        'perm${p.name[0].toUpperCase()}${p.name.substring(1)}';
    final v = TranslationRepository.instance.snapshot(code)[key];
    if (v != null && v.isNotEmpty && v != key) return v;
    return fallback[p] ?? p.name;
  }

  /// Full flow: rationale dialog -> system request -> settings fallback.
  ///
  /// Returns true when every *required* permission ends up granted.
  /// Optional (skippable) permissions never block the feature.
  Future<bool> ensureFeature(
    BuildContext context,
    String featureKey, {
    bool showRationaleFirst = true,
  }) async {
    final feature = FeaturePermissionRegistry.forFeature(featureKey);
    if (feature == null) return true;
    if (showRationaleFirst && context.mounted) {
      final agreed = await showRationale(context, featureKey: featureKey);
      if (!agreed) return false;
    }
    var allRequiredGranted = true;
    for (final p in feature.requiredPermissions) {
      if (await isGranted(p)) continue;
      final res = await request(p);
      if (!res.granted) {
        // Essential location denial is a hard stop; other denials are
        // recorded but still let the caller decide (feature degrades).
        if (p == AppPermission.location && feature.locationIsEssential) {
          allRequiredGranted = false;
        } else {
          allRequiredGranted = false;
        }
      }
    }
    // Fire-and-forget: optional permissions are offered but never block.
    for (final p in feature.optionalPermissions) {
      if (!await isGranted(p)) {
        // Best-effort single request; ignore the outcome.
        try {
          await request(p);
        } catch (_) {}
      }
    }
    return allRequiredGranted;
  }
}