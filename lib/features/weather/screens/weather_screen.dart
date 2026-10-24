import 'dart:async';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/offline_status_bar.dart';
import '../providers/location_preferences.dart';
import '../models/weather_day.dart';
import 'location_selection_screen.dart';
import 'mandi_impact_screen.dart';
import '../../clock/clock_screen.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});
  @override ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}
class _WeatherScreenState extends ConsumerState<WeatherScreen> with WidgetsBindingObserver {
  Timer? _clock, _refresh;
  RequestCancellation? _request;
  DateTime _now = DateTime.now();
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = false;
  bool _clockSkew = false;
  String? _placeKey;
  @override void initState() {
    super.initState(); tzdata.initializeTimeZones(); WidgetsBinding.instance.addObserver(this);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => _now = DateTime.now()); });
    _refresh = Timer.periodic(const Duration(minutes: 10), (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) _load();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }
  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) { setState(() => _now = DateTime.now()); _load(); }
  }
  @override void dispose() {
    _clock?.cancel(); _refresh?.cancel(); _request?.cancel();
    WidgetsBinding.instance.removeObserver(this); super.dispose();
  }
  Future<void> _load({bool force = false}) async {
    final place = ref.read(locationPreferencesProvider)[LocationPurpose.weather];
    if (place == null || !place.hasCoordinates) return;
    final key = '${place.latitude},${place.longitude}';
    if (_loading && key == _placeKey) return;
    _request?.cancel(); final request = RequestCancellation(); _request = request;
    setState(() { _loading = true; _error = null; if (_placeKey != key) _data = null; _placeKey = key; });
    try {
      final result = await DependencyInjection.apiClient.get('/weather?lat=${place.latitude}&lon=${place.longitude}',
        cancellation: request, forceRefresh: force, cacheTtl: const Duration(days: 7));
      if (result is! Map<String, dynamic> || result['daily'] is! Map) throw const FormatException('Invalid weather');
      if (mounted && !request.isCancelled) {
        setState(() {
          _data = result;
          final server = DateTime.tryParse(result['server_time']?.toString() ?? '');
          if (server != null && result['_isCache'] != true) {
            _clockSkew = DateTime.now().toUtc().difference(server).inMinutes.abs() > 5;
          }
        });
      }
    } catch (e) {
      if (mounted && !request.isCancelled) setState(() => _error = 'Weather unavailable. ${_data == null ? 'No downloaded weather for this location.' : 'Showing previous data; not live.'}');
    } finally { if (mounted && !request.isCancelled) setState(() => _loading = false); }
  }
  String _stamp(dynamic value) {
    if (value == null) return 'Not supplied';
    final dt = value is num ? DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000, isUtc: true) : DateTime.tryParse(value.toString());
    return dt?.toUtc().toIso8601String().replaceFirst('T', ' ').replaceFirst('.000Z', ' UTC') ?? value.toString();
  }
  dynamic _at(Map daily, String key, int i) {
    final values = daily[key];
    return values is List && values.length > i ? values[i] : null;
  }
  String _date(dynamic value, int offset) {
    if (value is! num) return value?.toString() ?? '';
    return DateTime.fromMillisecondsSinceEpoch((value.toInt() + offset) * 1000, isUtc: true).toIso8601String().split('T').first;
  }
  IconData _icon(dynamic code) {
    if (code is! num) return Icons.help_outline;
    if (code >= 95) return Icons.thunderstorm;
    if (code >= 51) return Icons.umbrella;
    if (code >= 1) return Icons.cloud;
    return Icons.wb_sunny;
  }
  String _condition(dynamic code) {
    if (code == 0) return 'Clear sky';
    if ([1, 2, 3].contains(code)) return 'Partly cloudy / overcast';
    if ([45, 48].contains(code)) return 'Fog';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snow';
    if (code is num && code >= 95) return 'Thunderstorms';
    if (code is num && code >= 51) return 'Rain / drizzle';
    return 'Condition not supplied';
  }
  Widget _metric(String label, dynamic value, String unit) =>
    value == null ? const SizedBox.shrink() : Chip(label: Text('$label: $value $unit'));
  @override Widget build(BuildContext context) {
    ref.listen(locationPreferencesProvider, (previous, next) {
      if (previous?[LocationPurpose.weather] != next[LocationPurpose.weather]) _load();
    });
    ref.listen(networkStatusProvider, (previous, next) {
      if (next.isOnline && previous?.isOnline != true) _load(force: true);
    });
    final place = ref.watch(locationPreferencesProvider)[LocationPurpose.weather];
    final data = _data;
    final daily = data?['daily'] as Map? ?? {};
    final current = data?['current'] as Map? ?? {};
    final offset = (data?['utc_offset_seconds'] as num?)?.toInt() ?? 0;
    final times = daily['time'] as List? ?? [];
    final cached = data?['_isCache'] == true || data?['_isOfflineCache'] == true || data?['cache_status'] != 'fresh' || _error != null;
    final zone = data?['timezone']?.toString() ?? place?.timezone;
    final zonedNow = zone != null && tz.timeZoneDatabase.locations.containsKey(zone)
      ? tz.TZDateTime.from(_now, tz.getLocation(zone)) : null;
    final hourly = data?['hourly'] as Map? ?? {};
    final hourlyTimes = hourly['time'] as List? ?? [];
    final currentSeconds = current['time'];
    final visibilityIndex = currentSeconds is num ? hourlyTimes.lastIndexWhere((t) => t is num && t <= currentSeconds) : -1;
    return Scaffold(appBar: AppBar(title: const Text('Weather Intelligence'), actions: [
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClockScreen())), icon: const Icon(Icons.alarm), tooltip: 'Reminders and clocks'),
      IconButton(onPressed: _loading ? null : () => _load(force: true), icon: const Icon(Icons.refresh), tooltip: 'Refresh weather'),
    ]), body: SafeArea(child: RefreshIndicator(onRefresh: () => _load(force: true), child: ListView(
      physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: [
        const OfflineStatusBar(),
        Text('${MaterialLocalizations.of(context).formatFullDate(_now)}\n${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} ${_now.timeZoneName} (device clock)'),
        if (zonedNow != null) Text('Selected location time: $zonedNow ($zone)'),
        if (_clockSkew) const Text('Device time differs from the server. Check your date and time settings.', style: TextStyle(color: Colors.deepOrange)),
        ListTile(contentPadding: EdgeInsets.zero, title: Text(place?.label ?? 'Choose your weather location'),
          subtitle: Text('Weather time zone: ${data?['timezone'] ?? place?.timezone ?? 'not selected'}'),
          trailing: const Icon(Icons.edit_location_alt), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSelectionScreen()))),
        if (place != null && !place.hasCoordinates) const Text('Choose a search result to attach coordinates to this address.'),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, style: const TextStyle(color: Colors.deepOrange)),
        if (data != null) ...[
          Card(color: cached ? Colors.amber.shade50 : Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Text(
            '${cached ? 'Cached weather — not live' : 'Latest retrieved weather'}\nSource: ${data['source']}\nCurrent conditions: ${data['observation_kind'] ?? 'provider data'}\nObservation time: ${_stamp(data['source_reported_at'])}\nLast successful refresh: ${_stamp(data['last_fetched_at'])}'))),
          const Text('Current conditions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Wrap(spacing: 8, runSpacing: 4, children: [
            _metric('Temperature', current['temperature_2m'], '°C'), _metric('Feels like', current['apparent_temperature'], '°C'),
            _metric('Humidity', current['relative_humidity_2m'], '%'), _metric('Precipitation', current['precipitation'], 'mm'),
            _metric('Wind', current['wind_speed_10m'], 'km/h'), _metric('Wind direction', current['wind_direction_10m'], '°'),
            _metric('Pressure', current['surface_pressure'], 'hPa'),
          ]),
          if (current['weather_code'] != null) Row(children: [Icon(_icon(current['weather_code'])), const SizedBox(width: 8), Expanded(child: Text(_condition(current['weather_code'])))]),
          if (visibilityIndex >= 0 && _at(hourly, 'visibility', visibilityIndex) != null)
            Text('Hourly visibility estimate: ${_at(hourly, 'visibility', visibilityIndex)} m at ${_stamp(hourlyTimes[visibilityIndex])}'),
          const SizedBox(height: 16),
          const Text('7-Day Forecast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Daily predictions; humidity is the daily mean. UV is the daily maximum.'),
          for (var i = 0; i < times.length; i++) Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(_icon(_at(daily, 'weather_code', i))), const SizedBox(width: 10),
                Expanded(child: Text(_date(times[i], offset), style: const TextStyle(fontWeight: FontWeight.bold)))]),
              Wrap(spacing: 8, children: [
                _metric('Minimum', _at(daily, 'temperature_2m_min', i), '°C'), _metric('Maximum', _at(daily, 'temperature_2m_max', i), '°C'),
                _metric('Rain chance', _at(daily, 'precipitation_probability_max', i), '%'), _metric('Rainfall', _at(daily, 'precipitation_sum', i), 'mm'),
                _metric('Humidity', _at(daily, 'relative_humidity_2m_mean', i), '%'), _metric('UV', _at(daily, 'uv_index_max', i), ''),
              ]),
              if (_at(daily, 'sunrise', i) != null) Text('Sunrise: ${_stamp(_at(daily, 'sunrise', i))}'),
              if (_at(daily, 'sunset', i) != null) Text('Sunset: ${_stamp(_at(daily, 'sunset', i))}'),
            ]))),
          const Text('Official weather alerts are not supplied by this forecast source.'),
          ExpansionTile(title: const Text('Rainfall Pattern Analysis'), children: [
            for (var i = 0; i < times.length; i++)
              if (_at(daily, 'precipitation_sum', i) != null)
                ListTile(title: Text(_date(times[i], offset)), subtitle: Text('Forecast rainfall: ${_at(daily, 'precipitation_sum', i)} mm')),
          ]),
          const ExpansionTile(title: Text('Crop advisory'), children: [Padding(padding: EdgeInsets.all(12),
            child: Text('Use these forecasts to plan field visits, irrigation and drying. Check local agricultural guidance before spraying or harvesting. Forecasts do not measure soil moisture or guarantee crop yield.'))]),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () {
            final days = <WeatherDay>[];
            for (var i = 0; i < times.length; i++) {
              final max = _at(daily, 'temperature_2m_max', i), min = _at(daily, 'temperature_2m_min', i), rain = _at(daily, 'precipitation_sum', i);
              if (max is num && min is num && rain is num) {
                days.add(WeatherDay(date: DateTime.parse(_date(times[i], offset)),
                maxTemp: max.toDouble(), minTemp: min.toDouble(), rainMm: rain.toDouble(), condition: rain > 0 ? 'rain' : 'cloud'));
              }
            }
            if (days.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_) => MandiImpactScreen(forecast: days)));
          }, child: const Text('Forecast-based mandi impact estimates')),
        ],
      ]))));
  }
}
