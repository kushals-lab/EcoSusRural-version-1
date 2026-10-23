import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';

/// User Location State
class UserLocation {
  final double latitude;
  final double longitude;
  final String stateName;
  final String districtName;
  final String marketName;
  final bool isPermissionGranted;
  final bool isManualSelection;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.stateName,
    required this.districtName,
    required this.marketName,
    this.isPermissionGranted = false,
    this.isManualSelection = false,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'stateName': stateName,
        'districtName': districtName,
        'marketName': marketName,
        'isPermissionGranted': isPermissionGranted,
        'isManualSelection': isManualSelection,
      };

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 21.5999,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 71.2162,
        stateName: json['stateName'] as String? ?? 'Gujarat',
        districtName: json['districtName'] as String? ?? 'Amreli',
        marketName: json['marketName'] as String? ?? 'Amreli APMC',
        isPermissionGranted: json['isPermissionGranted'] as bool? ?? false,
        isManualSelection: json['isManualSelection'] as bool? ?? false,
      );
}

/// Location Provider with fallback and persistence
final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, UserLocation>((ref) {
  return UserLocationNotifier();
});

class UserLocationNotifier extends StateNotifier<UserLocation> {
  static const String _storageKey = 'ecosus.user.location';

  UserLocationNotifier()
      : super(const UserLocation(
          latitude: 21.5999,
          longitude: 71.2162,
          stateName: 'Gujarat',
          districtName: 'Amreli',
          marketName: 'Amreli APMC',
        )) {
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final cached = DependencyInjection.localStorage.getJson(_storageKey);
    if (cached != null && cached['data'] is Map<String, dynamic>) {
      state = UserLocation.fromJson(cached['data'] as Map<String, dynamic>);
    }
  }

  /// Update location manually (when GPS permission is denied or user chooses another district)
  Future<void> setManualLocation({
    required String stateName,
    required String districtName,
    required String marketName,
    double? latitude,
    double? longitude,
  }) async {
    state = UserLocation(
      latitude: latitude ?? state.latitude,
      longitude: longitude ?? state.longitude,
      stateName: stateName,
      districtName: districtName,
      marketName: marketName,
      isPermissionGranted: state.isPermissionGranted,
      isManualSelection: true,
    );
    await DependencyInjection.localStorage.setJson(_storageKey, state.toJson());
  }

  /// Request runtime GPS coordinates & update location
  Future<void> updateFromGps({
    required double lat,
    required double lon,
    required String detectedState,
    required String detectedDistrict,
    required String nearestMarket,
  }) async {
    state = UserLocation(
      latitude: lat,
      longitude: lon,
      stateName: detectedState,
      districtName: detectedDistrict,
      marketName: nearestMarket,
      isPermissionGranted: true,
      isManualSelection: false,
    );
    await DependencyInjection.localStorage.setJson(_storageKey, state.toJson());
  }
}
