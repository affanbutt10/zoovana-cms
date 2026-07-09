import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_thread_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ChatThreadEntity>>> getThreads() async {
    try {
      final threads = await _remoteDataSource.getThreads();
      return Success(threads.map((thread) => thread.toEntity()).toList());
    } on AppError catch (e) {
      debugPrint('[CHAT_REPO][ERROR] ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[CHAT_REPO][ERROR] Unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ChatMessageEntity>>> getMessages(String threadId) async {
    try {
      final messages = await _remoteDataSource.getMessages(threadId);
      return Success(messages.map((message) => message.toEntity()).toList());
    } on AppError catch (e) {
      debugPrint('[CHAT_REPO][ERROR] Messages: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[CHAT_REPO][ERROR] Messages unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ChatMessageEntity>> sendMessage({
    required String threadId,
    required String body,
  }) async {
    try {
      final message = await _remoteDataSource.sendMessage(
        threadId: threadId,
        body: body,
      );
      return Success(message.toEntity());
    } on AppError catch (e) {
      debugPrint('[CHAT_REPO][ERROR] Send: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[CHAT_REPO][ERROR] Send unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> markThreadRead(String threadId) async {
    try {
      await _remoteDataSource.markThreadRead(threadId);
      return const Success(null);
    } on AppError catch (e) {
      debugPrint('[CHAT_REPO][ERROR] Mark read: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[CHAT_REPO][ERROR] Mark read unexpected: $e');
      return Failure(AppError.serverError());
    }
  }
}
