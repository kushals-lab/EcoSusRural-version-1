/// Dryer wire protocol v1 (JSON envelope, BLE-chunk safe).
library;
import 'dart:convert';
import '../domain/dryer_alert.dart';
import '../domain/dryer_reading.dart';
import '../domain/dryer_state.dart';
import '../domain/dryer_simulation.dart';
class DryerProtocol {
  static const String version = '1';
  static const int staleAfterSec = 30;
  static Map<String, dynamic> hello(String deviceId) => {
    'v': version, 'type': 'hello', 'deviceId': deviceId,
    'ts': DateTime.now().toUtc().toIso8601String(),
  };
  static Map<String, dynamic> command({
    required int seq, required String cmd, Map<String, dynamic>? args,
  }) => {
    'v': version, 'type': 'cmd', 'seq': seq, 'cmd': cmd,
    if (args != null) 'args': args,
  };
  static ({bool ok, String reason}) checkEnvelope(Map<String, dynamic> m) {
    if ('${m['v']}' != version) {
      return (ok: false, reason: 'protocol v${m['v']} != v$version');
    }
    if (m['type'] == null) return (ok: false, reason: 'missing type');
    return (ok: true, reason: 'ok');
  }
  static DryerReading? parseTelemetry(Map<String, dynamic> m) {
    if (m['type'] != 'telemetry') return null;
    final d = m['data'];
    if (d is! Map<String, dynamic>) return null;
    num? n(String k) => d[k] is num ? d[k] as num : null;
    return DryerReading(
      collectorTempC: n('collectorC')?.toDouble(),
      chamberTempC: n('chamberC')?.toDouble(),
      ambientTempC: n('ambientC')?.toDouble(),
      chamberRhPct: n('chamberRh')?.toDouble(),
      ambientRhPct: n('ambientRh')?.toDouble(),
      airflowM3h: n('airflow')?.toDouble(),
      fanOn: d['fanOn'] as bool?,
      fanPwmPct: n('fanPwm')?.toInt(),
      ventState: d['vent']?.toString(),
      receivedAt: DateTime.tryParse(m['ts']?.toString() ?? '') ?? DateTime.now(),
      fromDemo: m['simulated'] == true || d['simulation'] is Map,
      simulation: d['simulation'] is Map ? DryerSimulationSnapshot.fromMap(Map<String, dynamic>.from(d['simulation'] as Map)) : null,
      // v2 optional fields (null = unavailable, never zero-fill).
      inletTempC: n('inletC')?.toDouble(),
      exhaustTempC: n('exhaustC')?.toDouble(),
      exhaustRhPct: n('exhaustRh')?.toDouble(),
      batteryVoltageV: n('battV')?.toDouble() ?? n('batteryV')?.toDouble(),
      batterySocPct: n('battSoc')?.toDouble() ?? n('soc')?.toDouble(),
      charging: d['charging'] as bool?,
      mode: d['mode']?.toString() ?? d['state']?.toString(),
      bayId: d['bay']?.toString() ?? d['bayId']?.toString(),
    );
  }
  static DryerState parseState(Map<String, dynamic> m) {
    if (m['type'] == 'state') {
      return DryerStateX.fromWire('${m['state']}');
    }
    if (m['type'] == 'telemetry') {
      final d = m['data'];
      if (d is Map<String, dynamic>) {
        return DryerStateX.fromWire('${d['state'] ?? m['state']}');
      }
    }
    return DryerState.unknown;
  }
  static DryerAlert? parseAlert(Map<String, dynamic> m) {
    if (m['type'] != 'alert' && m['type'] != 'fault') return null;
    return DryerAlert(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      code: '${m['code'] ?? 'controller_fault'}',
      message: '${m['message'] ?? m['code'] ?? 'Controller fault'}',
      raisedAt: DateTime.now(), fromController: true,
    );
  }
  static bool isAckFor(Map<String, dynamic> m, int seq) =>
      (m['type'] == 'ack' || m['type'] == 'ack_cmd') &&
      (m['seq'] as num?)?.toInt() == seq;
  static String encode(Map<String, dynamic> m) => jsonEncode(m);
  static Map<String, dynamic>? decode(String s) {
    try {
      final v = jsonDecode(s);
      return v is Map<String, dynamic> ? v : null;
    } catch (_) { return null; }
  }
  static List<String> chunkForBle(String payload, [int mtu = 180]) {
    final out = <String>[];
    for (var i = 0; i < payload.length; i += mtu) {
      final end = (i + mtu < payload.length) ? i + mtu : payload.length;
      out.add(payload.substring(i, end));
    }
    return out;
  }
}
