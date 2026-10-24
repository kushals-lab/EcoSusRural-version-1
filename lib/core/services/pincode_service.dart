import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for Postal / PIN Code validation and location data result.
class PincodeResult {
  final bool isValid;
  final String postalCode;
  final String country;
  final String countryCode;
  final String state;
  final String district;
  final String city;
  final String villageOrArea;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  const PincodeResult({
    required this.isValid,
    this.postalCode = '',
    this.country = '',
    this.countryCode = '',
    this.state = '',
    this.district = '',
    this.city = '',
    this.villageOrArea = '',
    this.latitude,
    this.longitude,
    this.errorMessage,
  });

  /// Formatted string combining address components for auto-filling address forms.
  String get formattedAddress {
    final parts = [villageOrArea, city, district, state, country]
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final unique = <String>[];
    for (final part in parts) {
      if (!unique.contains(part)) {
        unique.add(part);
      }
    }
    return unique.join(', ');
  }

  @override
  String toString() {
    return 'PincodeResult(isValid: $isValid, code: $postalCode, country: $country, state: $state, district: $district, city: $city, address: $formattedAddress)';
  }
}

/// Service to verify PIN codes and postal codes using Zipcodebase API
/// (Key: ea0c3830-cff0-11f1-b2c8-d52714d5e59b) with Indian Postal Pincode API
/// and Zippopotam fallbacks.
class PincodeService {
  static const String _zipcodebaseApiKey = 'ea0c3830-cff0-11f1-b2c8-d52714d5e59b';
  static const String _zipcodebaseApiUrl = 'https://app.zipcodebase.com/api/v1/search';
  static const String _indiaPostApiUrl = 'https://api.postalpincode.in/pincode';
  static const String _zippopotamUrl = 'https://api.zippopotam.us';

  /// Map common 2-letter country codes to full country names.
  static const Map<String, String> _countryCodeMap = {
    'IN': 'India',
    'US': 'United States',
    'GB': 'United Kingdom',
    'CA': 'Canada',
    'AU': 'Australia',
    'DE': 'Germany',
    'FR': 'France',
    'JP': 'Japan',
    'BR': 'Brazil',
    'ZA': 'South Africa',
    'NP': 'Nepal',
    'BD': 'Bangladesh',
    'LK': 'Sri Lanka',
    'PK': 'Pakistan',
    'AE': 'United Arab Emirates',
  };

  /// Main method to verify a PIN / Postal code and fetch address details.
  static Future<PincodeResult> verifyAndFetch(
    String rawCode, {
    String? preferredCountryCode,
  }) async {
    final code = rawCode.trim();
    if (code.isEmpty) {
      return const PincodeResult(
        isValid: false,
        errorMessage: 'Please enter a PIN or postal code.',
      );
    }

    // Basic format validation (3 to 10 alphanumeric characters/hyphens)
    final cleanCode = code.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanCode.length < 3 || cleanCode.length > 10) {
      return const PincodeResult(
        isValid: false,
        errorMessage: 'Invalid PIN or postal code format. Please check and enter again.',
      );
    }

    // 1. Try Zipcodebase API first (Primary API with provided API key)
    try {
      final queryParams = {
        'apikey': _zipcodebaseApiKey,
        'codes': cleanCode,
        if (preferredCountryCode != null && preferredCountryCode.isNotEmpty)
          'country': preferredCountryCode,
      };

      final uri = Uri.parse(_zipcodebaseApiUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = data['results'];

        if (results is Map && results.containsKey(cleanCode)) {
          final List codeResults = results[cleanCode] as List;
          if (codeResults.isNotEmpty) {
            final first = codeResults.first as Map<String, dynamic>;

            final cCode = (first['country_code'] ?? preferredCountryCode ?? '').toString().toUpperCase();
            final cName = _countryCodeMap[cCode] ?? cCode;
            final state = (first['state'] ?? first['province'] ?? '').toString();
            final province = (first['province'] ?? '').toString();
            final city = (first['city'] ?? first['city_en'] ?? '').toString();
            final lat = double.tryParse(first['latitude']?.toString() ?? '');
            final lng = double.tryParse(first['longitude']?.toString() ?? '');

            return PincodeResult(
              isValid: true,
              postalCode: cleanCode,
              country: cName,
              countryCode: cCode,
              state: state,
              district: province.isNotEmpty && province != state ? province : '',
              city: city,
              villageOrArea: city,
              latitude: lat,
              longitude: lng,
            );
          }
        }
      }
    } catch (_) {
      // Fallback if Zipcodebase fails or times out
    }

    // 2. If 6-digit numeric PIN code (typical for Indian PIN codes), query Indian Postal API
    if (RegExp(r'^\d{6}$').hasMatch(cleanCode)) {
      try {
        final uri = Uri.parse('$_indiaPostApiUrl/$cleanCode');
        final response = await http.get(uri).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            final first = data.first as Map<String, dynamic>;
            final status = first['Status']?.toString();

            if (status == 'Success' && first['PostOffice'] is List) {
              final postOffices = first['PostOffice'] as List;
              if (postOffices.isNotEmpty) {
                final po = postOffices.first as Map<String, dynamic>;

                final state = (po['State'] ?? '').toString();
                final district = (po['District'] ?? '').toString();
                final poName = (po['Name'] ?? po['Block'] ?? '').toString();
                final country = (po['Country'] ?? 'India').toString();

                return PincodeResult(
                  isValid: true,
                  postalCode: cleanCode,
                  country: country,
                  countryCode: 'IN',
                  state: state,
                  district: district,
                  city: poName,
                  villageOrArea: poName,
                );
              }
            }
          }
        }
      } catch (_) {
        // Fallback to Zippopotam
      }
    }

    // 3. Fallback: Zippopotam API
    final String cCodeForZippo = (preferredCountryCode ?? 'IN').toUpperCase();
    try {
      final uri = Uri.parse('$_zippopotamUrl/$cCodeForZippo/$cleanCode');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final country = (data['country'] ?? _countryCodeMap[cCodeForZippo] ?? cCodeForZippo).toString();
        final places = data['places'] as List?;

        if (places != null && places.isNotEmpty) {
          final place = places.first as Map<String, dynamic>;
          final placeName = (place['place name'] ?? '').toString();
          final state = (place['state'] ?? '').toString();
          final lat = double.tryParse(place['latitude']?.toString() ?? '');
          final lng = double.tryParse(place['longitude']?.toString() ?? '');

          return PincodeResult(
            isValid: true,
            postalCode: cleanCode,
            country: country,
            countryCode: cCodeForZippo,
            state: state,
            district: '',
            city: placeName,
            villageOrArea: placeName,
            latitude: lat,
            longitude: lng,
          );
        }
      }
    } catch (_) {}

    // If all lookup APIs returned no data or indicated invalid code:
    return const PincodeResult(
      isValid: false,
      errorMessage: 'Invalid PIN or postal code. Verification failed — please enter a valid code.',
    );
  }
}
