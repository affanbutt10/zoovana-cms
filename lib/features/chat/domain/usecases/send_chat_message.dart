import '../../../../core/error/result.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class SendChatMessage {
  SendChatMessage({required ChatRepository repository})
    : _repository = repository;

  final ChatRepository _repository;

  Future<Result<ChatMessageEntity>> call({
    required String threadId,
    required String body,
  }) {
    return _repository.sendMessage(threadId: threadId, body: body);
  }
}
