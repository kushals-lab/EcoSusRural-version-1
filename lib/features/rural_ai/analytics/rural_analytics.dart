/// Deterministic rural analytics engine (evidence layer, Part 12.2).
library;

import '../data/example_historical_bank.dart';
import 'analytics_models.dart';
import '../models/data_models.dart';

class RuralAnalytics {
  const RuralAnalytics();

  BankAnalytics compute({Map<String, Map<int, DistrictAnnual>>? bank}) =>
      _compute(bank: bank);
}

const ruralAnalytics = RuralAnalytics();

/// Compute annual + monthly aggregation, trend, and a baseline forecast.
BankAnalytics compute({Map<String, Map<int, DistrictAnnual>>? bank}) =>
    _compute(bank: bank);

BankAnalytics _compute({Map<String, Map<int, DistrictAnnual>>? bank}) {
  final sources = bank ?? ExampleHistoricalBank.build();
  final districtNames = sources.keys.toList();
  final years = sources[districtNames.first]!.keys.toList()..sort();

  // Annual: one row per district-year.
  final yearly = <DistrictAggregation>[];
  for (final y in years) {
    for (final d in districtNames) {
      final r = _row(sources[d]!, y);
      yearly.add(DistrictAggregation(
        district: r.district,
        year: r.year,
        rainfallSumMm: r.rainfallMm.toDouble(),
        rainfallMeanMm: r.rainfallMm.toDouble(),
        tempMeanC: r.meanTempC,
        rainfallYoyPct: 0,
        hasData: true,
      ));
    }
  }
  final yearlyWithYoy = _fillYoy(yearly);

  // Monthly proxy: annual total / 12 (clearly labelled; annual data has no
  // intra-year signal, so a monthly series is derived, not observed).
  final monthly = yearlyWithYoy
      .map((r) => DistrictAggregation(
            district: r.district,
            year: r.year,
            rainfallSumMm: r.rainfallSumMm,
            rainfallMeanMm: r.rainfallSumMm / 12,
            tempMeanC: r.tempMeanC,
            rainfallYoyPct: r.rainfallYoyPct,
            hasData: r.hasData,
          ))
      .toList();

  final trend = _trend(sources, years);
  final forecast = _forecast(sources, years);
  final calc = _calculations(distribution: districtNames);

  return BankAnalytics(
    yearly: yearlyWithYoy,
    monthly: monthly,
    rainfallTrend: trend,
    rainfallForecast: forecast,
    calculations: calc,
  );
}

DistrictAnnual _row(Map<int, DistrictAnnual> bank, int year) {
  final r = bank[year];
  if (r == null) {
    return const DistrictAnnual(
        district: '',
        year: 0,
        rainfallMm: 0,
        meanTempC: 0,
        minTempC: 0,
        maxTempC: 0);
  }
  return r;
}

List<DistrictAggregation> _fillYoy(List<DistrictAggregation> rows) {
  final byKey = <String, Map<int, double>>{};
  for (final r in rows) {
    byKey.putIfAbsent(r.district, () => <int, double>{});
    byKey[r.district]![r.year] = r.rainfallSumMm;
  }
  final out = <DistrictAggregation>[];
  for (final r in rows) {
    final prev = byKey[r.district]?[r.year - 1];
    final yoy =
        prev != null && prev > 0 ? (r.rainfallSumMm - prev) / prev * 100 : 0.0;
    out.add(DistrictAggregation(
      district: r.district,
      year: r.year,
      rainfallSumMm: r.rainfallSumMm,
      rainfallMeanMm: r.rainfallMeanMm,
      tempMeanC: r.tempMeanC,
      rainfallYoyPct: yoy,
      hasData: r.hasData,
    ));
  }
  return out;
}

TrendSummary _trend(
    Map<String, Map<int, DistrictAnnual>> bank, List<int> years) {
  final samples = <({int year, double rainfall})>[];
  for (final d in bank.keys) {
    for (final y in years) {
      final r = bank[d]?[y];
      if (r != null) {
        samples.add((year: y, rainfall: r.rainfallMm.toDouble()));
      }
    }
  }

  if (samples.length < 2) {
    return const TrendSummary(
      increasing: false,
      slopePerYear: 0,
      description: 'Insufficient annual observations.',
    );
  }

  final n = samples.length;
  double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
  for (final sample in samples) {
    final x = sample.year.toDouble();
    final y = sample.rainfall;
    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumXX += x * x;
  }

  final denominator = n * sumXX - sumX * sumX;
  final slope =
      denominator == 0 ? 0.0 : (n * sumXY - sumX * sumY) / denominator;

  return TrendSummary(
    increasing: slope > 0,
    slopePerYear: slope,
    description: slope >= 0
        ? 'Precipitation trend rising (${slope.toStringAsFixed(1)} mm/year over sample).'
        : 'Precipitation trend falling (${slope.abs().toStringAsFixed(1)} mm/year over sample).',
  );
}

ForecastConfidence _forecast(
    Map<String, Map<int, DistrictAnnual>> bank, List<int> years) {
  final count = bank.values.expand((m) => m.values).length;
  if (count < 20) {
    return const ForecastConfidence(
        level: 'insufficient_evidence',
        note: 'Fewer than 20 observations; no baseline forecast produced.');
  }
  final all = <double>[];
  for (final m in bank.values) {
    for (final r in m.values) {
      all.add(r.rainfallMm.toDouble());
    }
  }
  final mean = all.isEmpty ? 0 : all.reduce((a, b) => a + b) / all.length;
  final fy = years.isNotEmpty ? years.last + 1 : 2026;
  return ForecastConfidence(
    level: all.length >= 10 ? 'moderate' : 'low',
    note:
        'Naive seasonal-baseline forecast $fy: mean annual rainfall ${mean.toStringAsFixed(0)} mm (baseline only).',
  );
}

String _calculations({required List<String> distribution}) {
  return 'Formulas: Sum=sample total; MoM/12=annual/12; YoY=(cur-prev)/prev*100; '
      'trend=OLS slope; baselineForecast=prior-year mean (naive). '
      'Distribution: ${distribution.join(', ')}. '
      'Source: ExampleHistoricalBank (synthetic dev dataset).';
}
