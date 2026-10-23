/// Transport abstraction: demo + WiFi reuse http, BLE stub.
library;
import 'dart:async';
import '../domain/dryer_alert.dart';
import '../domain/dryer_state.dart';
abstract class DryerTransport {
  DryerTransportKind get kind;
  String get label;
  Stream<Map<String, dynamic>> get incoming;
  Future<List<DryerDeviceInfo>> scan({Duration timeout = const Duration(seconds: 4)});
  Future<void> connect(DryerDeviceInfo device);
  Future<void> disconnect();
  Future<void> send(Map<String, dynamic> message);
  bool get isConnected;
  DryerDeviceInfo? get device;
}
class BleNotAvailable implements Exception {
  final String message;
  const BleNotAvailable(this.message);
  @override String toString() => 'BleNotAvailable: $message';
}
