/// Crop profile model: configurable, source-backed.
library;
class CropProfile {
  final String id;
  final String cropName;
  final String? variety;
  final double minTempC;
  final double maxTempC;
  final double absMaxTempC;
  final String airflowMode;
  final int fanPwm;
  final double hoursEst;
  final String notes;
  final double? targetMc;
  final String source;
  final bool verified;
  final DateTime updatedAt;
  final String version;
  const CropProfile({required this.id, required this.cropName,
    this.variety, required this.minTempC, required this.maxTempC,
    required this.absMaxTempC, required this.airflowMode,
    required this.fanPwm, required this.hoursEst,
    this.notes = '', this.targetMc, required this.source,
    required this.verified, required this.updatedAt,
    this.version = '1'});
  bool get provisional => !verified;
  String? validate() {
    if (cropName.trim().isEmpty) return 'Crop name required.';
    if (!(minTempC < maxTempC)) return 'min must be < max.';
    if (!(maxTempC <= absMaxTempC)) return 'max above absolute max.';
    if (absMaxTempC < 30 || absMaxTempC > 85) {
      return 'Absolute max 30..85 C.';
    }
    if (fanPwm < 0 || fanPwm > 100) return 'Fan 0..100.';
    if (hoursEst < 1 || hoursEst > 96) return 'Hours 1..96.';
    return null;
  }
  Map<String, dynamic> toMap() => {'id': id, 'cropName': cropName,
    'variety': variety, 'minTempC': minTempC, 'maxTempC': maxTempC,
    'absMaxTempC': absMaxTempC, 'airflowMode': airflowMode,
    'fanPwm': fanPwm, 'hoursEst': hoursEst, 'notes': notes,
    'targetMc': targetMc, 'source': source, 'verified': verified,
    'updatedAt': updatedAt.toIso8601String(), 'version': version};
  factory CropProfile.fromMap(Map<String, dynamic> m) => CropProfile(
    id: '${m['id'] ?? ''}', cropName: '${m['cropName'] ?? 'Custom'}',
    variety: m['variety'] as String?,
    minTempC: (m['minTempC'] as num?)?.toDouble() ?? 35,
    maxTempC: (m['maxTempC'] as num?)?.toDouble() ?? 50,
    absMaxTempC: (m['absMaxTempC'] as num?)?.toDouble() ?? 60,
    airflowMode: '${m['airflowMode'] ?? 'auto'}',
    fanPwm: (m['fanPwm'] as num?)?.toInt() ?? 70,
    hoursEst: (m['hoursEst'] as num?)?.toDouble() ?? 12,
    notes: '${m['notes'] ?? ''}',
    targetMc: (m['targetMc'] as num?)?.toDouble(),
    source: '${m['source'] ?? 'provisional'}',
    verified: m['verified'] == true,
    updatedAt: DateTime.tryParse('${m['updatedAt']}') ?? DateTime.now(),
    version: '${m['version'] ?? '1'}');
}
List<CropProfile> defaultCropProfiles() {
  final n = DateTime(2026, 1, 1);
  return [
    CropProfile(id: 'mango', cropName: 'Mango', minTempC: 45,
      maxTempC: 55, absMaxTempC: 60, airflowMode: 'high',
      fanPwm: 85, hoursEst: 14, notes: 'Slice 5-8 mm, single layer.',
      targetMc: 15, source: 'Provisional - validate locally',
      verified: false, updatedAt: n),
    CropProfile(id: 'tomato', cropName: 'Tomato', minTempC: 45,
      maxTempC: 55, absMaxTempC: 60, airflowMode: 'medium',
      fanPwm: 70, hoursEst: 13, notes: 'Slice 5-7 mm.',
      targetMc: 12, source: 'Provisional - validate locally',
      verified: false, updatedAt: n),
    CropProfile(id: 'chili', cropName: 'Chili', minTempC: 45,
      maxTempC: 55, absMaxTempC: 60, airflowMode: 'medium',
      fanPwm: 70, hoursEst: 12, notes: 'Uniform size.',
      targetMc: 10, source: 'Provisional - validate locally',
      verified: false, updatedAt: n),
    CropProfile(id: 'herbs', cropName: 'Leafy herbs', minTempC: 30,
      maxTempC: 40, absMaxTempC: 45, airflowMode: 'low',
      fanPwm: 55, hoursEst: 10, notes: 'Thin layer, gentle air.',
      targetMc: 10, source: 'Provisional - validate locally',
      verified: false, updatedAt: n),
  ];
}
