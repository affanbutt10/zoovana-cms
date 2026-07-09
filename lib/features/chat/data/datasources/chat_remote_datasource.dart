import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatThreadModel>> getThreads();

  Future<List<ChatMessageModel>> getMessages(String threadId);

  Future<ChatMessageModel> sendMessage({
    required String threadId,
    required String body,
  });

  Future<void> markThreadRead(String threadId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required Dio cmsDio}) : _dio = cmsDio;

  final Dio _dio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<List<ChatThreadModel>> getThreads() async {
    try {
      debugPrint('[CHAT] GET /api/v1/chats');
      final response = await _dio.get<dynamic>('/api/v1/chats');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ChatThreadModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String threadId) async {
    try {
      debugPrint('[CHAT] GET /api/v1/chats/$threadId/messages');
      final response = await _dio.get<dynamic>(
        '/api/v1/chats/$threadId/messages',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(
            (json) => ChatMessageModel.fromJson({
              ...json,
              'thread_id': json['thread_id'] ?? threadId,
            }),
          )
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String threadId,
    required String body,
  }) async {
    try {
      debugPrint('[CHAT] POST /api/v1/chats/$threadId/messages');
      final response = await _dio.post<dynamic>(
        '/api/v1/chats/$threadId/messages',
        data: {'message': body, 'body': body},
      );
      final data = _extractObject(response.data);
      return ChatMessageModel.fromJson({
        ...data,
        'thread_id': data['thread_id'] ?? threadId,
        'body': data['body'] ?? data['message'] ?? body,
        'is_mine': data['is_mine'] ?? true,
      });
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> markThreadRead(String threadId) async {
    try {
      debugPrint('[CHAT] PATCH /api/v1/chats/$threadId/read');
      await _dio.patch<dynamic>('/api/v1/chats/$threadId/read');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) return nested;
      if (nested is Map<String, dynamic>) {
        for (final key in const [
          'items',
          'results',
          'threads',
          'chats',
          'messages',
        ]) {
          final value = nested[key];
          if (value is List) return value;
        }
      }
      for (final key in const [
        'items',
        'results',
        'threads',
        'chats',
        'messages',
      ]) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return const {};
  }
}
