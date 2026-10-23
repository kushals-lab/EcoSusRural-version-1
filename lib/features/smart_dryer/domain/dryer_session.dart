/// Drying session record: time-complete vs certified-dry distinction.
/// Pure Dart.
library;
class DryerSession {
  final String id;
  final String deviceId;
  final String cropProfileId;
  final String profileVersion;
  final String cropName;
  final DateTime? startAt;
  final DateTime? endAt;
  final double targetMinC;
  final double targetMaxC;
  final double absMaxC;
  final List<String> pauseHistory;
  final List<String> warnings;
  final String endState; // running|paused|time_complete|stopped|fault
  final bool moistureMeasured; // false => time-complete only
  const DryerSession({required this.id, required this.deviceId,
    required this.cropProfileId, required this.profileVersion,
    required this.cropName, this.startAt, this.endAt,
    required this.targetMinC, required this.targetMaxC,
    required this.absMaxC, this.pauseHistory = const [],
    this.warnings = const [], this.endState = 'running',
    this.moistureMeasured = false});
  double elapsedMin(DateTime now) {
    if (startAt == null) return 0;
    return now.difference(startAt!).inSeconds / 60.0;
  }
  String completionLabel() {
    if (moistureMeasured) {
      return 'Certified (final moisture/water-activity measured)';
    }
    return 'Time-complete (NOT certified dry — verify moisture)';
  }
  Map<String, dynamic> toMap() => {'id': id, 'deviceId': deviceId,
    'cropProfileId': cropProfileId, 'profileVersion': profileVersion,
    'cropName': cropName, 'startAt': startAt?.toIso8601String(),
    'endAt': endAt?.toIso8601String(), 'targetMinC': targetMinC,
    'targetMaxC': targetMaxC, 'absMaxC': absMaxC,
    'pauseHistory': pauseHistory, 'warnings': warnings,
    'endState': endState, 'moistureMeasured': moistureMeasured};
  factory DryerSession.fromMap(Map<String, dynamic> m) => DryerSession(
    id: '${m['id'] ?? ''}', deviceId: '${m['deviceId'] ?? ''}',
    cropProfileId: '${m['cropProfileId'] ?? ''}',
    profileVersion: '${m['profileVersion'] ?? '1'}',
    cropName: '${m['cropName'] ?? ''}',
    startAt: m['startAt'] == null ? null
      : DateTime.tryParse('${m['startAt']}'),
    endAt: m['endAt'] == null ? null
      : DateTime.tryParse('${m['endAt']}'),
    targetMinC: (m['targetMinC'] as num?)?.toDouble() ?? 40,
    targetMaxC: (m['targetMaxC'] as num?)?.toDouble() ?? 50,
    absMaxC: (m['absMaxC'] as num?)?.toDouble() ?? 60,
    pauseHistory: (m['pauseHistory'] as List?)
      ?.map((e) => '$e').toList() ?? [],
    warnings: (m['warnings'] as List?)
      ?.map((e) => '$e').toList() ?? [],
    endState: '${m['endState'] ?? 'running'}',
    moistureMeasured: m['moistureMeasured'] == true);
}
