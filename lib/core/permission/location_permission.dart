/// Explicit location-access consent for weather intelligence and the other
/// geo-aware features of EcoSusRural.
///
/// The app bundles no GPS plugin, so instead of reporting a silent "granted"
/// this module records the user's real answer using the same four choices the
/// platform dialog offers:
///
///   * Allow every time
///   * Allow only while using the app
///   * Ask every time
///   * Deny
///
/// The answer is persisted, so it survives restarts, and every feature keeps
/// working with its bundled village anchor whenever access is not allowed —
/// nothing is blocked and no existing behaviour is removed.
library location_permission;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../translation/translation_repository.dart';

/// The four location choices presented to the user.
enum LocationAccessMode {
  /// Consent has never been captured.
  notAsked,

  /// "Allow all the time" (foreground + background).
  allowEveryTime,

  /// "Allow only while using the app".
  allowWhileUsingApp,

  /// "Ask every time" — re-prompt on each feature entry.
  askEveryTime,

  /// "Deny" — the feature degrades to the bundled village anchor.
  deny,
}

extension LocationAccessModeX on LocationAccessMode {
  /// Whether the stored answer permits using the device location.
  bool get allowsAccess =>
      this == LocationAccessMode.allowEveryTime ||
      this == LocationAccessMode.allowWhileUsingApp;

  /// Whether the consent sheet should be surfaced again.
  bool get needsPrompt =>
      this == LocationAccessMode.notAsked ||
      this == LocationAccessMode.askEveryTime;
}

/// Persists the user's location choice across sessions.
class LocationPermissionStore {
  LocationPermissionStore._();

  static const String prefsKey = 'ecosus.permission.location.mode';

  static LocationAccessMode _mode = LocationAccessMode.notAsked;
  static bool _loaded = false;

  /// Last known answer (call [load] first for the persisted value).
  static LocationAccessMode get mode => _mode;

  /// True when the app may use the device location right now.
  static bool get allowsAccess => _mode.allowsAccess;

  /// True when the consent sheet should be shown before using location.
  static bool get shouldAsk => _mode.needsPrompt;

  /// Reads the persisted answer once (cached afterwards).
  static Future<LocationAccessMode> load() async {
    if (_loaded) return _mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      _mode = _parse(prefs.getString(prefsKey));
    } catch (_) {
      _mode = LocationAccessMode.notAsked;
    }
    _loaded = true;
    return _mode;
  }

  /// Stores a new answer.
  static Future<void> save(LocationAccessMode mode) async {
    _mode = mode;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, mode.name);
    } catch (_) {
      // Storage is best-effort; the in-memory answer still applies.
    }
  }

  static LocationAccessMode _parse(String? raw) {
    if (raw == null || raw.isEmpty) return LocationAccessMode.notAsked;
    for (final value in LocationAccessMode.values) {
      if (value.name == raw) return value;
    }
    return LocationAccessMode.notAsked;
  }

  /// Test/teardown helper.
  static void reset() {
    _mode = LocationAccessMode.notAsked;
    _loaded = false;
  }
}

/// Localized strings for the consent sheet, resolved from the active pack with
/// an English fallback (mirrors PermissionManager.showRationale).
class _LocationPermissionStrings {
  static Future<Map<String, String>> resolve() async {
    String code = 'en';
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_language');
      if (saved != null && saved.trim().isNotEmpty) {
        code = saved.trim().toLowerCase();
      }
    } catch (_) {
      code = 'en';
    }

    String t(String key, String fallback) {
      final value = TranslationRepository.instance.snapshot(code)[key];
      if (value != null && value.isNotEmpty && value != key) return value;
      return fallback;
    }

