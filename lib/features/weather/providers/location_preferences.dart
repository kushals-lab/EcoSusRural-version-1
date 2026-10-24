import '../../../core/storage/offline_workspace.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LocationPurpose { weather, farm, business, market }
class SavedPlace {
  final String country, state, district, city, postalCode, timezone;
  final double? latitude, longitude;
  const SavedPlace({this.country = '', this.state = '', this.district = '', this.city = '',
    this.postalCode = '', this.timezone = '', this.latitude, this.longitude});
  String get label => [city, district, state, country].where((s) => s.isNotEmpty).toSet().join(', ');
  bool get hasCoordinates => latitude != null && longitude != null;
  Map<String, dynamic> toJson() => {'country': country, 'state': state, 'district': district,
    'city': city, 'postalCode': postalCode, 'timezone': timezone, 'latitude': latitude, 'longitude': longitude};
  factory SavedPlace.fromJson(Map<String, dynamic> j) => SavedPlace(country: j['country'] ?? '',
    state: j['state'] ?? '', district: j['district'] ?? '', city: j['city'] ?? '',
    postalCode: j['postalCode'] ?? '', timezone: j['timezone'] ?? '',
    latitude: (j['latitude'] as num?)?.toDouble(), longitude: (j['longitude'] as num?)?.toDouble());
  factory SavedPlace.fromSearch(Map<String, dynamic> j) => SavedPlace(country: j['country'] ?? '',
    state: j['admin1'] ?? '', district: j['admin2'] ?? '', city: j['name'] ?? '',
    timezone: j['timezone'] ?? '', postalCode: (j['postcodes'] as List?)?.firstOrNull?.toString() ?? '',
    latitude: (j['latitude'] as num?)?.toDouble(), longitude: (j['longitude'] as num?)?.toDouble());
}
final locationPreferencesProvider = StateNotifierProvider<LocationPreferences, Map<LocationPurpose, SavedPlace>>(
  (ref) => LocationPreferences());
class LocationPreferences extends StateNotifier<Map<LocationPurpose, SavedPlace>> {
  LocationPreferences() : super({}) { load(); }
  SavedPlace? deviceLocation; // Session-only: never persists precise device coordinates.
  Future<String> _key(SharedPreferences prefs) async =>
    'ecosus.locations.${(prefs.getString('ecosus.auth.user') ?? 'guest').split('|').first}';
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _key(prefs));
    try {
      final data = raw == null ? <String, dynamic>{} : jsonDecode(raw) as Map<String, dynamic>;
      if (mounted) {
        state = {for (final purpose in LocationPurpose.values)
        if (data[purpose.name] is Map) purpose: SavedPlace.fromJson(Map<String, dynamic>.from(data[purpose.name]))};
      }
    } catch (_) { if (mounted) state = {}; }
  }
  Future<void> save(LocationPurpose purpose, SavedPlace place) async {
    final prefs = await SharedPreferences.getInstance();
    final next = {...state, purpose: place};
    await prefs.setString(await _key(prefs), jsonEncode({for (final e in next.entries) e.key.name: e.value.toJson()}));
    await OfflineWorkspace.save('locations', purpose.name, place.toJson(), queued: true);
    await OfflineWorkspace.sync();
    if (mounted) state = next;
  }
}
