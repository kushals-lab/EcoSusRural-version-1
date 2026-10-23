import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

import '../../../core/permission/location_permission.dart';
import '../models/weather_day.dart';
import 'mandi_impact_screen.dart';
import 'weather_alert_screen.dart';

/// Weather Intelligence: 7-day forecast, rainfall analysis, crop advisory and
/// the weather–yield correlation engine.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = false;
  final Color _primaryGreen = const Color(0xFF1B4D3E);
  final Map<String, bool> _sectionLoading = {};

  /// Whether the user has allowed location access for village-level weather.
  bool _locationAllowed = false;

  /// True once the stored consent has been read, so the notice does not flash
  /// on the first frame for users who already allowed access.
  bool _locationChecked = false;

  // Village anchor used for the Open-Meteo call (Nashik, Maharashtra).
  static const double _lat = 19.9975;
  static const double _lng = 73.7898;

  // Demo dataset shown immediately (offline-safe) and replaced by live data
  // whenever a refresh succeeds.
  List<WeatherDay> _forecast = [
    WeatherDay(date: DateTime(2026, 1, 1), maxTemp: 31, minTemp: 18, rainMm: 0, condition: 'sunny'),
    WeatherDay(date: DateTime(2026, 1, 2), maxTemp: 30, minTemp: 19, rainMm: 2, condition: 'cloud'),
    WeatherDay(date: DateTime(2026, 1, 3), maxTemp: 28, minTemp: 20, rainMm: 14, condition: 'rain'),
    WeatherDay(date: DateTime(2026, 1, 4), maxTemp: 27, minTemp: 20, rainMm: 22, condition: 'storm'),
    WeatherDay(date: DateTime(2026, 1, 5), maxTemp: 29, minTemp: 19, rainMm: 6, condition: 'rain'),
    WeatherDay(date: DateTime(2026, 1, 6), maxTemp: 30, minTemp: 18, rainMm: 1, condition: 'cloud'),
    WeatherDay(date: DateTime(2026, 1, 7), maxTemp: 32, minTemp: 17, rainMm: 0, condition: 'sunny'),
  ];

  double get _currentTemp => _forecast.first.maxTemp;
  double get _weekRainfall => _forecast.fold(0.0, (sum, d) => sum + d.rainMm);
  double get _avgTemp =>
      _forecast.fold(0.0, (sum, d) => sum + (d.maxTemp + d.minTemp) / 2) / (_forecast.isEmpty ? 1 : _forecast.length);

  @override
  void initState() {
    super.initState();
    // Location consent is required for village-level weather. The stored answer
    // decides whether the sheet is shown: "ask every time" re-prompts on each
    // visit, "deny" keeps the bundled village anchor and never nags.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncLocationAccess());
  }

  Future<void> _syncLocationAccess() async {
    await LocationPermissionStore.load();
    if (!mounted) return;
    setState(() {
      _locationChecked = true;
      _locationAllowed = LocationPermissionStore.allowsAccess;
    });
    if (LocationPermissionStore.shouldAsk) {
      await showLocationPermissionSheet(context);
      if (!mounted) return;
      setState(() => _locationAllowed = LocationPermissionStore.allowsAccess);
    }
  }

  Future<void> _enableLocation() async {
    await showLocationPermissionSheet(context);
    if (!mounted) return;
    setState(() {
      _locationChecked = true;
      _locationAllowed = LocationPermissionStore.allowsAccess;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Weather Intelligence',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh live data',
            onPressed: _isLoading ? null : _refreshWeather,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationNotice(),
            _buildCurrentWeather(),
            SizedBox(height: 20.h),
            Text('7-Day Forecast', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),
            _buildForecast(),
            SizedBox(height: 20.h),
            Text('Rainfall Pattern Analysis', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen)),
            SizedBox(height: 12.h),
            _buildRainfallAnalysis(),
            SizedBox(height: 20.h),
            _buildCropAdvisory(),
            SizedBox(height: 20.h),
            _buildWeatherCorrelation(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Live data. Uses OpenWeatherMap when a key is configured (bundled by
  // default), otherwise keyless Open-Meteo. Fails silently back to the demo
  // dataset so the screen always renders, on-device and in tests.
  // ---------------------------------------------------------------------------
  Future<void> _refreshWeather() async {
    setState(() => _isLoading = true);
    try {
      final List<WeatherDay>? days;
      if (AppConfig.weatherApiKey.isNotEmpty) {
        days = await _fetchOpenWeatherMap();
      } else {
        days = await _fetchOpenMeteo();
      }
      if (days == null || days.isEmpty) throw Exception('no weather data');
      final nextForecast = days;
      if (!mounted) return;
      setState(() => _forecast = nextForecast);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live weather updated')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live weather unavailable — showing cached advisory data')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// OpenWeatherMap 5-day/3-hour forecast, aggregated into per-calendar-day
  /// buckets (max/min temperature, rainfall sum, dominant condition).
  Future<List<WeatherDay>?> _fetchOpenWeatherMap() async {
    final uri = Uri.parse(AppConfig.openWeatherMapForecastUrl).replace(queryParameters: {
      'lat': '$_lat',
      'lon': '$_lng',
      'units': 'metric',
      'appid': AppConfig.weatherApiKey,
    });
    final response = await http.get(uri).timeout(
          const Duration(seconds: AppConfig.connectTimeout),
        );
    if (response.statusCode != 200) return null;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['list'] as List?;
    if (list == null || list.isEmpty) return null;

    final byDay = <String, _DayAggregate>{};
    for (final entry in list) {
      final e = entry as Map<String, dynamic>;
      final dt = DateTime.fromMillisecondsSinceEpoch((e['dt'] as num).toInt() * 1000);
      final key = '${dt.year}-${dt.month}-${dt.day}';
      final agg = byDay.putIfAbsent(key, () => _DayAggregate(DateTime(dt.year, dt.month, dt.day)));

      final main = e['main'] as Map<String, dynamic>;
      final maxT = (main['temp_max'] as num?)?.toDouble();
      final minT = (main['temp_min'] as num?)?.toDouble();
      if (maxT != null && (agg.maxTemp == null || maxT > agg.maxTemp!)) agg.maxTemp = maxT;
      if (minT != null && (agg.minTemp == null || minT < agg.minTemp!)) agg.minTemp = minT;

      agg.rainMm += ((e['rain'] as Map<String, dynamic>?)?['3h'] as num?)?.toDouble() ?? 0.0;

      if (agg.condition == null) {
        final weatherList = e['weather'] as List?;
        final weather = (weatherList != null && weatherList.isNotEmpty)
            ? weatherList.first as Map<String, dynamic>
            : null;
        agg.condition = _conditionFromWeatherId((weather?['id'] as num?)?.toInt());
      }
    }

    final days = byDay.values.toList()..sort((a, b) => a.date.compareTo(b.date));
    return days.take(7).map((a) {
      return WeatherDay(
        date: a.date,
        maxTemp: a.maxTemp ?? 0,
        minTemp: a.minTemp ?? a.maxTemp ?? 0,
        rainMm: a.rainMm,
        condition: a.condition ?? 'sunny',
      );
    }).toList();
  }

  /// Keyless Open-Meteo daily forecast (previous behaviour).
  Future<List<WeatherDay>?> _fetchOpenMeteo() async {
    final uri = Uri.parse(AppConfig.weatherApiBaseUrl).replace(queryParameters: {
      'latitude': '$_lat',
      'longitude': '$_lng',
      'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final response = await http.get(uri, headers: {
      if (AppConfig.weatherApiHeader.isNotEmpty) 'Authorization': AppConfig.weatherApiHeader,
    }).timeout(const Duration(seconds: AppConfig.connectTimeout));

    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = body['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List).cast<String>();
    final maxs = (daily['temperature_2m_max'] as List).cast<num>();
    final mins = (daily['temperature_2m_min'] as List).cast<num>();
    final rain = (daily['precipitation_sum'] as List).cast<num>();

    final days = <WeatherDay>[];
    final count = [dates.length, maxs.length, mins.length, rain.length]
        .reduce((a, b) => a < b ? a : b);
    for (var i = 0; i < count && i < 7; i++) {
      final mm = rain[i].toDouble();
      days.add(WeatherDay(
        date: DateTime.tryParse(dates[i]) ?? DateTime.now().add(Duration(days: i)),
        maxTemp: maxs[i].toDouble(),
        minTemp: mins[i].toDouble(),
        rainMm: mm,
        condition: _conditionFromRain(mm),
      ));
    }
    return days;
  }

  /// Maps OpenWeatherMap condition ids to the app's condition labels.
  static String _conditionFromWeatherId(int? id) {
    if (id == null) return 'sunny';
    if (id < 300) return 'storm'; // 2xx thunderstorm
    if (id < 600) return 'rain'; // 3xx drizzle, 5xx rain
    if (id < 700) return 'cloud'; // 6xx snow
    if (id < 800) return 'cloud'; // 7xx atmosphere (haze, dust…)
    if (id == 800) return 'sunny'; // clear
    return 'cloud'; // 80x clouds
  }

  static String _conditionFromRain(double mm) {
    if (mm >= 20) return 'storm';
    if (mm >= 5) return 'rain';
    if (mm >= 1) return 'cloud';
    return 'sunny';
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------
  /// Banner shown while location access is denied or not yet allowed. The page
  /// keeps working with the bundled village anchor instead of blocking.
  Widget _buildLocationNotice() {
    if (!_locationChecked || _locationAllowed) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_off, size: 18.r, color: Colors.amber.shade900),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location access is off',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Showing the default village forecast for Nashik. Allow location '
                  'access for village-level accuracy.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.amber.shade900,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.amber.shade900,
                    side: BorderSide(color: Colors.amber.shade700),
                  ),
                  onPressed: _enableLocation,
                  icon: const Icon(Icons.my_location, size: 16),
                  label: Text(
                    'Allow location',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child, required String loadingKey}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _sectionLoading[loadingKey] == true
          ? SizedBox(
              height: 80.h,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : child,
    );
  }

  Widget _buildCurrentWeather() {
    final today = _forecast.first;
    return _sectionCard(
      loadingKey: 'current',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Village Weather (Nashik)',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_currentTemp.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    Text(
                      _conditionLabel(today.condition),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(today.icon, size: 64.r, color: Colors.amber[700]),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _statChip(Icons.device_thermostat, 'Avg 7d',
                    '${_avgTemp.toStringAsFixed(1)}°C'),
              ),
              Expanded(
                child: _statChip(Icons.water_drop, 'Week Rain',
                    '${_weekRainfall.toStringAsFixed(0)} mm'),
              ),
              Expanded(
                child: _statChip(Icons.thermostat, 'Today L/H',
                    '${today.minTemp.toStringAsFixed(0)}°/${today.maxTemp.toStringAsFixed(0)}°'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20.r, color: _primaryGreen),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildForecast() {
    return _sectionCard(
      loadingKey: 'forecast',
      child: SizedBox(
        // Tall enough for the four stacked rows (day, icon, temperature, rain)
        // even when the device font scale exceeds the design scale — previously
        // overflowed at the bottom by ~17 px; extra 26 logical-px margin fixes that.
        height: 168.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _forecast.length,
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
          itemBuilder: (ctx, i) {
            final day = _forecast[i];
            return Container(
              width: 88.w,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: i == 0 ? _primaryGreen.withValues(alpha: 0.08) : Colors.grey[50],
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: i == 0 ? _primaryGreen : Colors.grey.shade300,
                ),
              ),
              // Clamp text scaling inside the fixed-height strip so a larger
              // accessibility font size cannot push the row past the bottom.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i == 0 ? 'Today' : day.dayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                    Icon(day.icon, size: 24.r, color: _conditionColor(day.condition)),
                    Text(
                      '${day.maxTemp.toStringAsFixed(0)}°/${day.minTemp.toStringAsFixed(0)}°',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    SizedBox(
                      height: 13.h,
                      child: day.rainMm > 0
                          ? Text(
                              '${day.rainMm.toStringAsFixed(0)} mm',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.sp, color: Colors.blue[700]),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRainfallAnalysis() {
    final maxRain = _forecast.fold(0.0, (m, d) => d.rainMm > m ? d.rainMm : m);
    return _sectionCard(
      loadingKey: 'rainfall',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly total: ${_weekRainfall.toStringAsFixed(1)} mm',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),
          ..._forecast.map((day) {
            final fraction = maxRain <= 0 ? 0.0 : day.rainMm / maxRain;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.w,
                    child: Text(day.dayLabel, style: TextStyle(fontSize: 11.sp)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 10.h,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          day.rainMm >= 5 ? Colors.blue[600]! : Colors.blue[300]!,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 52.w,
                    child: Text(
                      '${day.rainMm.toStringAsFixed(1)} mm',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCropAdvisory() {
    final rainyDays = _forecast.where((d) => d.rainMm >= 5).length;
    final advisory = rainyDays >= 3
        ? 'Heavy rainfall expected on $rainyDays of the next 7 days. Delay urea top-dressing '
            'and pesticide sprays, clear field drainage channels, and shift harvested produce '
            'into covered storage.'
        : 'Mostly dry conditions over the next 7 days. A good window for sowing, inter-cultivation '
            'and spray operations. Irrigate standing crops every 5-7 days and mulch beds to retain soil moisture.';

    return _sectionCard(
      loadingKey: 'advisory',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Crop Advisory (AI + IMD blended)',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            advisory,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[800], height: 1.5),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: const [
              AdvisoryChip('Wheat: irrigation window open'),
              AdvisoryChip('Onion: watch thrips in dry spell'),
              AdvisoryChip('Grapes: prune after rain stops'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCorrelation() {
    final hotDays = _forecast.where((d) => d.maxTemp >= 30).length;
    final insight = hotDays >= 3
        ? 'Correlation engine: $hotDays hot days (≥30°C) ahead — wheat grain filling may be '
            'affected. Consider evening irrigation and consider MSP-aware early marketing of '
            'ready lots via the Mandi tracker.'
        : 'Correlation engine: temperatures within the normal band for this week. Historical '
            'yields for your district stay stable in this range — no heat-stress action needed.';

    return _sectionCard(
      loadingKey: 'correlation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 20.r, color: _primaryGreen),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Weather – Yield Correlation',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            insight,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[800], height: 1.5),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.query_stats, size: 18),
                  label: const Text('View mandi impact'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MandiImpactScreen(forecast: _forecast),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: const Text('Set alert'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeatherAlertSetScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _conditionLabel(String condition) {
    switch (condition) {
      case 'rain':
        return 'Rain likely';
      case 'storm':
        return 'Thunderstorm risk';
      case 'cloud':
        return 'Partly cloudy';
      default:
        return 'Sunny';
    }
  }

  static Color _conditionColor(String condition) {
    switch (condition) {
      case 'rain':
        return Colors.blue[600]!;
      case 'storm':
        return Colors.indigo;
      case 'cloud':
        return Colors.blueGrey;
      default:
        return Colors.amber[700]!;
    }
  }
}

/// Small pill label used inside the crop advisory section.
class AdvisoryChip extends StatelessWidget {
  final String label;

  const AdvisoryChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D3E).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF1B4D3E)),
      ),
    );
  }
}

/// Mutable per-day accumulator used while collapsing OpenWeatherMap's
/// 3-hourly forecast entries into daily buckets.
class _DayAggregate {
  final DateTime date;
  double? maxTemp;
  double? minTemp;
  double rainMm = 0.0;
  String? condition;

  _DayAggregate(this.date);
}


