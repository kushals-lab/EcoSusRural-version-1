import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

/// Real authentication must install the server-issued access token in memory.
/// Local demo OTPs and user-supplied IDs never authorize database access.
class AccountSync {
  static String? accessToken;
  static String? accountId;
  static Future<Map<String, dynamic>> send(String path, Map<String, dynamic> body) async {
    if (accessToken == null || accountId == null) throw StateError('A verified server sign-in is required. Your data has not been submitted.');
    final client = http.Client();
    try {
      final result = await client.post(apiUri('/account/$path'), headers: {
        'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'}, body: jsonEncode(body)).timeout(const Duration(seconds: 20));
      if (result.statusCode < 200 || result.statusCode >= 300) throw ApiException(result.statusCode);
      return Map<String, dynamic>.from(jsonDecode(result.body));
    } finally { client.close(); }
  }
}
