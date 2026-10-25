import 'dart:async';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/language_provider.dart';
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
      if (mounted && !request.isCancelled) setState(() => _error = 'weatherUnavailable');
    } finally { if (mounted && !request.isCancelled) setState(() => _loading = false); }
  }
  String _stamp(dynamic value) {
    if (value == null) return ref.tr('notSupplied');
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
    if (code == 0) return ref.tr('clearSky');
    if ([1, 2, 3].contains(code)) return ref.tr('cloudy');
    if ([45, 48].contains(code)) return ref.tr('fog');
    if ([71, 73, 75, 77, 85, 86].contains(code)) return ref.tr('snow');
    if (code is num && code >= 95) return ref.tr('thunderstorms');
    if (code is num && code >= 51) return ref.tr('rainDrizzle');
    return ref.tr('conditionNotSupplied');
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
    return Scaffold(appBar: AppBar(title: Text(ref.tr('weatherIntelligence')), actions: [
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClockScreen())), icon: const Icon(Icons.alarm), tooltip: ref.tr('remindersClocks')),
      IconButton(onPressed: _loading ? null : () => _load(force: true), icon: const Icon(Icons.refresh), tooltip: ref.tr('refreshWeather')),
    ]), body: SafeArea(child: RefreshIndicator(onRefresh: () => _load(force: true), child: ListView(
      physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: [
        const OfflineStatusBar(),
        Text('${MaterialLocalizations.of(context).formatFullDate(_now)}\n${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} ${_now.timeZoneName} (${ref.tr('deviceClock')})'),
        if (zonedNow != null) Text('${ref.tr('selectedLocationTime')}: $zonedNow ($zone)'),
        if (_clockSkew) Text(ref.tr('deviceTimeSkew'), style: const TextStyle(color: Colors.deepOrange)),
        ListTile(contentPadding: EdgeInsets.zero, title: Text(place?.label ?? ref.tr('chooseWeatherLocation')),
          subtitle: Text('${ref.tr('weatherTimeZone')}: ${data?['timezone'] ?? place?.timezone ?? ref.tr('notSelected')}'),
          trailing: const Icon(Icons.edit_location_alt), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSelectionScreen()))),
        if (place != null && !place.hasCoordinates) Text(ref.tr('attachCoordinates')),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) Text(ref.tr(_error!), style: const TextStyle(color: Colors.deepOrange)),
        if (data != null) ...[
          Card(color: cached ? Colors.amber.shade50 : Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Text(
            '${ref.tr(cached ? 'cachedWeather' : 'latestWeather')}\n${ref.tr('weatherSource')}: ${data['source']}\n${ref.tr('currentConditions')}: ${data['observation_kind'] ?? 'provider data'}\n${ref.tr('observationTime')}: ${_stamp(data['source_reported_at'])}\n${ref.tr('lastSuccessfulRefresh')}: ${_stamp(data['last_fetched_at'] ?? data['_cachedAt'])}'))),
          Text(ref.tr('currentConditions'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Wrap(spacing: 8, runSpacing: 4, children: [
            _metric(ref.tr('temperature'), current['temperature_2m'], '°C'), _metric(ref.tr('feelsLike'), current['apparent_temperature'], '°C'),
            _metric(ref.tr('humidity'), current['relative_humidity_2m'], '%'), _metric(ref.tr('precipitation'), current['precipitation'], 'mm'),
            _metric(ref.tr('wind'), current['wind_speed_10m'], 'km/h'), _metric(ref.tr('windDirection'), current['wind_direction_10m'], '°'),
            _metric(ref.tr('pressure'), current['surface_pressure'], 'hPa'),
          ]),
          if (current['weather_code'] != null) Row(children: [Icon(_icon(current['weather_code'])), const SizedBox(width: 8), Expanded(child: Text(_condition(current['weather_code'])))]),
          if (visibilityIndex >= 0 && _at(hourly, 'visibility', visibilityIndex) != null)
            Text('${ref.tr('hourlyVisibility')}: ${_at(hourly, 'visibility', visibilityIndex)} m — ${_stamp(hourlyTimes[visibilityIndex])}'),
          const SizedBox(height: 16),
          Text(ref.tr('sevenDayForecast'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(ref.tr('dailyPredictionNote')),
          for (var i = 0; i < times.length; i++) Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(_icon(_at(daily, 'weather_code', i))), const SizedBox(width: 10),
                Expanded(child: Text(_date(times[i], offset), style: const TextStyle(fontWeight: FontWeight.bold)))]),
              Wrap(spacing: 8, children: [
                _metric(ref.tr('minimum'), _at(daily, 'temperature_2m_min', i), '°C'), _metric(ref.tr('maximum'), _at(daily, 'temperature_2m_max', i), '°C'),
                _metric(ref.tr('rainChance'), _at(daily, 'precipitation_probability_max', i), '%'), _metric(ref.tr('rainfall'), _at(daily, 'precipitation_sum', i), 'mm'),
                _metric(ref.tr('humidity'), _at(daily, 'relative_humidity_2m_mean', i), '%'), _metric('UV', _at(daily, 'uv_index_max', i), ''),
              ]),
              if (_at(daily, 'sunrise', i) != null) Text('${ref.tr('sunrise')}: ${_stamp(_at(daily, 'sunrise', i))}'),
              if (_at(daily, 'sunset', i) != null) Text('${ref.tr('sunset')}: ${_stamp(_at(daily, 'sunset', i))}'),
            ]))),
          Text(ref.tr('officialAlertsUnavailable')),
          ExpansionTile(title: Text(ref.tr('rainfallPattern')), children: [
            for (var i = 0; i < times.length; i++)
              if (_at(daily, 'precipitation_sum', i) != null)
                ListTile(title: Text(_date(times[i], offset)), subtitle: Text('${ref.tr('forecastRainfall')}: ${_at(daily, 'precipitation_sum', i)} mm')),
          ]),
          ExpansionTile(title: Text(ref.tr('cropAdvisory')), children: [Padding(padding: const EdgeInsets.all(12),
            child: Text(ref.tr('cropAdvisoryNote')))]),
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
          }, child: Text(ref.tr('mandiImpactEstimates'))),
        ],
      ]))));
  }
}
