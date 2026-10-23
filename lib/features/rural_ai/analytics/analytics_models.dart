/// Result models for the rural analytics engine.
library;

/// One district's aggregated annual measurement.
class DistrictAggregation {
  final String district;
  final int year;
  final double rainfallSumMm;
  final double rainfallMeanMm;
  final double tempMeanC;
  final double rainfallYoyPct;
  final bool hasData;
  const DistrictAggregation({
    required this.district,
    required this.year,
    required this.rainfallSumMm,
    required this.rainfallMeanMm,
    required this.tempMeanC,
    required this.rainfallYoyPct,
    required this.hasData,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistrictAggregation &&
          district == other.district &&
          year == other.year &&
          rainfallSumMm == other.rainfallSumMm &&
          rainfallMeanMm == other.rainfallMeanMm &&
          tempMeanC == other.tempMeanC &&
          rainfallYoyPct == other.rainfallYoyPct &&
          hasData == other.hasData;

  @override
  int get hashCode => Object.hash(
      district,
      year,
      rainfallSumMm,
      rainfallMeanMm,
      tempMeanC,
      rainfallYoyPct,
      hasData,
  );
}

/// Forecast reliability (Part 13.2).
class ForecastConfidence {
  final String level; // high | moderate | low | insufficient_evidence
  final String note;
  const ForecastConfidence({required this.level, required this.note});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForecastConfidence &&
          level == other.level &&
          note == other.note;

  @override
  int get hashCode => Object.hash(level, note);
}

/// Deterministic trend summary.
class TrendSummary {
  final bool increasing;
  final double slopePerYear;
  final String description;
  const TrendSummary({
    required this.increasing,
    required this.slopePerYear,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendSummary &&
          increasing == other.increasing &&
          slopePerYear == other.slopePerYear &&
          description == other.description;

  @override
  int get hashCode => Object.hash(increasing, slopePerYear, description);
}

/// Full analytics output for a source-cited answer.
class BankAnalytics {
  final List<DistrictAggregation> yearly;
  final List<DistrictAggregation> monthly;
  final TrendSummary rainfallTrend;
  final ForecastConfidence rainfallForecast;
  final String calculations;
  const BankAnalytics({
    required this.yearly,
    required this.monthly,
    required this.rainfallTrend,
    required this.rainfallForecast,
    required this.calculations,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BankAnalytics) return false;
    if (yearly.length != other.yearly.length || monthly.length != other.monthly.length) {
      return false;
    }
    for (var i = 0; i < yearly.length; i++) {
      if (yearly[i] != other.yearly[i]) return false;
    }
    for (var i = 0; i < monthly.length; i++) {
      if (monthly[i] != other.monthly[i]) return false;
    }
    return rainfallTrend == other.rainfallTrend &&
        rainfallForecast == other.rainfallForecast &&
        calculations == other.calculations;
  }

  @override
  int get hashCode {
    var hash = 17;
    for (final item in yearly) {
      hash = 31 * hash + item.hashCode;
    }
    for (final item in monthly) {
      hash = 31 * hash + item.hashCode;
    }
    hash = 31 * hash + rainfallTrend.hashCode;
    hash = 31 * hash + rainfallForecast.hashCode;
    hash = 31 * hash + calculations.hashCode;
    return hash;
  }
}
