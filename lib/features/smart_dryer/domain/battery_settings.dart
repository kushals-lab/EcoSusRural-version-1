/// Battery + device settings models. Pure Dart.
library;
class BatteryStatus {
  final double? voltageV;
  final double? socPct;
  final bool? charging;
  final String level; // ok | low | critical | unknown
  const BatteryStatus({this.voltageV, this.socPct,
    this.charging, this.level = 'unknown'});
  Map<String, dynamic> toMap() => {'v': voltageV,
    'soc': socPct, 'charging': charging, 'level': level};
}
class DryerDeviceSettings {
  final String deviceName;
  final String deviceId;
  final double tempOffsetC;
  final double rhOffsetPct;
  final bool metric;
  final bool notifyAlerts;
  const DryerDeviceSettings({this.deviceName = 'EcoDryer',
    this.deviceId = 'DRYER-01', this.tempOffsetC = 0,
    this.rhOffsetPct = 0, this.metric = true,
    this.notifyAlerts = true});
  Map<String, dynamic> toMap() => {'name': deviceName,
    'id': deviceId, 'tOff': tempOffsetC, 'rhOff': rhOffsetPct,
    'metric': metric, 'notify': notifyAlerts};
  factory DryerDeviceSettings.fromMap(Map<String, dynamic> m) =>
    DryerDeviceSettings(
      deviceName: '${m['name'] ?? 'EcoDryer'}',
      deviceId: '${m['id'] ?? 'DRYER-01'}',
      tempOffsetC: (m['tOff'] as num?)?.toDouble() ?? 0,
      rhOffsetPct: (m['rhOff'] as num?)?.toDouble() ?? 0,
      metric: m['metric'] != false,
      notifyAlerts: m['notify'] != false);
}
