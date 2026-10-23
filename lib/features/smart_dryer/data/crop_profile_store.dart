/// Crop profile local store: CRUD + import/export, offline-first.
/// Pure Dart wrapper over SharedPreferences JSON.
library;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/crop_profile.dart';
class CropProfileStore {
  static const _key = 'smart_dryer.crop_profiles.v2';
  static Future<List<CropProfile>> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw == null || raw.isEmpty) {
        final d = defaultCropProfiles();
        await saveAll(d);
        return d;
      }
      final list = jsonDecode(raw) as List;
      final out = list.whereType<Map<String, dynamic>>()
          .map(CropProfile.fromMap).toList();
      return out.isEmpty ? defaultCropProfiles() : out;
    } catch (_) {
      return defaultCropProfiles();
    }
  }
  static Future<void> saveAll(List<CropProfile> v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key,
        jsonEncode(v.map((e) => e.toMap()).toList()));
  }
  static Future<void> upsert(CropProfile c) async {
    final all = await load();
    final i = all.indexWhere((e) => e.id == c.id);
    if (i >= 0) { all[i] = c; } else { all.add(c); }
    await saveAll(all);
  }
  static Future<void> remove(String id) async {
    final all = await load();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }
  static String exportJson(List<CropProfile> v) =>
      jsonEncode(v.map((e) => e.toMap()).toList());
  static List<CropProfile> importJson(String raw) {
    final list = jsonDecode(raw) as List;
    return list.whereType<Map<String, dynamic>>()
        .map(CropProfile.fromMap).toList();
  }
}
