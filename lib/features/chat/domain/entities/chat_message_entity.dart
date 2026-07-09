class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.threadId,
    required this.body,
    required this.createdAt,
    required this.isMine,
    this.senderId,
    this.senderName,
    this.status,
  });

  final String id;
  final String threadId;
  final String body;
  final DateTime createdAt;
  final bool isMine;
  final String? senderId;
  final String? senderName;
  final String? status;
}
