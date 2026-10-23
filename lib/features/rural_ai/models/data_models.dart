/// Core data models for Rural Intelligence (definitional models only).
library;

/// A district-year record used for historical trend analysis (Part 2.2).
class DistrictAnnual {
  final String district;
  final int year;
  final int rainfallMm;
  final double meanTempC;
  final double minTempC;
  final double maxTempC;
  const DistrictAnnual({
    required this.district,
    required this.year,
    required this.rainfallMm,
    required this.meanTempC,
    required this.minTempC,
    required this.maxTempC,
  });
}

/// Dataset registry entry (Central Data Catalog, Part 11.1).
class DatasetEntry {
  final String id;
  final String name;
  final String provider;
  final String sourceUrl;
  final String accessType;
  final String? authRequirements;
  final String license;
  final int? earliestYear;
  final int? latestYear;
  final int observationCount;
  final String unit;
  final String geographicLevel;
  final String temporalResolution;
  final String? updateSchedule;
  final String? lastIngested;
  final String qualityStatus;
  final String knownLimitations;
  final String responsibleModule;

  const DatasetEntry({
    required this.id,
    required this.name,
    required this.provider,
    required this.sourceUrl,
    required this.accessType,
    this.authRequirements,
    required this.license,
    this.earliestYear,
    this.latestYear,
    required this.observationCount,
    required this.unit,
    required this.geographicLevel,
    required this.temporalResolution,
    this.updateSchedule,
    this.lastIngested,
    required this.qualityStatus,
    required this.knownLimitations,
    required this.responsibleModule,
  });

  DatasetEntry copyWith({
    String? id,
    String? name,
    String? provider,
    String? sourceUrl,
    String? accessType,
    String? authRequirements,
    String? license,
    int? earliestYear,
    int? latestYear,
    int? observationCount,
    String? unit,
    String? geographicLevel,
    String? temporalResolution,
    String? updateSchedule,
    String? lastIngested,
    String? qualityStatus,
    String? knownLimitations,
    String? responsibleModule,
  }) => DatasetEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    provider: provider ?? this.provider,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    accessType: accessType ?? this.accessType,
    authRequirements: authRequirements ?? this.authRequirements,
    license: license ?? this.license,
    earliestYear: earliestYear ?? this.earliestYear,
    latestYear: latestYear ?? this.latestYear,
    observationCount: observationCount ?? this.observationCount,
    unit: unit ?? this.unit,
    geographicLevel: geographicLevel ?? this.geographicLevel,
    temporalResolution: temporalResolution ?? this.temporalResolution,
    updateSchedule: updateSchedule ?? this.updateSchedule,
    lastIngested: lastIngested ?? this.lastIngested,
    qualityStatus: qualityStatus ?? this.qualityStatus,
    knownLimitations: knownLimitations ?? this.knownLimitations,
    responsibleModule: responsibleModule ?? this.responsibleModule,
  );
}

/// Dataset quality / coverage assessment (Part 2.2 matrix).
enum CoverageClass {
  twentyPlusYears,
  tenToNineteenYears,
  fiveToNineYears,
  lessThanFiveYears,
  irregular,
  unavailable,
}

class DatasetAssessment {
  final DatasetEntry entry;
  final CoverageClass coverageClass;
  final bool continuousHistory;
  final int observedYears;
  final int? missingPeriods;
  final String gapNote;
  final bool hasRevisionHistory;

  const DatasetAssessment({
    required this.entry,
    required this.coverageClass,
    required this.continuousHistory,
    required this.observedYears,
    this.missingPeriods,
    required this.gapNote,
    required this.hasRevisionHistory,
  });

  static const Map<CoverageClass, String> _labels = {
    CoverageClass.twentyPlusYears: '~20+ years',
    CoverageClass.tenToNineteenYears: '10-19 years',
    CoverageClass.fiveToNineYears: '5-9 years',
    CoverageClass.lessThanFiveYears: '<5 years',
    CoverageClass.irregular: 'irregular observations',
    CoverageClass.unavailable: 'not available',
  };

  String get coverageLabel => _labels[coverageClass] ?? 'unknown';

  String get summary {
    var sb =
        'Coverage class: $coverageLabel. Continuous history: $continuousHistory. '
        'Observed years: $observedYears. Missing periods: $missingPeriods. '
        'Revision history: $hasRevisionHistory.';
    if (missingPeriods != null) {
      sb += ' Gap note: $gapNote.';
    }
    return sb;
  }
}