    return {
      'title': t(
        'permLocationTitle',
        'Allow EcoSusRural to access your location?',
      ),
      'message': t(
        'permLocationMessage',
        'Weather intelligence needs your village location to show accurate '
            'rainfall, temperature and mandi advisories. Your coordinates stay '
            'on your device.',
      ),
      'everyTime': t('permAllowEveryTime', 'Allow every time'),
      'everyTimeNote': t(
        'permAllowEveryTimeNote',
        'Live weather, mandi alerts and advisories even in the background',
      ),
      'whileUsing': t('permAllowWhileUsing', 'Only while using the app'),
      'whileUsingNote': t(
        'permAllowWhileUsingNote',
        'Recommended — location is used only when the app is open',
      ),
      'askEveryTime': t('permAskEveryTime', 'Ask every time'),
      'askEveryTimeNote': t(
        'permAskEveryTimeNote',
        'The app asks for permission each time you open a location feature',
      ),
      'deny': t('permDeny', 'Deny'),
      'denyNote': t(
        'permDenyNote',
        'Continue with the default village forecast — you can enable it later',
      ),
      'required': t('permLocationRequired', 'Needed for Weather Intelligence'),
      'changeAnytime': t(
        'permChangeAnytime',
        'You can change this any time in Settings.',
      ),
    };
  }
}

/// Shows the four-option consent sheet and persists the answer.
///
/// Returns the resulting [LocationAccessMode]; dismissing the sheet keeps the
/// previous answer.
Future<LocationAccessMode> showLocationPermissionSheet(
  BuildContext context,
) async {
  await LocationPermissionStore.load();
  final previous = LocationPermissionStore.mode;
  final s = await _LocationPermissionStrings.resolve();
  if (!context.mounted) return previous;

  final chosen = await showModalBottomSheet<LocationAccessMode>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4D3E).withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: const Color(0xFF1B4D3E),
                    size: 22.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    s['title']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B4D3E),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              s['message']!,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline,
                      size: 14.r, color: Colors.amber.shade900),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      s['required']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            _locationOptionTile(
              sheetContext,
              icon: Icons.public,
              title: s['everyTime']!,
              subtitle: s['everyTimeNote']!,
              mode: LocationAccessMode.allowEveryTime,
              selected: previous == LocationAccessMode.allowEveryTime,
            ),
            _locationOptionTile(
              sheetContext,
              icon: Icons.smartphone,
              title: s['whileUsing']!,
              subtitle: s['whileUsingNote']!,
              mode: LocationAccessMode.allowWhileUsingApp,
              selected: previous == LocationAccessMode.allowWhileUsingApp,
            ),
            _locationOptionTile(
              sheetContext,
              icon: Icons.help_outline,
              title: s['askEveryTime']!,
              subtitle: s['askEveryTimeNote']!,
              mode: LocationAccessMode.askEveryTime,
              selected: previous == LocationAccessMode.askEveryTime,
            ),
            _locationOptionTile(
              sheetContext,
              icon: Icons.block,
              title: s['deny']!,
              subtitle: s['denyNote']!,
              mode: LocationAccessMode.deny,
              selected: previous == LocationAccessMode.deny,
              danger: true,
            ),
            SizedBox(height: 6.h),
            Text(
              s['changeAnytime']!,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    },
  );

  if (chosen == null) return previous;
  await LocationPermissionStore.save(chosen);
  return chosen;
}

/// One radio-style row of the consent sheet.
Widget _locationOptionTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required LocationAccessMode mode,
  required bool selected,
  bool danger = false,
}) {
  final accent = danger ? Colors.red.shade700 : const Color(0xFF1B4D3E);
  return Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Material(
      color: selected ? accent.withValues(alpha: 0.07) : Colors.grey[50],
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => Navigator.pop(context, mode),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(icon, size: 20.r, color: accent),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18.r,
                color: selected ? accent : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Prompts for location consent when the stored answer requires it and reports
/// whether access is allowed afterwards.
Future<bool> requestLocationAccess(BuildContext context) async {
  await LocationPermissionStore.load();
  if (LocationPermissionStore.allowsAccess) return true;
  if (!context.mounted) return false;
  final chosen = await showLocationPermissionSheet(context);
  return chosen.allowsAccess;
}
