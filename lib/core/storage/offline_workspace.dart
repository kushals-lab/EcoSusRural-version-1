import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/account_sync.dart';

/// An account-scoped, idempotent metadata outbox. Orders/payments cannot enter it.
class OfflineWorkspace {
  static Future<void>? _syncing;
  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();
  static String account(SharedPreferences p) => (p.getString('ecosus.auth.user') ?? 'guest').split('|').first;
  static String _key(SharedPreferences p) => 'ecosus.offline.${account(p)}';
  static List<Map<String, dynamic>> _read(SharedPreferences p) {
    try { return (jsonDecode(p.getString(_key(p)) ?? '[]') as List).map((j) => Map<String, dynamic>.from(j)).toList(); }
    catch (_) { return []; }
  }
  static Future<List<Map<String, dynamic>>> records() async => _read(await _prefs());
  static Future<void> save(String kind, String id, Map<String, dynamic> payload, {bool queued = false}) async {
    if (!['drafts','learning','locations','reminders'].contains(kind)) throw ArgumentError('Unsupported offline record');
    if (kind == 'learning' && queued) throw ArgumentError('Learning material cannot upload');
    final p = await _prefs();
    final list = _read(p)..removeWhere((r) => r['kind'] == kind && r['id'] == id);
    list.add({'kind': kind, 'id': id, 'payload': payload, 'queued': queued,
      'revision': DateTime.now().microsecondsSinceEpoch.toString(), 'savedAt': DateTime.now().toUtc().toIso8601String()});
    await p.setString(_key(p), jsonEncode(list));
  }
  static Future<void> remove(String kind, String id) async {
    final p = await _prefs(); final list = _read(p)..removeWhere((r) => r['kind'] == kind && r['id'] == id);
    await p.setString(_key(p), jsonEncode(list));
  }
  static Future<void> sync() => _syncing ??= _flush().whenComplete(() => _syncing = null);
  static Future<void> _flush() async {
    final p = await _prefs(); final owner = account(p); final key = _key(p);
    if (AccountSync.accountId != owner || AccountSync.accessToken == null) return;
    for (final record in _read(p).where((r) => r['queued'] == true)) {
      if (account(p) != owner || AccountSync.accountId != owner) return;
      final kind = record['kind'] as String;
      final body = kind == 'locations' ? {'purpose': record['id'], 'preference': record['payload']}
        : {'id': record['id'], kind == 'reminders' ? 'metadata' : 'payload': record['payload']};
      try {
        final response = await AccountSync.send(kind, body);
        if (account(p) != owner) return;
        final latest = _read(p);
        for (final r in latest) {
          if (r['id'] == record['id'] && r['kind'] == kind && r['revision'] == record['revision']) {
            r['queued'] = false; r['serverStatus'] = response['status'];
          }
        }
        await p.setString(key, jsonEncode(latest));
      } catch (_) { return; } // Bounded: retry on reconnect/resume, never a tight loop.
    }
  }
}
