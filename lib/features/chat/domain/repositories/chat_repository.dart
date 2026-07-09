import '../../../../core/error/result.dart';
import '../entities/chat_message_entity.dart';
import '../entities/chat_thread_entity.dart';

abstract class ChatRepository {
  Future<Result<List<ChatThreadEntity>>> getThreads();

  Future<Result<List<ChatMessageEntity>>> getMessages(String threadId);

  Future<Result<ChatMessageEntity>> sendMessage({
    required String threadId,
    required String body,
  });

  Future<Result<void>> markThreadRead(String threadId);
}
