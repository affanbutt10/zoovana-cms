class ChatThreadEntity {
  const ChatThreadEntity({
    required this.id,
    required this.participantName,
    this.participantAvatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.contextLabel,
  });

  final String id;
  final String participantName;
  final String? participantAvatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? contextLabel;

  bool get hasUnread => unreadCount > 0;
}
