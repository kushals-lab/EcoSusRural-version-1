/// Master dataset catalog (Part 11.1) + coverage report (Part 2.2 matrix).
library;

import '../models/data_models.dart';

/// Master catalog of every dataset the platform intends to integrate.
class RuralDataRegistry {
  RuralDataRegistry._();

  static const Map<String, DatasetEntry> _entries = <String, DatasetEntry>{
    'weather_historical': DatasetEntry(
      id: 'weather_historical',
      name: 'Historical Weather Observations (rainfall, temperature, humidity)',
      provider: 'India Meteorological Department (IMD) + Open-Meteo (archive)',
      sourceUrl: 'https://www.data.gov.in/',
      accessType: 'api',
      authRequirements: 'IMD manual download / keyless Open-Meteo',
      license: 'Public domain (IMD) / CC-BY (Open-Meteo)',
      earliestYear: 2016,
      latestYear: 2030,
      observationCount: 0,
      unit: 'mm / C / %RH',
      geographicLevel: 'District / tehsil / grid',
      temporalResolution: 'Daily / monthly aggregates',
      updateSchedule: 'Weekly reanalysis refresh',
      lastIngested: '2026-10-15',
      qualityStatus: 'Awaiting ingestion run',
      knownLimitations: 'Missing station data must be distinguished from zero; daily-to-annual aggregation needs documented defaults.',
      responsibleModule: 'rural_ai.weather_analytics',
    ),
    'commodity_prices': DatasetEntry(
      id: 'commodity_prices',
      name: 'Wholesale market arrivals and prices',
      provider: 'NAFED / AGMARKNET / e-NAM',
      sourceUrl: 'https://enam.gov.in/',
      accessType: 'api',
      authRequirements: 'Registration key',
      license: 'Open (access varies by market)',
      earliestYear: 2019,
      latestYear: 2026,
      observationCount: 0,
      unit: 'INR/quintal',
      geographicLevel: 'Mandi / market',
      temporalResolution: 'Daily arrivals, weekly prices',
      updateSchedule: 'Daily',
      lastIngested: '2026-10-15',
      qualityStatus: 'Awaiting ingestion run',
      knownLimitations: 'Mandi coverage varies; some markets lack trading data.',
      responsibleModule: 'rural_ai.market_analytics',
    ),
    'government_schemes': DatasetEntry(
      id: 'government_schemes',
      name: 'Government schemes and advisories',
      provider: 'Rural Development / Agriculture Ministries',
      sourceUrl: 'https://manuportal.gov.in/',
      accessType: 'manual',
      authRequirements: 'Official portals',
      license: 'Official documents',
      earliestYear: 2020,
      latestYear: 2026,
      observationCount: 0,
      unit: 'program records',
      geographicLevel: 'State / district',
      temporalResolution: 'As published',
      updateSchedule: 'Continuous',
      lastIngested: '2026-10-15',
      qualityStatus: 'Awaiting ingestion run',
      knownLimitations: 'Time-sensitive details must be rechecked; never guarantee approval.',
      responsibleModule: 'rural_ai.scheme_service',
    ),
    'crop_production': DatasetEntry(
      id: 'crop_production',
      name: 'Crop acreage, yield and production',
      provider: 'Ministry of Agriculture',
      sourceUrl: 'https://agricoop.gov.in/',
      accessType: 'download',
      authRequirements: 'Registrations',
      license: 'Public',
      earliestYear: 2016,
      latestYear: 2025,
      observationCount: 0,
      unit: 'hectares / tonnes',
      geographicLevel: 'District / state',
      temporalResolution: 'Annual',
      updateSchedule: 'Seasonal',
      lastIngested: '2026-10-15',
      qualityStatus: 'Awaiting ingestion run',
      knownLimitations: 'Post-harvest revision history must be preserved.',
      responsibleModule: 'rural_ai.crop_analytics',
    ),
    'marketplace_events': DatasetEntry(
      id: 'marketplace_events',
      name: 'EcoSusRural marketplace events',
      provider: 'EcoSusRural platform (anonymised)',
      sourceUrl: 'Internal API',
      accessType: 'api',
      authRequirements: 'Authenticated service account',
      license: 'Private - aggregation only',
      earliestYear: 2025,
      latestYear: 2026,
      observationCount: 0,
      unit: 'events',
      geographicLevel: 'District',
      temporalResolution: 'Real-time / weekly',
      updateSchedule: 'Continuous',
      lastIngested: '2026-10-15',
      qualityStatus: 'Awaiting ingestion run',
      knownLimitations: 'Individual records are anonymised; no private user data exposed.',
      responsibleModule: 'marketplace.ai',
    ),
  };

  static DatasetEntry getBy(String id) {
    final entry = _entries[id];
    if (entry != null) {
      return entry;
    }
    throw ArgumentError.value(id, 'id', 'Unknown dataset id');
  }

  static List<DatasetEntry> get all {
    return _entries.values.toList();
  }

  /// Quality & coverage report matching Part 2.2 matrix (coverageLabel per class).
  static List<DatasetAssessment> coverageReport() {
    final out = <DatasetAssessment>[];
    for (final e in _entries.values) {
      if (e.earliestYear != null && e.latestYear != null && e.latestYear! - e.earliestYear! >= 20) {
        out.add(DatasetAssessment(
          entry: e,
          coverageClass: CoverageClass.twentyPlusYears,
          continuousHistory: false,
          observedYears: e.latestYear! - e.earliestYear!,
          missingPeriods: 3,
          gapNote: 'Gaps pending ingestion.',
          hasRevisionHistory: false,
        ));
      } else {
        out.add(DatasetAssessment(
          entry: e,
          coverageClass: CoverageClass.lessThanFiveYears,
          continuousHistory: false,
          observedYears: 1,
          missingPeriods: null,
          gapNote: 'Ranked by availability; gap detail pending ingestion.',
          hasRevisionHistory: false,
        ));
      }
    }
    return out;
  }
}
