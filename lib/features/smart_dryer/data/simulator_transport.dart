/// Pairs the phone with the HTML simulator's shared backend session.
library;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../domain/dryer_alert.dart';
import '../domain/dryer_state.dart';
import 'dryer_transport.dart';

class SimulatorDryerTransport extends DryerTransport {
  SimulatorDryerTransport({http.Client? client, this.pollingInterval = const Duration(seconds: 1)})
      : _client = client ?? http.Client();
  final http.Client _client;
  final Duration pollingInterval;
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _timer;
  DryerDeviceInfo? _device;
  String? _sessionId;
  bool _polling = false;
  bool _disposed = false;

  @override DryerTransportKind get kind => DryerTransportKind.htmlSimulator;
  @override String get label => 'HTML simulator (shared simulated data)';
  @override Stream<Map<String, dynamic>> get incoming => _ctrl.stream;
  @override bool get isConnected => _device != null && _sessionId != null;
  @override DryerDeviceInfo? get device => _device;
  @override Future<List<DryerDeviceInfo>> scan({Duration timeout = const Duration(seconds: 4)}) async => [];

  Future<Map<String, dynamic>> _request(String path, [Map<String, dynamic>? body]) async {
    final uri = apiUri('/dryer-simulator$path');
    final response = await (body == null ? _client.get(uri) : _client.post(uri,
      headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))).timeout(const Duration(seconds: 6));
    final result = jsonDecode(response.body);
    if (result is! Map<String, dynamic>) throw StateError('Invalid simulator response.');
    if (response.statusCode != 200 && response.statusCode != 409) {
      throw StateError(result['error']?.toString() ?? 'Simulation unavailable.');
    }
    return result;
  }

  Future<DryerDeviceInfo> pair(String code) async {
    if (!RegExp(r'^\d{6}$').hasMatch(code)) throw StateError('Enter the six-digit code shown in the HTML simulator.');
    final result = await _request('/pair', {'code': code});
    final session = result['sessionId'];
    if (result['simulated'] != true || session is! String || !RegExp(r'^[A-Za-z0-9_-]{24}$').hasMatch(session)) {
      throw StateError('This endpoint is not an EcoSusRural simulation.');
    }
    return DryerDeviceInfo(deviceId: 'HTML-SIM-$code', name: 'HTML six-tray simulation', transport: kind, address: session);
  }

  @override Future<void> connect(DryerDeviceInfo device) async {
    if (device.address == null || !RegExp(r'^[A-Za-z0-9_-]{24}$').hasMatch(device.address!)) throw StateError('Pair the HTML simulator first.');
    await disconnect();
    _device = device; _sessionId = device.address;
    try { await _poll(failOnError: true); }
    catch (_) { _device = null; _sessionId = null; rethrow; }
    _timer = Timer.periodic(pollingInterval, (_) => unawaited(_poll()));
  }

  Future<void> _poll({bool failOnError = false}) async {
    final session = _sessionId;
    if (session == null || _disposed || _polling) return;
    _polling = true;
    try {
      final telemetry = await _request('/sessions/$session/telemetry');
      if (telemetry['simulated'] != true || telemetry['source'] != 'html_simulator') throw StateError('Unmarked simulation data was rejected.');
      if (!_disposed && _sessionId == session) _ctrl.add(telemetry);
    } catch (_) {
      if (!_disposed && _sessionId == session) {
        _ctrl.add({'v': '1', 'type': 'state', 'state': 'unknown'});
        _ctrl.add({'v': '1', 'type': 'error', 'message': 'HTML simulator connection lost. Readings may be stale. Check the backend or pair again.'});
      }
      if (failOnError) rethrow;
    } finally { _polling = false; }
  }

  @override Future<void> send(Map<String, dynamic> message) async {
    final session = _sessionId;
    if (session == null) throw StateError('Pair the HTML simulator before sending commands.');
    final ack = await _request('/sessions/$session/commands', message);
    if (!_disposed && _sessionId == session) {
      _ctrl.add(ack);
      if (ack['accepted'] == false) _ctrl.add({'v': '1', 'type': 'error', 'message': ack['message']});
    }
    await _poll();
  }

  @override Future<void> disconnect() async {
    _timer?.cancel(); _timer = null; _device = null; _sessionId = null;
  }

  @override void dispose() {
    if (_disposed) return;
    _disposed = true; _timer?.cancel(); _client.close(); _ctrl.close();
  }
}
