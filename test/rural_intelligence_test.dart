/// Rural Intelligence (evidence layer) regression tests.
///
/// Verifies the deterministic router, the reproducible analytics engine and
/// the data registry. No network, no model, no Gemini API key.
library;

import 'package:eco_sus_rural/features/rural_ai/analytics/rural_analytics.dart';
import 'package:eco_sus_rural/features/rural_ai/data/example_historical_bank.dart';
import 'package:eco_sus_rural/features/rural_ai/data/rural_data_registry.dart';
import 'package:eco_sus_rural/features/rural_ai/models/data_models.dart';
import 'package:eco_sus_rural/features/rural_ai/providers/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuralSearchVerifier (deterministic router)', () {
    test('weather query -> weather_history', () {
      final ev = RuralSearchVerifier.route('What were rainfall patterns over 20 years?');
      expect(ev.intent, 'weather_history');
      expect(ev.sector, 'weather');
    });

    test('price query -> market_search', () {
      final ev = RuralSearchVerifier.route('What are mandi prices for my crop?');
      expect(ev.intent, 'market_search');
      expect(ev.sector, 'prices');
    });

    test('crop query -> agriculture_advisory', () {
      final ev = RuralSearchVerifier.route('Which crops are suitable for my district?');
      expect(ev.intent, 'agriculture_advisory');
      expect(ev.sector, 'agriculture');
    });

    test('scheme query -> scheme_search', () {
      final ev = RuralSearchVerifier.route('Which government schemes are available?');
      expect(ev.intent, 'scheme_search');
      expect(ev.sector, 'schemes');
    });
  });

  group('rural_analytics (reproducible evidence)', () {
    test('returns yearly + monthly rows and reproducible calculations', () {
      final analytics = compute();
      expect(analytics.yearly.length, greaterThan(0));
      expect(analytics.monthly.length, greaterThan(0));
      expect(analytics.rainfallTrend.slopePerYear, isA<num>());
      expect(analytics.rainfallForecast.level, isNotEmpty);
      expect(analytics.calculations, contains('ExampleHistoricalBank'));
    });

    test('deterministic: same bank twice gives identical results', () {
      final first = compute();
      final second = compute();
      expect(first.yearly, equals(second.yearly));
      expect(first.monthly, equals(second.monthly));
      expect(first.calculations, equals(second.calculations));
    });

    test('confidence is honest when data is sparse', () {
      final sparseBank = _sparseBank();
      final analytics = compute(bank: sparseBank);
      expect(analytics.rainfallForecast.level, equals('insufficient_evidence'));
    });
  });

  group('RuralDataRegistry (central catalog)', () {
    test('has the expected datasets', () {
      final ids = RuralDataRegistry.all.map((e) => e.id).toList();
      expect(ids, contains('weather_historical'));
      expect(ids, contains('commodity_prices'));
      expect(ids, contains('government_schemes'));
      expect(ids, contains('crop_production'));
      expect(ids, contains('marketplace_events'));
    });

    test('coverage report classifies each dataset', () {
      final report = RuralDataRegistry.coverageReport();
      expect(report.length, equals(RuralDataRegistry.all.length));
      for (final a in report) {
        expect(a.coverageLabel, isNotEmpty);
        expect(a.summary, contains('Coverage class:'));
      }
    });
  });

  group('ExampleHistoricalBank (synthetic dev dataset)', () {
    test('produces district-year records for every example district', () {
      final bank = ExampleHistoricalBank.build();
      expect(bank.keys, hasLength(3));
      for (final d in bank.keys) {
        expect(bank[d]!.keys, hasLength(10)); // 2016-2025
        for (final y in bank[d]!.keys) {
          final r = bank[d]![y]!;
          expect(r.year, greaterThanOrEqualTo(2016));
          expect(r.rainfallMm, greaterThanOrEqualTo(0));
          expect(r.meanTempC, greaterThanOrEqualTo(r.minTempC));
          expect(r.maxTempC, greaterThanOrEqualTo(r.meanTempC));
        }
      }
    });
  });
}

/// Tiny sparse bank (< 20 observations) to force 'insufficient_evidence'.
Map<String, Map<int, DistrictAnnual>> _sparseBank() {
  final out = <String, Map<int, DistrictAnnual>>{};
  final source = ExampleHistoricalBank.build();
  for (final d in source.keys) {
    out[d] = {2020: source[d]![2020]!, 2021: source[d]![2021]!};
  }
  return out;
}
