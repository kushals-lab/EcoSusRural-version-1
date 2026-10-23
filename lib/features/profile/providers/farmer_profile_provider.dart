import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerProfileState {
  final String name;
  final String landSize;
  final String landUnit; // e.g., Acres, Hectares, Bigha
  final String soilType;
  final List<String> selectedCrops;
  final bool isSubmitting;
  final String? errorMessage;

  FarmerProfileState({
    this.name = '',
    this.landSize = '',
    this.landUnit = 'Acres',
    this.soilType = 'Unknown / पता नहीं',
    this.selectedCrops = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  FarmerProfileState copyWith({
    String? name,
    String? landSize,
    String? landUnit,
    String? soilType,
    List<String>? selectedCrops,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return FarmerProfileState(
      name: name ?? this.name,
      landSize: landSize ?? this.landSize,
      landUnit: landUnit ?? this.landUnit,
      soilType: soilType ?? this.soilType,
      selectedCrops: selectedCrops ?? this.selectedCrops,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Serializes the profile for local persistence.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'landSize': landSize,
      'landUnit': landUnit,
      'soilType': soilType,
      'selectedCrops': selectedCrops,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Stores the farmer profile on device (shared preferences) under a
/// per-user key. Previously this was saved to Firestore; the local store
/// keeps the same flow working with no external service required.
class FarmerProfileNotifier extends StateNotifier<FarmerProfileState> {
  FarmerProfileNotifier() : super(FarmerProfileState()) {
    _loadProfile();
  }

  static const String _profileKeyPrefix = 'ecosus.farmer_profile.';
  static const String _sessionKey = 'ecosus.auth.user';

  /// Returns the storage key for the currently signed-in user, or `null`
  /// when nobody is signed in.
  Future<String?> _storageKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString(_sessionKey);
      if (session == null || session.isEmpty) return null;
      final uid = session.split('|').first;
      return '$_profileKeyPrefix$uid';
    } catch (_) {
      return null;
    }
  }

  /// Loads a previously saved profile for the signed-in user.
  Future<void> _loadProfile() async {
    try {
      final key = await _storageKey();
      if (key == null) return;
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = FarmerProfileState(
        name: (map['name'] as String?) ?? '',
        landSize: (map['landSize'] as String?) ?? '',
        landUnit: (map['landUnit'] as String?) ?? 'Acres',
        soilType: (map['soilType'] as String?) ?? 'Unknown / पता नहीं',
        selectedCrops:
            ((map['selectedCrops'] as List<dynamic>?) ?? const [])
                .map((e) => e.toString())
                .toList(),
      );
    } catch (_) {
      // Corrupt or unreadable data — start with a fresh profile.
    }
  }

  void updateName(String name) =>
      state = state.copyWith(name: name, clearErrorMessage: true);

  void updateLandSize(String size) => state = state.copyWith(landSize: size);

  void updateLandUnit(String unit) => state = state.copyWith(landUnit: unit);

  void updateSoilType(String soil) => state = state.copyWith(soilType: soil);

  void toggleCrop(String crop) {
    final crops = List<String>.from(state.selectedCrops);
    if (crops.contains(crop)) {
      crops.remove(crop);
    } else {
      crops.add(crop);
    }
    state = state.copyWith(selectedCrops: crops);
  }

  /// Saves the farmer profile on device for the currently signed-in user.
  Future<bool> submitProfile() async {
    if (state.name.trim().isEmpty || state.landSize.trim().isEmpty) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Please provide your name and land size.',
      );
      return false;
    }

    String? key;
    try {
      key = await _storageKey();
    } catch (_) {
      key = null;
    }
    if (key == null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'You must be signed in to save your profile.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(state.toMap()));

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to save profile. Please try again.',
      );
      return false;
    }
  }
}

final farmerProfileProvider = StateNotifierProvider<FarmerProfileNotifier, FarmerProfileState>(
  (ref) => FarmerProfileNotifier(),
);
