/// Device settings store: calibration, units, notifications, maintenance.
library;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/battery_settings.dart';
class DryerSettingsStore {
  static const _k = 'smart_dryer.settings.v1';
  static const _logK = 'smart_dryer.config_log.v1';
  static Future<DryerDeviceSettings> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_k);
      if (raw == null) return const DryerDeviceSettings();
      return DryerDeviceSettings.fromMap(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const DryerDeviceSettings();
    }
  }
  static Future<void> save(DryerDeviceSettings s,
      {String note = ''}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(s.toMap()));
    final log = p.getStringList(_logK) ?? [];
    log.add('${DateTime.now().toIso8601String()} $note');
    await p.setStringList(_logK, log.take(200).toList());
  }
  static Future<List<String>> log() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList(_logK) ?? [];
  }
}
