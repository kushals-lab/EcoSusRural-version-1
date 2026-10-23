/// Drying batch + profile catalogue. Pure Dart.
library;
class DryerBatch {
  final String id;
  final String cropType;
  final String? customCropName;
  final double initialMassKg;
  final double? initialMoisturePct;
  final double? targetMoisturePct;
  final String profileId;
  final String operatorNotes;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? finalMassKg;
  final double? finalMoisturePct;
  final bool experimental;
  const DryerBatch({
    required this.id, required this.cropType, this.customCropName,
    required this.initialMassKg, this.initialMoisturePct,
    this.targetMoisturePct, required this.profileId,
    this.operatorNotes = '', required this.createdAt,
    this.startedAt, this.completedAt, this.finalMassKg,
    this.finalMoisturePct, this.experimental = false,
  });
  String get displayCrop => cropType == 'custom' &&
      (customCropName ?? '').isNotEmpty ? customCropName! : cropType;
  Map<String, dynamic> toMap() => {
    'id': id, 'cropType': cropType, 'customCropName': customCropName,
    'initialMassKg': initialMassKg, 'initialMoisturePct': initialMoisturePct,
    'targetMoisturePct': targetMoisturePct, 'profileId': profileId,
    'operatorNotes': operatorNotes, 'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'finalMassKg': finalMassKg, 'finalMoisturePct': finalMoisturePct,
    'experimental': experimental,
  };
  factory DryerBatch.fromMap(Map<String, dynamic> m) => DryerBatch(
    id: '${m['id'] ?? ''}', cropType: '${m['cropType'] ?? 'custom'}',
    customCropName: m['customCropName'] as String?,
    initialMassKg: (m['initialMassKg'] as num?)?.toDouble() ?? 0,
    initialMoisturePct: (m['initialMoisturePct'] as num?)?.toDouble(),
    targetMoisturePct: (m['targetMoisturePct'] as num?)?.toDouble(),
    profileId: '${m['profileId'] ?? 'gentle'}',
    operatorNotes: '${m['operatorNotes'] ?? ''}',
    createdAt: DateTime.tryParse('${m['createdAt']}') ?? DateTime.now(),
    startedAt: m['startedAt'] == null ? null
        : DateTime.tryParse('${m['startedAt']}'),
    completedAt: m['completedAt'] == null ? null
        : DateTime.tryParse('${m['completedAt']}'),
    finalMassKg: (m['finalMassKg'] as num?)?.toDouble(),
    finalMoisturePct: (m['finalMoisturePct'] as num?)?.toDouble(),
    experimental: m['experimental'] == true,
  );
}
class DryerProfile {
  final String id;
  final String title;
  final double maxChamberTempC;
  final double targetChamberTempC;
  final int fanPwmPct;
  final bool experimental;
  final String note;
  const DryerProfile({
    required this.id, required this.title,
    required this.maxChamberTempC, required this.targetChamberTempC,
    required this.fanPwmPct, this.experimental = false, this.note = '',
  });
}
const List<DryerProfile> kDryerProfiles = [
  DryerProfile(id: 'gentle', title: 'Gentle (leafy veg / herbs)',
      maxChamberTempC: 45, targetChamberTempC: 40, fanPwmPct: 60,
      note: 'Conservative default for delicate produce.'),
  DryerProfile(id: 'standard', title: 'Standard (chillies / tomatoes)',
      maxChamberTempC: 55, targetChamberTempC: 50, fanPwmPct: 70,
      note: 'General-purpose solar drying.'),
  DryerProfile(id: 'high', title: 'High airflow (onion / mango)',
      maxChamberTempC: 60, targetChamberTempC: 55, fanPwmPct: 85,
      experimental: true,
      note: 'EXPERIMENTAL - validate with a thermometer before food use.'),
];
const List<String> kDryerCrops = [
  'chillies', 'tomatoes', 'onions', 'leafy', 'mango', 'custom',
];
