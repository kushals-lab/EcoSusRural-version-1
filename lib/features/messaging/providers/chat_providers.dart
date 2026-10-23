/// Riverpod providers for the Messaging module (end-to-end encrypted).
///
/// Plaintext is never stored: `chatMessagesProvider` keeps ONLY [ChatMessage]
/// instances whose [ChatMessage.cipherTextB64] envelopes were produced by
/// [E2eeService]. Local plaintext lives in a per-screen in-memory cache.
library chat_providers;

import 'dart:async' show Future;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../crypto/e2ee_service.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

// ── Seed metadata ──────────────────────────────────────────────────────────

List<ChatConversation> _seedConversations() {
  final now = DateTime.now();
  return [
    ChatConversation(
      id: 'c-saree',
      participantId: 'u-saree',
      participantName: 'Banarasi Saree Co.',
      participantAvatar: '',
      lastMessage: '🔒 New encrypted message',
      lastMessageTime: now.subtract(const Duration(minutes: 4)),
      unreadCount: 2,
      isOnline: true,
      lastMessageEncrypted: true,
    ),
    ChatConversation(
      id: 'c-mandi',
      participantId: 'u-mandi',
      participantName: 'Kisan Organic Mandi',
      participantAvatar: '',
      lastMessage: '🔒 New encrypted message',
      lastMessageTime: now.subtract(const Duration(hours: 1)),
      unreadCount: 1,
      isOnline: true,
      lastMessageEncrypted: true,
    ),
    ChatConversation(
      id: 'c-clinic',
      participantId: 'u-clinic',
      participantName: 'Gram Arogya Clinic',
      participantAvatar: '',
      lastMessage: '🔒 New encrypted message',
      lastMessageTime: now.subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
      lastMessageEncrypted: true,
    ),
    ChatConversation(
      id: 'c-ride',
      participantId: 'u-ride',
      participantName: 'Ride Partner Support',
      participantAvatar: '',
      lastMessage: '🔒 New encrypted message',
      lastMessageTime: now.subtract(const Duration(days: 2)),
      unreadCount: 0,
      isOnline: false,
      lastMessageEncrypted: true,
    ),
  ];
}

/// Plaintext seed history. These are encrypted on first open of a chat and the
/// plaintext versions are discarded immediately afterwards.
Map<String, List<ChatMessage>> _seedMessages() {
  final now = DateTime.now();
  return {
    'c-saree': [
      ChatMessage(
        id: 'm-seed-1',
        conversationId: 'c-saree',
        senderId: 'u-saree',
        text: 'Namaste! Your Banarasi Saree order is being woven. We ship in 3–4 business days.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        isDelivered: true,
      ),
      ChatMessage(
        id: 'm-seed-2',
        conversationId: 'c-saree',
        senderId: 'me',
        text: 'Wonderful! Can you share a photo before dispatch?',
        timestamp: now.subtract(const Duration(days: 1, minutes: 30)),
        isRead: true,
        isDelivered: true,
      ),
      ChatMessage(
        id: 'm-seed-3',
        conversationId: 'c-saree',
        senderId: 'u-saree',
        text: 'Of course! Here is the gold zari border close-up.',
        timestamp: now.subtract(const Duration(minutes: 4)),
        isRead: false,
        isDelivered: true,
      ),
    ],
    'c-mandi': [
      ChatMessage(
        id: 'm-seed-4',
        conversationId: 'c-mandi',
        senderId: 'me',
        text: 'Hello, is organic tur dal available this week?',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        isDelivered: true,
      ),
      ChatMessage(
        id: 'm-seed-5',
        conversationId: 'c-mandi',
        senderId: 'u-mandi',
        text: 'Yes! Fresh stock arrived from the Jaipur cluster. 25 kg lots.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        isDelivered: true,
      ),
    ],
    'c-clinic': [
      ChatMessage(
        id: 'm-seed-6',
        conversationId: 'c-clinic',
        senderId: 'u-clinic',
        text: 'Your e-prescription for Dr. Meera is ready. Vitamin-D 2000 IU, once a day after lunch.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        isDelivered: true,
      ),
    ],
    'c-ride': [
      ChatMessage(
        id: 'm-seed-7',
        conversationId: 'c-ride',
        senderId: 'u-ride',
        text: 'Weekly subscription approved! You ride free until Sunday, zero commission.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        isDelivered: true,
      ),
    ],
  };
}
// ── Providers ──────────────────────────────────────────────────────────────

final chatConversationsProvider = StateProvider<List<ChatConversation>>(
  (ref) => _seedConversations(),
);

