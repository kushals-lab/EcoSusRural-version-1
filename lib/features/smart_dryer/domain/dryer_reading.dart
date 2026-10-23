/// Smart Dryer telemetry snapshot. Pure Dart, no Flutter import.
/// v2: adds inlet/exhaust/battery while keeping v1 fields for compat.
library;
class DryerReading {
  final double? collectorTempC;
  final double? chamberTempC;
  final double? ambientTempC;
  final double? chamberRhPct;
  final double? ambientRhPct;
  final double? airflowM3h;
  final bool? fanOn;
  final int? fanPwmPct;
  final String? ventState;
  final DateTime receivedAt;
  final bool fromDemo;
  // v2 additions (all optional, null = unavailable, never zero-fill).
  final double? inletTempC;
  final double? exhaustTempC;
  final double? exhaustRhPct;
  final double? batteryVoltageV;
  final double? batterySocPct;
  final bool? charging;
  final String? mode;
  final String? bayId;
  const DryerReading({
    this.collectorTempC, this.chamberTempC, this.ambientTempC,
    this.chamberRhPct, this.ambientRhPct, this.airflowM3h,
    this.fanOn, this.fanPwmPct, this.ventState,
    required this.receivedAt, this.fromDemo = false,
    this.inletTempC, this.exhaustTempC, this.exhaustRhPct,
    this.batteryVoltageV, this.batterySocPct, this.charging,
    this.mode, this.bayId,
  });
  double? get internalTempC => chamberTempC;
  double? get internalRhPct => chamberRhPct;
  Map<String, dynamic> toMap() => {
    'collectorTempC': collectorTempC, 'chamberTempC': chamberTempC,
    'ambientTempC': ambientTempC, 'chamberRhPct': chamberRhPct,
    'ambientRhPct': ambientRhPct, 'airflowM3h': airflowM3h,
    'fanOn': fanOn, 'fanPwmPct': fanPwmPct, 'ventState': ventState,
    'receivedAt': receivedAt.toIso8601String(), 'fromDemo': fromDemo,
    'inletTempC': inletTempC, 'exhaustTempC': exhaustTempC,
    'exhaustRhPct': exhaustRhPct, 'batteryVoltageV': batteryVoltageV,
    'batterySocPct': batterySocPct, 'charging': charging,
    'mode': mode, 'bayId': bayId,
  };
  factory DryerReading.fromMap(Map<String, dynamic> m) => DryerReading(
    collectorTempC: (m['collectorTempC'] as num?)?.toDouble(),
    chamberTempC: (m['chamberTempC'] as num?)?.toDouble(),
    ambientTempC: (m['ambientTempC'] as num?)?.toDouble(),
    chamberRhPct: (m['chamberRhPct'] as num?)?.toDouble(),
    ambientRhPct: (m['ambientRhPct'] as num?)?.toDouble(),
    airflowM3h: (m['airflowM3h'] as num?)?.toDouble(),
    fanOn: m['fanOn'] as bool?,
    fanPwmPct: (m['fanPwmPct'] as num?)?.toInt(),
    ventState: m['ventState'] as String?,
    receivedAt: DateTime.tryParse('${m['receivedAt']}') ?? DateTime.now(),
    fromDemo: m['fromDemo'] == true,
    inletTempC: (m['inletTempC'] as num?)?.toDouble(),
    exhaustTempC: (m['exhaustTempC'] as num?)?.toDouble(),
    exhaustRhPct: (m['exhaustRhPct'] as num?)?.toDouble(),
    batteryVoltageV: (m['batteryVoltageV'] as num?)?.toDouble(),
    batterySocPct: (m['batterySocPct'] as num?)?.toDouble(),
    charging: m['charging'] as bool?,
    mode: m['mode'] as String?,
    bayId: m['bayId'] as String?,
  );
}

