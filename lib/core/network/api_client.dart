import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../di/injection.dart';

/// Network status representation
enum NetworkStatus { online, offline, checking }

class NetworkState {
  final NetworkStatus status;
  final DateTime? lastChecked;
  final String? activeHost;

  const NetworkState({
    required this.status,
    this.lastChecked,
    this.activeHost,
  });

  bool get isOnline => status == NetworkStatus.online;
}

/// Riverpod provider tracking live network & backend reachability
final networkStatusProvider =
    StateNotifierProvider<NetworkNotifier, NetworkState>((ref) {
  return NetworkNotifier();
});

class NetworkNotifier extends StateNotifier<NetworkState> {
  Timer? _heartbeatTimer;

  NetworkNotifier()
      : super(const NetworkState(status: NetworkStatus.checking)) {
    checkConnectivity();
    // Heartbeat check every 25 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      checkConnectivity();
    });
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  /// Verifies true end-to-end backend connectivity rather than assuming Wi-Fi means internet
  Future<bool> checkConnectivity() async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl.replaceAll('/api', '')}/health');
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      final online = res.statusCode >= 200 && res.statusCode < 400;
      state = NetworkState(
        status: online ? NetworkStatus.online : NetworkStatus.offline,
        lastChecked: DateTime.now(),
        activeHost: uri.host,
      );
      return online;
    } catch (_) {
      // Backend unreachable or device is completely offline
      state = NetworkState(
        status: NetworkStatus.offline,
        lastChecked: DateTime.now(),
      );
      return false;
    }
  }

  void markOffline() {
    state = NetworkState(
      status: NetworkStatus.offline,
      lastChecked: DateTime.now(),
    );
  }
}

/// Enhanced HTTP client with automatic retry, exponential backoff, request deduplication, and offline caching
class ApiClient {
  final http.Client _client = http.Client();
  final Map<String, Future<dynamic>> _inFlightRequests = {};

  Future<dynamic> get(String path, {bool cacheOffline = true, Duration? cacheTtl}) async {
    final cacheKey = 'http_cache_$path';

    // Request deduplication for simultaneous in-flight queries
    if (_inFlightRequests.containsKey(path)) {
      return _inFlightRequests[path];
    }

    final future = _executeGetWithRetry(path, cacheKey, cacheOffline);
    _inFlightRequests[path] = future;

    try {
      final res = await future;
      return res;
    } finally {
      _inFlightRequests.remove(path);
    }
  }

  Future<dynamic> _executeGetWithRetry(String path, String cacheKey, bool cacheOffline) async {
    int attempts = 0;
    const maxAttempts = 3;
    Duration delay = const Duration(milliseconds: 500);

    while (attempts < maxAttempts) {
      attempts++;
      try {
        final url = Uri.parse('${AppConfig.apiBaseUrl}$path');
        final response = await _client
            .get(url)
            .timeout(const Duration(milliseconds: AppConfig.connectTimeout));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (cacheOffline && decoded is Map<String, dynamic>) {
            await DependencyInjection.localStorage.setJson(cacheKey, decoded);
          }
          return decoded;
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        if (attempts >= maxAttempts) {
          // If offline or failed after retries, fallback to cached data if available
          final cached = DependencyInjection.localStorage.getJson(cacheKey);
          if (cached != null) {
            return {
              ...cached['data'] as Map<String, dynamic>,
              '_isOfflineCache': true,
              '_cachedAt': cached['cachedAt'],
            };
          }
          throw Exception('Network error after $maxAttempts attempts: $e');
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    // Non-idempotent/financial actions must never replay automatically from offline queues
    final response = await _client
        .post(
          Uri.parse('${AppConfig.apiBaseUrl}$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(milliseconds: AppConfig.connectTimeout));
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Network error: ${response.statusCode}');
    }
  }
}