/// Repository: owns transport, parses protocol, tracks state/alerts.
library;
import 'dart:async';
import 'ble_transport.dart';
import 'demo_transport.dart';
import 'dryer_history_store.dart';
import 'dryer_protocol.dart';
import 'dryer_transport.dart';
import 'wifi_transport.dart';
import 'simulator_transport.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_batch.dart';
import '../domain/dryer_calculations.dart';
import '../domain/dryer_reading.dart';
import '../domain/dryer_state.dart';
class DryerRepository {
  DryerTransport _transport = DemoDryerTransport();
  StreamSubscription<Map<String, dynamic>>? _sub;
  int _seq = 0;
  final Map<int, Completer<bool>> _pending = {};
  DryerRepository() {
    _attach();
  }
  DryerTransport get transport => _transport;
  final StreamController<DryerReading> readingsCtrl =
      StreamController<DryerReading>.broadcast();
  final StreamController<DryerState> stateCtrl =
      StreamController<DryerState>.broadcast();
  final StreamController<DryerAlert> alertsCtrl =
      StreamController<DryerAlert>.broadcast();
  final StreamController<String> errorsCtrl =
      StreamController<String>.broadcast();
  Stream<DryerReading> get readings => readingsCtrl.stream;
  Stream<DryerState> get states => stateCtrl.stream;
  Stream<DryerAlert> get alerts => alertsCtrl.stream;
  Stream<String> get errors => errorsCtrl.stream;
  DryerReading? lastReading;
  DryerState lastState = DryerState.notConnected;
  DryerBatch? activeBatch;
  void _attach() {
    _sub?.cancel();
    _sub = _transport.incoming.listen(_onMessage, onError: (Object e) {
      errorsCtrl.add('$e');
    });
  }
  void useTransport(DryerTransportKind kind) {
    if (_transport.kind == kind) return;
    _sub?.cancel();
    _transport.dispose();
    for (final pending in _pending.values) { if (!pending.isCompleted) pending.complete(false); }
    _pending.clear();
    _transport = switch (kind) {
      DryerTransportKind.demo => DemoDryerTransport(),
      DryerTransportKind.wifi => WifiDryerTransport(),
      DryerTransportKind.ble => BleDryerTransport(),
      DryerTransportKind.htmlSimulator => SimulatorDryerTransport(),
    };
    lastReading = null;
    activeBatch = null;
    lastState = DryerState.notConnected;
    _attach();
    stateCtrl.add(lastState);
  }
  Future<List<DryerDeviceInfo>> scan() => _transport.scan();
  Future<void> connect(DryerDeviceInfo d) async {
    await _transport.connect(d);
    if (lastReading == null) lastState = DryerState.ready;
    stateCtrl.add(lastState);
  }
  Future<void> disconnect() async {
    await _transport.disconnect();
    lastState = DryerState.notConnected;
    stateCtrl.add(lastState);
  }
  void _onMessage(Map<String, dynamic> m) {
    final env = DryerProtocol.checkEnvelope(m);
    if (!env.ok) { errorsCtrl.add('Protocol: ${env.reason}'); return; }
    if (m['type'] == 'ack' || m['type'] == 'ack_cmd') {
      final seq = (m['seq'] as num?)?.toInt();
      if (seq != null && _pending.containsKey(seq)) {
        _pending.remove(seq)?.complete(m['accepted'] != false);
      }
      return;
    }
    if (m['type'] == 'error') {
      errorsCtrl.add('${m['message'] ?? 'device error'}');
      return;
    }
    final reading = DryerProtocol.parseTelemetry(m);
    if (reading != null) {
      final flagged = reading.fromDemo ? reading : reading;
      final isDemoTransport = _transport.kind == DryerTransportKind.demo || _transport.kind == DryerTransportKind.htmlSimulator || flagged.fromDemo;
      final stored = DryerReading(
        collectorTempC: flagged.collectorTempC,
        chamberTempC: flagged.chamberTempC,
        ambientTempC: flagged.ambientTempC,
        chamberRhPct: flagged.chamberRhPct,
        ambientRhPct: flagged.ambientRhPct,
        airflowM3h: flagged.airflowM3h, fanOn: flagged.fanOn,
        fanPwmPct: flagged.fanPwmPct, ventState: flagged.ventState,
        receivedAt: flagged.receivedAt, fromDemo: isDemoTransport,
        inletTempC: flagged.inletTempC,
        exhaustTempC: flagged.exhaustTempC,
        exhaustRhPct: flagged.exhaustRhPct,
        batteryVoltageV: flagged.batteryVoltageV,
        batterySocPct: flagged.batterySocPct,
        charging: flagged.charging, mode: flagged.mode,
        bayId: flagged.bayId,
        simulation: flagged.simulation,
      );
      lastReading = stored;
      readingsCtrl.add(stored);
      final issues = DryerCalculations.sensorIssues(stored, DateTime.now());
      for (final issue in issues.where((e) => e != 'stale data')) {
        alertsCtrl.add(DryerAlert(
          id: '${DateTime.now().microsecondsSinceEpoch}$issue',
          code: 'sensor_issue', message: issue,
          raisedAt: DateTime.now(),
        ));
      }
      if (activeBatch != null) {
        DryerHistoryStore.appendReading(activeBatch!.id, stored);
      }
    }
    final st = DryerProtocol.parseState(m);
    if (st != DryerState.unknown) {
      lastState = st;
      stateCtrl.add(st);
      if (st == DryerState.completed) {
        alertsCtrl.add(DryerAlert(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          code: 'batch_completed', message: 'Drying cycle completed.',
          raisedAt: DateTime.now(), fromController: true,
        ));
      }
      if (st == DryerState.safetyShutdown) {
        alertsCtrl.add(DryerAlert(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          code: 'safety_shutdown',
          message: 'Controller safety shutdown. Inspect hardware.',
          raisedAt: DateTime.now(), fromController: true,
        ));
      }
    }
    final alert = DryerProtocol.parseAlert(m);
    if (alert != null) alertsCtrl.add(alert);
  }
  Future<bool> sendCommand(String cmd,
      {Map<String, dynamic>? args}) async {
    if (!_transport.isConnected) {
      errorsCtrl.add('Connect a dryer or simulator before sending commands.');
      return false;
    }
    _seq++;
    final seq = _seq;
    final c = Completer<bool>();
    _pending[seq] = c;
    try {
      await _transport.send(DryerProtocol.command(seq: seq, cmd: cmd, args: args));
    } catch (_) {
      _pending.remove(seq);
      errorsCtrl.add('Command $cmd could not reach the connected device or simulator.');
      return false;
    }
    return c.future.timeout(const Duration(seconds: 8),
        onTimeout: () {
      _pending.remove(seq);
      errorsCtrl.add('Command $cmd timed out (seq $seq).');
      return false;
    });
  }
  void dispose() {
    _sub?.cancel();
    _transport.dispose();
    for (final pending in _pending.values) { if (!pending.isCompleted) pending.complete(false); }
    _pending.clear();
    readingsCtrl.close(); stateCtrl.close();
    alertsCtrl.close(); errorsCtrl.close();
  }
}
