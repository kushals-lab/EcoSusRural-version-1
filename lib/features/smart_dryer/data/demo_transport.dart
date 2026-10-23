/// Demo simulator: plausible solar-dryer telemetry, no hardware.
library;
import 'dart:async';
import 'dart:math';
import 'dryer_transport.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_state.dart';
class DemoDryerTransport extends DryerTransport {
  @override DryerTransportKind get kind => DryerTransportKind.demo;
  @override String get label => 'Demo Mode (simulated)';
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  @override Stream<Map<String, dynamic>> get incoming => _ctrl.stream;
  Timer? _timer;
  bool _connected = false;
  DryerDeviceInfo? _device;
  final _rand = Random();
  double _sun = 0.7;
  bool _fault = false;
  @override bool get isConnected => _connected;
  @override DryerDeviceInfo? get device => _device;
  @override Future<List<DryerDeviceInfo>> scan(
      {Duration timeout = const Duration(seconds: 2)}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const [
      DryerDeviceInfo(deviceId: 'DEMO-DRYER-01', name: 'Demo Solar Dryer',
          transport: DryerTransportKind.demo),
    ];
  }
  @override Future<void> connect(DryerDeviceInfo d) async {
    _device = d; _connected = true; _fault = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    _ctrl.add({'v': '1', 'type': 'state', 'state': 'ready'});
  }
  @override Future<void> disconnect() async {
    _timer?.cancel(); _connected = false;
  }
  @override Future<void> send(Map<String, dynamic> m) async {
    final cmd = '${m['cmd'] ?? ''}';
    final seq = (m['seq'] as num?)?.toInt() ?? 0;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!_connected) return;
    if (cmd == 'simulate_fault') { _fault = true; }
    if (cmd == 'simulate_disconnect') {
      _ctrl.add({'v': '1', 'type': 'state', 'state': 'unknown'});
      await disconnect();
      return;
    }
    if (cmd == 'start' || cmd == 'pause' || cmd == 'stop' ||
        cmd == 'set_profile' || cmd == 'set_fan' || cmd == 'set_vent') {
      _ctrl.add({'v': '1', 'type': 'ack', 'seq': seq, 'accepted': true});
      final st = cmd == 'start' ? 'running'
          : cmd == 'stop' ? 'ready'
          : cmd == 'pause' ? 'paused' : 'running';
      _ctrl.add({'v': '1', 'type': 'state', 'state': st});
      if (cmd == 'stop') {
        _ctrl.add({'v': '1', 'type': 'state', 'state': 'completed'});
      }
    }
  }
  void _tick() {
    if (!_connected) return;
    _sun += (_rand.nextDouble() - 0.5) * 0.1;
    _sun = _sun.clamp(0.25, 1.0);
    final collector = 28 + _sun * 38 + _rand.nextDouble() * 2;
    final chamber = 26 + _sun * 28 + _rand.nextDouble() * 1.5;
    final ambient = 27 + _rand.nextDouble() * 3;
    final inlet = ambient + _sun * 8 + _rand.nextDouble();
    final exhaust = chamber - 2 - _rand.nextDouble() * 2;
    final chamberRh = (78 - _sun * 42 + _rand.nextDouble() * 3)
        .clamp(8.0, 95.0);
    final ambientRh = (62 - _sun * 12 + _rand.nextDouble() * 4)
        .clamp(10.0, 95.0);
    final exhaustRh = (chamberRh + 8 + _rand.nextDouble() * 4)
        .clamp(8.0, 98.0);
    final battV = 12.2 + _sun * 1.4 + (_rand.nextDouble() - 0.5) * 0.2;
    final soc = ((battV - 11.0) / (14.4 - 11.0) * 100).clamp(5.0, 100.0);
    _ctrl.add({
      'v': '1', 'type': 'telemetry',
      'data': {
        'collectorC': collector, 'chamberC': chamber,
        'ambientC': ambient, 'inletC': inlet, 'exhaustC': exhaust,
        'chamberRh': chamberRh, 'ambientRh': ambientRh,
        'exhaustRh': exhaustRh, 'airflow': 120 + _sun * 60,
        'fanOn': true, 'fanPwm': 70, 'vent': 'open',
        'battV': battV, 'battSoc': soc, 'charging': _sun > 0.5,
        'mode': 'DRYING_AUTO', 'bay': 'bay-1',
        'state': _fault ? 'warning' : 'running',
      },
    });
    if (_fault) {
      _ctrl.add({'v': '1', 'type': 'alert',
          'code': 'fan_fault', 'message': 'Demo fan fault (simulated)'});
      _fault = false;
    }
  }
  void dispose() { _timer?.cancel(); _ctrl.close(); }
}
