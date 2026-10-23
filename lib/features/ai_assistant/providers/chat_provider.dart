import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasImage; // True if the user uploaded a pest photo

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.hasImage = false,
  });
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([
    ChatMessage(
      id: '0',
      text: 'Namaste! I am your EcoSusRural AI Assistant. How can I help with your farm today? You can ask a question or upload a photo of a plant.',
      isUser: false,
      timestamp: DateTime.now(),
    )
  ]);

  void sendMessage(String text, {bool hasImage = false}) async {
    if (text.isEmpty && !hasImage) return;

    // 1. Add user message to chat
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      hasImage: hasImage,
    );
    state = [...state, userMsg];

    // 2. Photo flow: this quick button captures no image bytes (no camera
    // plugin), so nothing can be analysed. We never present a claim of a
    // diagnosis. Real uploads go through the Search tab -> camera/gallery,
    // which sends actual bytes to the gateway vision pipeline.
    if (hasImage) {
      _appendAiReply('I cannot analyse a photo here because this quick button '
          'does not capture any image. Please open the Search tab, tap the camera '
          'or gallery icon, and upload a real photo — the Rural Intelligence '
          'service will then inspect it honestly and tell you exactly what it used.');
      return;
    }

    // 3. Text flow: Rural Intelligence gateway (self-hosted). No third-party
    // generative API and no provider key are involved anywhere. Offline/error
    // fallback keeps the chat usable when the gateway is unreachable.
    final aiReply = await _fetchAiReply(text) ??
        'I could not reach the Rural Intelligence service. Please check your connection and try again, or ask again later.';
    _appendAiReply(aiReply);
  }

  void _appendAiReply(String text) {
    final aiMsg = ChatMessage(
      id: "${DateTime.now()}_ai",
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = [...state, aiMsg];
  }

  /// Calls the self-hosted Rural Intelligence gateway (/api/ai/answer) with
  /// the query plus the last few turns for follow-up context. Returns the
  /// composed answer (with cited sources appended as text), or null on any
  /// failure so the caller falls back to the offline advisory.
  Future<String?> _fetchAiReply(String userText) async {
    try {
      // Recent conversation history (oldest -> newest, greeting excluded).
      // Single reverse pass over the tail: no intermediate list copies.
      final history = <Map<String, String>>[];
      for (var i = state.length - 1; i >= 0 && history.length < 6; i--) {
        final m = state[i];
        if (m.id == '0' || m.text.trim().isEmpty) continue;
        if (m.isUser) {
          history.add({'q': m.text});
        } else if (history.isNotEmpty) {
          history[history.length - 1] = {...history[history.length - 1], 'a': m.text};
        }
      }

      final response = await http.post(
        Uri.parse('${AppConfig.aiGatewayUrl}/ai/answer'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': userText,
          'history': history.reversed.toList(),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final answer = body['answer'];
      if (answer is! String || answer.trim().isEmpty) return null;
      final sb = StringBuffer(answer.trim());
      final sources = body['sources'];
      if (sources is List && sources.isNotEmpty) {
        sb.writeln();
        sb.writeln();
        sb.write('Sources:');
        var n = 0;
        for (final s in sources.whereType<Map>()) {
          final title = '${s['title'] ?? 'source'}';
          final url = '${s['url'] ?? ''}';
          if (url.isEmpty || url == 'null') continue;
          n++;
          sb.write('\n$n. $title — $url');
        }
      }
      final disclaimer = body['disclaimer'];
      if (disclaimer is String && disclaimer.trim().isNotEmpty) {
        sb.writeln();
        sb.write('Note: $disclaimer');
      }
      return sb.toString();
    } catch (_) {
      return null;
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(),
);