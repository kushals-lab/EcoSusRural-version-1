library translation_repository;

import 'dart:convert';
import 'package:flutter/services.dart';

/// Dialect -> parent fallback for the 40 regional packs.
/// Mirrors kDialectToParent in language_provider.dart and AllLanguages.parentCode.
const Map<String, String> kDialectParents = {
  // English regional variants
  'en-us': 'en',
  'en-gb': 'en',
  'en-in': 'en-gb',
  'en-au': 'en-gb',
  'bho': 'hi',
  'mag': 'hi',
  'ang': 'hi',
  'raj': 'hi',
  'mwr': 'hi',
  'awa': 'hi',
  'braj': 'hi',
  'bund': 'hi',
  'bag': 'hi',
  'cha': 'hi',
  'ngl': 'hi',
  'gon': 'hi',
  'kru': 'hi',
  'kku': 'hi',
  'gdb': 'hi',
  'jns': 'hi',
  'gaar': 'hi',
  'kmn': 'hi',
  'ngp': 'hi',
  'kos': 'hi',
  'var': 'mr',
  'kath': 'gu',
  'kut': 'gu',
  'sau': 'gu',
  'kod': 'kn',
  'tcy': 'kn',
  'mle': 'ml',
  'tnk': 'ta',
  'tnc': 'ta',
  'tod': 'ta',
  'har': 'pa',
  'pah': 'ks',
  'syl': 'bn',
  'trip': 'bn',
  'smb': 'or',
  'kha': 'as',
  'rab': 'as',
  'njl': 'mni',
  'mizo': 'mni',
};

class PackMeta {
  final String code;
  final int version;
  final String sha256;
  const PackMeta({required this.code, required this.version, required this.sha256});
}

class TranslationRepository {
  TranslationRepository._();
  static final TranslationRepository instance = TranslationRepository._();

  final Map<String, Map<String, String>> _cache = {};
  Map<String, PackMeta> _manifest = {};
  int _manifestVersion = 0;

  Future<void> loadManifest() async {
    try {
      final raw = await rootBundle.loadString('assets/lang/manifest.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _manifestVersion = (data['version'] as num?)?.toInt() ?? 0;
      final packs = (data['packs'] as List?) ?? const [];
      final m = <String, PackMeta>{};
      for (final p in packs) {
        final pm = p as Map<String, dynamic>;
        final code = (pm['code'] ?? '').toString();
        if (code.isEmpty) continue;
        m[code] = PackMeta(
          code: code,
          version: (pm['version'] as num?)?.toInt() ?? 0,
          sha256: (pm['sha256'] ?? '').toString(),
        );
      }
      _manifest = m;
    } catch (_) {
      _manifest = {};
    }
  }

  int get manifestVersion => _manifestVersion;
  List<String> get bundledCodes => _manifest.keys.toList()..sort();

  Future<Map<String, String>> packFor(String code) async {
    final c = code.trim().toLowerCase();
    if (_cache.containsKey(c)) return _cache[c]!;
    try {
      final raw = await rootBundle.loadString('assets/lang/$c.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final pack = <String, String>{};
      data.forEach((k, v) {
        if (k == '_meta') return;
        if (v is String) {
          // Identity placeholders ('back': 'back') from older generated packs
          // must never shadow the real bundled/native translations — skip them.
          if (v == k) return;
          pack[k] = v;
        }
      });
      _cache[c] = pack;
      return pack;
    } catch (_) {
      _cache[c] = const {};
      return const {};
    }
  }

  void prime(String code, Map<String, String> pack) {
    _cache[code.trim().toLowerCase()] = Map<String, String>.from(pack);
  }

  /// Prime a pack FROM the engine layer (breaks the provider<->repository cycle).

  /// Synchronous read-only view of a primed pack (never loads from disk).
  Map<String, String> snapshot(String code) {
    return _cache[code.trim().toLowerCase()] ?? const {};
  }

  /// Parent code for a dialect (regional -> official), or null.
  String? parentOf(String code) {
    return kDialectParents[code.trim().toLowerCase()];
  }

  void evict(String code) {
    _cache.remove(code.trim().toLowerCase());
  }
}
