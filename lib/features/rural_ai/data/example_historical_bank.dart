/// Reproducible example historical bank for development and demonstration.
///
/// RE\(?S\bMENT LABEL: This file contains a synthetic, deterministically
/// generated development dataset. It is NOT verified national statistics and
/// must never be presented as such in any answer. It exists so the platform can
/// demonstrate: search, aggregation, trend analysis, a baseline forecast, and a
/// reproducible source-cited answer while the real connectors (IMD, AGMARKNET,
/// etc.) are implemented.
///
/// Deterministic RNG keeps the demo identical across launches so tests are
/// reproducible.
library;

import '../models/data_models.dart';

/// Example rural districts used as a reproducible sample.
class ExampleHistoricalBank {
  static const List<String> _districts = [
    'Example District A',
    'Example District B',
    'Example District C',
  ];

  /// Build one [DistrictAnnual] per district-year (2016-2025) with deterministic
  /// spread. Produce the seed-free demo bank when called from the analytics.
  static Map<String, Map<int, DistrictAnnual>> build() {
    final out = <String, Map<int, DistrictAnnual>>{};
    for (final d in _districts) {
      final bank = <int, DistrictAnnual>{};
      for (int y = 2016; y <= 2025; y++) {
        final rain = _clampInt(900 + ((d.hashCode + y * 7) % 600) - 200, 400, 1600);
        final min = 12.0 + (d.hashCode % 3) * 0.8 + ((17 - y) % 4) * 0.7;
        final spread = _clampInt(3 + (d.hashCode % 4), 2, 8).toDouble();
        bank[y] = DistrictAnnual(
          district: d,
          year: y,
          rainfallMm: rain,
          minTempC: min.roundToDouble(),
          maxTempC: (min + spread).roundToDouble(),
          meanTempC: (min + spread / 2).roundToDouble(),
        );
      }
      out[d] = bank;
    }
    return out;
  }

  static int _clampInt(int v, int lo, int hi) {
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
  }
}
