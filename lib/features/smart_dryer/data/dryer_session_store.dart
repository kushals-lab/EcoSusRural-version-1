/// Session store: offline-first drying sessions + readings index.
/// SharedPreferences JSON, capped lists, clock-fault tolerant.
library;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/dryer_session.dart';
class DryerSessionStore {
  static const _k = 'smart_dryer.sessions.v1';
  static Future<List<DryerSession>> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_k);
      if (raw == null || raw.isEmpty) return [];
      final l = jsonDecode(raw) as List;
      return l.whereType<Map<String, dynamic>>()
          .map(DryerSession.fromMap).toList();
    } catch (_) { return []; }
  }
  static Future<void> upsert(DryerSession s) async {
    final all = await load();
    final i = all.indexWhere((e) => e.id == s.id);
    if (i >= 0) { all[i] = s; } else { all.add(s); }
    while (all.length > 100) { all.removeAt(0); }
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(all.map((e) => e.toMap()).toList()));
  }
  static Future<DryerSession?> active() async {
    final all = await load();
    for (var i = all.length - 1; i >= 0; i--) {
      if (all[i].endAt == null) return all[i];
    }
    return null;
  }
}
