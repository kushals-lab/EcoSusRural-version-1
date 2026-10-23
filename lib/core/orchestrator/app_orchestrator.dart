import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AppOrchestrator {
  static Future<Map<String, dynamic>> executePipeline(int value) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/gateway/forward-ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'value': value}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}