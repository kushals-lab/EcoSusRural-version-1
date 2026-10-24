import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Production-ready persistent storage layer for EcoSusRural.
/// Backed by SharedPreferences with in-memory fast caching for instant access.
class LocalStorage {
  static SharedPreferences? _prefs;
  final Map<String, String> _memoryCache = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    _memoryCache[key] = value;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  String? getString(String key) {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    return _prefs?.getString(key);
  }

  /// Store structured JSON models offline with timestamps
  Future<void> setJson(String key, Map<String, dynamic> data) async {
    final payload = {
      'cachedAt': DateTime.now().toIso8601String(),
      'data': data,
    };
    await setString(key, jsonEncode(payload));
  }

  /// Retrieve cached JSON payload with its original cachedAt timestamp
  Map<String, dynamic>? getJson(String key) {
    final raw = getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    _memoryCache.clear();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.clear();
  }
}