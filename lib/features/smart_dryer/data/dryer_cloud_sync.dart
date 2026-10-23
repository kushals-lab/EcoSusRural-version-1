/// Optional cloud sync: local-first, sync only when enabled + online.
/// No secrets in source. Backend: /api/dryer/* when configured.
library;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/dryer_batch.dart';
import 'dryer_history_store.dart';
class DryerCloudSync {
  static const _enK = 'smart_dryer.cloud.enabled';
  static const _urlK = 'smart_dryer.cloud.baseUrl';
  static Future<bool> enabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_enK) ?? false;
  }
  static Future<void> setEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_enK, v);
  }
  static Future<String> baseUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_urlK) ?? '';
  }
  static Future<void> setBaseUrl(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_urlK, v);
  }
  static Future<String> pushBatch(DryerBatch b) async {
    if (!await enabled()) return 'cloud disabled (local-only)';
    final base = await baseUrl();
    if (base.isEmpty) return 'no cloud URL configured';
    try {
      final r = await http.post(Uri.parse('$base/api/dryer/batches'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(b.toMap())).timeout(
          const Duration(seconds: 8));
      if (r.statusCode >= 200 && r.statusCode < 300) return 'synced';
      return 'server ${r.statusCode}';
    } catch (e) {
      return 'offline: $e';
    }
  }
  static Future<String> pushAll() async {
    final all = await DryerHistoryStore.loadBatches();
    if (all.isEmpty) return 'nothing to sync';
    var ok = 0; var fail = 0;
    for (final b in all) {
      final s = await pushBatch(b);
      if (s == 'synced') { ok++; } else { fail++; }
    }
    return 'synced $ok, pending $fail (local copy kept)';
  }
}
