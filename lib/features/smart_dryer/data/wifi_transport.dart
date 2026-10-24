/// Wi-Fi transport: polls ESP32 HTTP endpoints, no new packages.
library;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dryer_transport.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_state.dart';
class WifiDryerTransport extends DryerTransport {
  @override DryerTransportKind get kind => DryerTransportKind.wifi;
  @override String get label => 'Wi-Fi (ESP32 HTTP)';
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  @override Stream<Map<String, dynamic>> get incoming => _ctrl.stream;
  Timer? _timer;
  DryerDeviceInfo? _device;
  String? _baseUrl;
  @override bool get isConnected => _device != null && _baseUrl != null;
  @override DryerDeviceInfo? get device => _device;
  @override Future<List<DryerDeviceInfo>> scan(
      {Duration timeout = const Duration(seconds: 4)}) async {
    return const [
      DryerDeviceInfo(deviceId: 'WIFI-DRYER-01', name: 'Solar Dryer (Wi-Fi)',
          transport: DryerTransportKind.wifi,
          address: 'http://192.168.4.1'),
    ];
  }
  @override Future<void> connect(DryerDeviceInfo d) async {
    _device = d;
    _baseUrl = (d.address ?? 'http://192.168.4.1').replaceAll(RegExp(r'/$'), '');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
    await _poll();
  }
  Future<void> _poll() async {
    if (_baseUrl == null) return;
    try {
      final r = await http.get(Uri.parse('$_baseUrl/telemetry'))
          .timeout(const Duration(seconds: 6));
      if (_ctrl.isClosed || _baseUrl == null) return;
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final m = jsonDecode(r.body);
        if (m is Map<String, dynamic>) _ctrl.add(m);
      } else {
        _ctrl.add({'v': '1', 'type': 'error', 'message': 'HTTP ${r.statusCode}'});
      }
    } catch (e) {
      if (!_ctrl.isClosed) _ctrl.add({'v': '1', 'type': 'error', 'message': '$e'});
    }
  }
  @override Future<void> send(Map<String, dynamic> m) async {
    if (_baseUrl == null) return;
    try {
      await http.post(Uri.parse('$_baseUrl/cmd'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(m)).timeout(const Duration(seconds: 6));
    } catch (e) {
      if (!_ctrl.isClosed) _ctrl.add({'v': '1', 'type': 'error', 'message': '$e'});
    }
  }
  @override Future<void> disconnect() async {
    _timer?.cancel(); _device = null; _baseUrl = null;
  }
  @override void dispose() { _timer?.cancel(); _baseUrl = null; _device = null; _ctrl.close(); }
}
