import '../../domain/entities/chat_thread_entity.dart';

class ChatThreadModel {
  const ChatThreadModel({
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

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final participant = _firstMap([
      json['participant'],
      json['other_user'],
      json['provider'],
      json['pet_owner'],
      json['user'],
    ]);

    final last = _firstMap([json['last_message'], json['latest_message']]);
    final name = _string(
      participant?['name'] ??
          participant?['full_name'] ??
          participant?['display_name'] ??
          json['participant_name'] ??
          json['name'],
    );

    return ChatThreadModel(
      id: _string(json['id'] ?? json['thread_id'] ?? json['chat_id']),
      participantName: name.isEmpty ? 'Conversation' : name,
      participantAvatarUrl: _nullableString(
        participant?['avatar_url'] ??
            participant?['avatar'] ??
            json['participant_avatar_url'],
      ),
      lastMessage: _nullableString(
        last?['body'] ??
            last?['message'] ??
            last?['content'] ??
            json['last_message_text'] ??
            json['last_message'],
      ),
      lastMessageAt: _date(
        last?['created_at'] ??
            last?['sent_at'] ??
            json['last_message_at'] ??
            json['updated_at'],
      ),
      unreadCount: _int(json['unread_count'] ?? json['unread']),
      contextLabel: _nullableString(
        json['booking_number'] ??
            json['booking_id'] ??
            json['service_name'] ??
            json['context_label'],
      ),
    );
  }

  ChatThreadEntity toEntity() => ChatThreadEntity(
    id: id,
    participantName: participantName,
    participantAvatarUrl: participantAvatarUrl,
    lastMessage: lastMessage,
    lastMessageAt: lastMessageAt,
    unreadCount: unreadCount,
    contextLabel: contextLabel,
  );

  static Map<String, dynamic>? _firstMap(List<dynamic> values) {
    for (final value in values) {
      if (value is Map<String, dynamic>) return value;
    }
    return null;
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