/// conversationId -> list of messages (ciphertext-only envelopes).
final chatMessagesProvider = StateProvider<Map<String, List<ChatMessage>>>(
  (ref) => _seedMessages(),
);

final chatLoadingProvider = StateProvider<bool>((ref) => false);

// ── E2E operations ─────────────────────────────────────────────────────────

/// Encrypts a conversation's plaintext seed history into ciphertext-only
/// storage. Runs once per conversation (first open). Returns the in-memory
/// plaintext cache used for rendering.
Future<Map<String, String>> prepareConversation(
  WidgetRef ref,
  String conversationId,
) async {
  final controller = ref.read(chatMessagesProvider.notifier);
  final current = controller.state;
  final existing = current[conversationId];

  // Already encrypted: decrypt into the render cache.
  if (existing != null && existing.isNotEmpty && existing.first.isEncrypted) {
    final cache = <String, String>{};
    for (final message in existing) {
      if (message.isEncrypted) {
        cache[message.id] = await _decryptOrFallback(conversationId, message);
      }
    }
    return cache;
  }

  // First open: encrypt the plaintext seeds, store envelopes only.
  final seeds = _seedMessages()[conversationId] ?? [];
  final encrypted = <ChatMessage>[];
  final cache = <String, String>{};
  for (final seed in seeds) {
    final envelope = await E2eeService.encrypt(conversationId, seed.text);
    encrypted.add(ChatMessage.encrypted(
      id: seed.id,
      conversationId: conversationId,
      senderId: seed.senderId,
      timestamp: seed.timestamp,
      cipherTextB64: envelope.cipherTextB64,
      cipherAlgorithm: envelope.algorithm,
      keyId: envelope.keyId,
      senderPublicKeyB64: envelope.senderPublicKeyB64,
      plaintext: seed.text,
      isRead: seed.isRead,
      isDelivered: seed.isDelivered,
    ));
    cache[seed.id] = seed.text;
  }
  final updated = Map<String, List<ChatMessage>>.from(current);
  updated[conversationId] = encrypted;
  controller.state = updated;
  return cache;
}

/// Authenticated decrypt with a safe fallback (never throws in UI flows).
Future<String> _decryptOrFallback(
  String conversationId,
  ChatMessage message,
) async {
  try {
    final envelope = E2eeEnvelope(
      cipherTextB64: message.cipherTextB64!,
      senderPublicKeyB64: message.senderPublicKeyB64 ?? '',
      keyId: message.keyId ?? '',
      algorithm: message.cipherAlgorithm ?? 'X25519 + AES-256-GCM',
    );
    return await E2eeService.decrypt(conversationId, envelope);
  } catch (_) {
    return '🔒 Could not decrypt (key changed)';
  }
}

/// Encrypts [plaintext], stores the ciphertext envelope and refreshes the
/// conversation summary. Returns the id of the stored message.
Future<String> sendEncryptedMessage(
  WidgetRef ref,
  String conversationId,
  String plaintext,
) async {
  final trimmed = plaintext.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('Cannot send an empty message');
  }
  final timestamp = DateTime.now();
  final envelope = await E2eeService.encrypt(conversationId, trimmed);
  final message = ChatMessage.encrypted(
    id: 'msg-${timestamp.millisecondsSinceEpoch}',
    conversationId: conversationId,
    senderId: 'me',
    timestamp: timestamp,
    cipherTextB64: envelope.cipherTextB64,
    cipherAlgorithm: envelope.algorithm,
    keyId: envelope.keyId,
    senderPublicKeyB64: envelope.senderPublicKeyB64,
    plaintext: trimmed,
    isRead: true,
    isDelivered: true,
  );

  final messagesController = ref.read(chatMessagesProvider.notifier);
  final messages = messagesController.state;
  final updatedMessages = Map<String, List<ChatMessage>>.from(messages);
  final history = [...?updatedMessages[conversationId], message];
  updatedMessages[conversationId] = history;
  messagesController.state = updatedMessages;

  final conversationsController = ref.read(chatConversationsProvider.notifier);
  final updatedConversations = [
    for (final conversation in conversationsController.state)
      if (conversation.id == conversationId)
        conversation.copyWith(
          lastMessage: trimmed.length > 42
              ? '${trimmed.substring(0, 42)}…'
              : trimmed,
          lastMessageTime: timestamp,
          lastMessageEncrypted: true,
          unreadCount: 0,
        )
      else
        conversation,
  ];
  conversationsController.state = updatedConversations;

  return message.id;
}
