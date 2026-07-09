import '../../../../core/error/result.dart';
import '../repositories/chat_repository.dart';

class MarkChatThreadRead {
  MarkChatThreadRead({required ChatRepository repository})
    : _repository = repository;

  final ChatRepository _repository;

  Future<Result<void>> call(String threadId) {
    return _repository.markThreadRead(threadId);
  }
}
