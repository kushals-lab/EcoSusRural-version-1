
/// A chat message. When [cipherTextB64] is set the message is stored ONLY as
/// an end-to-end encrypted envelope — [text] is the locally decrypted plaintext
/// and lives only in memory.
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String type;
  final String? mediaUrl;
  final bool isRead;
  final bool isDelivered;

  // E2EE envelope (persisted / transmitted). `text` is the local plaintext.
  final String? cipherTextB64;
  final String? cipherAlgorithm;
  final String? keyId;
  final String? senderPublicKeyB64;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.type = 'text',
    this.mediaUrl,
    this.isRead = false,
    this.isDelivered = false,
    this.cipherTextB64,
    this.cipherAlgorithm,
    this.keyId,
    this.senderPublicKeyB64,
  });

  bool get isEncrypted => cipherTextB64 != null && cipherTextB64!.isNotEmpty;

  bool get isMine => senderId == 'me' || senderId == 'me-2';

  /// Builds an encrypted (ciphertext-only) message from an E2E envelope.
  factory ChatMessage.encrypted({
    required String id,
    required String conversationId,
    required String senderId,
    required DateTime timestamp,
    required String cipherTextB64,
    required String cipherAlgorithm,
    required String keyId,
    required String senderPublicKeyB64,
    String plaintext = '',
    String type = 'text',
    bool isRead = false,
    bool isDelivered = false,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      text: plaintext,
      timestamp: timestamp,
      type: type,
      isRead: isRead,
      isDelivered: isDelivered,
      cipherTextB64: cipherTextB64,
      cipherAlgorithm: cipherAlgorithm,
      keyId: keyId,
      senderPublicKeyB64: senderPublicKeyB64,
    );
  }
}
