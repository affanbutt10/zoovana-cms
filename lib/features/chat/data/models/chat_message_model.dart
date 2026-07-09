import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel {
  const ChatMessageModel({
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

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] is Map<String, dynamic>
        ? json['sender'] as Map<String, dynamic>
        : null;

    return ChatMessageModel(
      id: _string(json['id'] ?? json['message_id']),
      threadId: _string(json['thread_id'] ?? json['chat_id']),
      body: _string(json['body'] ?? json['message'] ?? json['content']),
      createdAt: _date(json['created_at'] ?? json['sent_at']) ?? DateTime.now(),
      isMine:
          json['is_mine'] == true ||
          json['mine'] == true ||
          json['direction']?.toString() == 'outgoing',
      senderId: _nullableString(json['sender_id'] ?? sender?['id']),
      senderName: _nullableString(
        json['sender_name'] ?? sender?['name'] ?? sender?['full_name'],
      ),
      status: _nullableString(json['status']),
    );
  }

  ChatMessageEntity toEntity() => ChatMessageEntity(
    id: id,
    threadId: threadId,
    body: body,
    createdAt: createdAt,
    isMine: isMine,
    senderId: senderId,
    senderName: senderName,
    status: status,
  );

  static String _string(dynamic value) => value?.toString() ?? '';

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
