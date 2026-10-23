/// BLE stub: API-compatible, throws until flutter_blue_plus is added.
library;
import 'dart:async';
import 'dryer_transport.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_state.dart';
class BleDryerTransport extends DryerTransport {
  @override DryerTransportKind get kind => DryerTransportKind.ble;
  @override String get label => 'Bluetooth LE (needs setup)';
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  @override Stream<Map<String, dynamic>> get incoming => _ctrl.stream;
  @override bool get isConnected => false;
  @override DryerDeviceInfo? get device => null;
  @override Future<List<DryerDeviceInfo>> scan(
      {Duration timeout = const Duration(seconds: 8)}) async {
    throw const BleNotAvailable(
      'Add flutter_blue_plus + permission_handler, then implement '
      'BleDryerTransport.scan/connect per docs/smart_dryer_protocol.md.',
    );
  }
  @override Future<void> connect(DryerDeviceInfo d) async {
    throw const BleNotAvailable('BLE not wired yet. Use Demo or Wi-Fi.');
  }
  @override Future<void> send(Map<String, dynamic> m) async {
    throw const BleNotAvailable('BLE not wired yet. Use Demo or Wi-Fi.');
  }
  @override Future<void> disconnect() async {}
  void dispose() { _ctrl.close(); }
}
