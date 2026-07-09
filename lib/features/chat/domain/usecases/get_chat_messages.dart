import '../../../../core/error/result.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatMessages {
  GetChatMessages({required ChatRepository repository})
    : _repository = repository;

  final ChatRepository _repository;

  Future<Result<List<ChatMessageEntity>>> call(String threadId) {
    return _repository.getMessages(threadId);
  }
}
