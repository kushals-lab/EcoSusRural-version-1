library translation_engine;

class EngineResult {
  final String text;
  final bool explained;
  const EngineResult(this.text, {this.explained = false});
}

class TranslationEngine {
  final Map<String, String> pack;
  final Map<String, String> parentPack;

  /// Regional group fallback (e.g. Hindi for Indian languages) checked
  /// after the direct parent, before the global English pack.
  final List<Map<String, String>> fallbackPacks;
  final Map<String, String> enPack;
  final Map<String, Map<String, String>> glossary;
  final String code;
  const TranslationEngine({
    required this.pack,
    required this.parentPack,
    required this.enPack,
    required this.glossary,
    required this.code,
    this.fallbackPacks = const [],
  });

  EngineResult resolve(String key, [Map<String, String>? params]) {
    String? hit = pack[key] ?? parentPack[key];
    if (hit == null) {
      for (final fb in fallbackPacks) {
        hit = fb[key];
        if (hit != null) break;
      }
    }
    hit ??= enPack[key];
    if (hit != null) return EngineResult(_fill(hit, params));
    final g = glossary[key];
    if (g != null) {
      final exp = g[code] ?? g['en'];
      if (exp != null && exp.isNotEmpty) {
        return EngineResult(exp, explained: true);
      }
    }
    return EngineResult(_fill(key, params), explained: true);
  }

  String _fill(String t, Map<String, String>? p) {
    if (p == null || p.isEmpty) return t;
    var out = t;
    p.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }

  String single(String key, [Map<String, String>? params]) {
    return resolve(key, params).text;
  }

  Map<String, String> bundle(Iterable<String> keys) {
    final m = <String, String>{};
    for (final k in keys) {
      m[k] = resolve(k).text;
    }
    return m;
  }
}
