import '../../../../core/error/result.dart';
import '../entities/chat_thread_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatThreads {
  GetChatThreads({required ChatRepository repository})
    : _repository = repository;

  final ChatRepository _repository;

  Future<Result<List<ChatThreadEntity>>> call() => _repository.getThreads();
}
