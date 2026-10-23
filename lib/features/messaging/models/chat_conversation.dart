
class ChatConversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? lastMessageType;
  final bool isPinned;
  final bool lastMessageEncrypted;

  ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    this.lastMessageType,
    this.isPinned = false,
    this.lastMessageEncrypted = false,
  });

  ChatConversation copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    bool? lastMessageEncrypted,
    bool? isPinned,
  }) {
    return ChatConversation(
      id: id,
      participantId: participantId,
      participantName: participantName,
      participantAvatar: participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastMessageType: lastMessageType,
      isPinned: isPinned ?? this.isPinned,
      lastMessageEncrypted: lastMessageEncrypted ?? this.lastMessageEncrypted,
    );
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      participantId: json['participantId'] as String,
      participantName: json['participantName'] as String,
      participantAvatar: json['participantAvatar'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.tryParse(json['lastMessageTime'] as String? ?? '') ?? DateTime.now(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      lastMessageType: json['lastMessageType'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      lastMessageEncrypted: json['lastMessageEncrypted'] as bool? ?? false,
    );
  }
}

enum MessageType { text, image, video, audio, file, payment, location }
