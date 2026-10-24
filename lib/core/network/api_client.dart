import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../di/injection.dart';

enum NetworkStatus { online, offline, checking }
class NetworkState {
  final NetworkStatus status;
  final DateTime? lastChecked;
  final String? activeHost;
  final bool hasTransport;
  const NetworkState({required this.status, this.lastChecked, this.activeHost, this.hasTransport = true});
  bool get isOnline => status == NetworkStatus.online;
}
final networkStatusProvider = StateNotifierProvider<NetworkNotifier, NetworkState>((ref) => NetworkNotifier());
class NetworkNotifier extends StateNotifier<NetworkState> {
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final http.Client _client = http.Client();
  bool _checking = false, _disposed = false;
  NetworkNotifier({bool monitor = true}) : super(const NetworkState(status: NetworkStatus.checking)) {
    if (!monitor) return;
    checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => checkConnectivity());
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((e) => e != ConnectivityResult.none)) { checkConnectivity(); }
      else { markOffline(hasTransport: false); }
    });
  }
  Future<bool> checkConnectivity() async {
    if (_checking || _disposed) return state.isOnline;
    _checking = true;
    try {
      final uri = apiUri('').replace(path: '/health', query: null);
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      final online = response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok';
      if (!_disposed) {
        state = NetworkState(status: online ? NetworkStatus.online : NetworkStatus.offline,
        lastChecked: DateTime.now(), activeHost: uri.host);
      }
      return online;
    } catch (_) { markOffline(); return false; }
    finally { _checking = false; }
  }
  void markOffline({bool hasTransport = true}) {
    if (!_disposed) {
      state = NetworkState(status: NetworkStatus.offline,
      lastChecked: DateTime.now(), hasTransport: hasTransport);
    }
  }
  @override void dispose() {
    _disposed = true; _timer?.cancel(); _subscription?.cancel(); _client.close(); super.dispose();
  }
}
Uri apiUri(String path) {
  final base = Uri.parse(AppConfig.apiBaseUrl);
  final local = !kReleaseMode && ['localhost', '127.0.0.1', '::1', '10.0.2.2'].contains(base.host);
  if (base.host.isEmpty || (base.scheme != 'https' && !local)) {
    throw StateError('Production API_BASE_URL must use HTTPS');
  }
  return Uri.parse('${base.toString().replaceFirst(RegExp(r'/+$'), '')}$path');
}
class RequestCancelled implements Exception { const RequestCancelled(); }
class RequestCancellation {
  final Completer<void> _cancelled = Completer<void>();
  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;
  void cancel() { if (!isCancelled) _cancelled.complete(); }
  void check() { if (isCancelled) throw const RequestCancelled(); }
}
class ApiException implements Exception {
  final int status;
  const ApiException(this.status);
  @override String toString() => 'Server returned HTTP $status';
}
/// Caches public reads only; writes never retry or report cached success.
class ApiClient {
  ApiClient({http.Client Function()? clientFactory}) : _factory = clientFactory ?? http.Client.new;
  final http.Client Function() _factory;
  final Map<String, Future<dynamic>> _inFlight = {};
  final Set<http.Client> _active = {};
  Future<dynamic> get(String path, {bool cacheOffline = true, Duration? cacheTtl,
      Duration freshFor = const Duration(minutes: 2), bool forceRefresh = false,
      RequestCancellation? cancellation}) async {
    await DependencyInjection.localStorage.init();
    cancellation?.check();
    final key = 'http_cache_${apiUri(path)}';
    final cached = DependencyInjection.localStorage.getJson(key);
    final at = DateTime.tryParse(cached?['cachedAt']?.toString() ?? '');
    final age = at == null ? null : DateTime.now().difference(at);
    if (cacheOffline && !forceRefresh && age != null && !age.isNegative && age < freshFor) {
      return _cached(cached!, offline: false);
    }
    if (cancellation == null && _inFlight.containsKey(key)) return _inFlight[key];
    final future = _read(path, key, cacheOffline, cacheTtl, cancellation);
    if (cancellation == null) _inFlight[key] = future;
    try { return await future; } finally { if (cancellation == null) _inFlight.remove(key); }
  }
  dynamic _cached(Map<String, dynamic> value, {required bool offline}) {
    final envelope = value['data'];
    final data = envelope is Map && envelope.containsKey('value') ? envelope['value'] : envelope;
    return data is Map<String, dynamic> ? {...data, '_isOfflineCache': offline,
      '_isCache': true, '_cachedAt': value['cachedAt']} : data;
  }
  Future<dynamic> _read(String path, String key, bool cacheOffline, Duration? ttl,
      RequestCancellation? cancellation) async {
    Object? failure;
    for (var attempt = 0; attempt < 3; attempt++) {
      cancellation?.check();
      try {
        final response = await _request('GET', path, cancellation: cancellation);
        if (response.statusCode < 200 || response.statusCode >= 300) throw ApiException(response.statusCode);
        final data = jsonDecode(response.body);
        if (cacheOffline) await DependencyInjection.localStorage.setJson(key, {'value': data});
        return data;
      } catch (e) {
        if (e is RequestCancelled) rethrow;
        failure = e;
        if (e is ApiException && (e.status == 429 || e.status < 500)) break;
        if (attempt < 2) {
          await Future.any([Future<void>.delayed(Duration(milliseconds: 500 * (1 << attempt))),
          if (cancellation != null) cancellation.whenCancelled]);
        }
      }
    }
    cancellation?.check();
    if (cacheOffline && !(failure is ApiException && failure.status >= 400 && failure.status < 429)) {
      final saved = DependencyInjection.localStorage.getJson(key);
      final at = DateTime.tryParse(saved?['cachedAt']?.toString() ?? '');
      if (saved != null && at != null && (ttl == null || DateTime.now().difference(at) <= ttl)) {
        return _cached(saved, offline: true);
      }
    }
    throw failure ?? StateError('Request failed');
  }
  Future<dynamic> post(String path, Map<String, dynamic> body, {String? idempotencyKey}) async {
    final response = await _request('POST', path, body: body, idempotencyKey: idempotencyKey);
    if (response.statusCode < 200 || response.statusCode >= 300) throw ApiException(response.statusCode);
    return jsonDecode(response.body);
  }
  Future<http.Response> _request(String method, String path, {Map<String, dynamic>? body,
      String? idempotencyKey, RequestCancellation? cancellation}) async {
    final client = _factory(); _active.add(client);
    final cancelled = cancellation?.whenCancelled.then<http.Response>((_) {
      client.close(); throw const RequestCancelled();
    });
    try {
      final headers = {'Content-Type': 'application/json', if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey};
      final operation = method == 'GET' ? client.get(apiUri(path), headers: headers)
        : client.post(apiUri(path), headers: headers, body: jsonEncode(body));
      return await Future.any([operation, if (cancelled != null) cancelled]).timeout(const Duration(seconds: 20));
    } finally { client.close(); _active.remove(client); }
  }
  void close() { for (final client in _active.toList()) { client.close(); } }
}
