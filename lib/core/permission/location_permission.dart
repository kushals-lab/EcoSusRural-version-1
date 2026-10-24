library location_permission;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';



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


Future<LocationAccessMode> showLocationPermissionSheet(BuildContext context) async {
  final agreed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
    title: const Text('Location for local weather'),
    content: const Text('Allow foreground location to select local weather. You may use an approximate location or choose an address manually in Settings.'),
    actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Choose manually')),
      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Continue'))]));
  if (agreed != true) {
    await LocationPermissionStore.save(LocationAccessMode.deny);
    return LocationAccessMode.deny;
  }
  try {
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) permission = await geo.Geolocator.requestPermission();
    final mode = permission == geo.LocationPermission.always || permission == geo.LocationPermission.whileInUse
      ? LocationAccessMode.allowWhileUsingApp : LocationAccessMode.deny;
    await LocationPermissionStore.save(mode);
    return mode;
  } catch (_) { return LocationAccessMode.deny; }
}
Future<bool> requestLocationAccess(BuildContext context) async =>
  (await showLocationPermissionSheet(context)).allowsAccess;
