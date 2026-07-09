import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_thread_entity.dart';
import '../../domain/usecases/get_chat_messages.dart';
import '../../domain/usecases/get_chat_threads.dart';
import '../../domain/usecases/mark_chat_thread_read.dart';
import '../../domain/usecases/send_chat_message.dart';

enum ChatStatus { idle, loading, success, error }

enum ChatSendStatus { idle, sending, success, error }

class ChatController extends GetxController {
  ChatController({
    required GetChatThreads getChatThreads,
    required GetChatMessages getChatMessages,
    required SendChatMessage sendChatMessage,
    required MarkChatThreadRead markChatThreadRead,
  }) : _getChatThreads = getChatThreads,
       _getChatMessages = getChatMessages,
       _sendChatMessage = sendChatMessage,
       _markChatThreadRead = markChatThreadRead;

  final GetChatThreads _getChatThreads;
  final GetChatMessages _getChatMessages;
  final SendChatMessage _sendChatMessage;
  final MarkChatThreadRead _markChatThreadRead;

  final Rx<ChatStatus> threadsStatus = ChatStatus.idle.obs;
  final Rx<ChatStatus> messagesStatus = ChatStatus.idle.obs;
  final Rx<ChatSendStatus> sendStatus = ChatSendStatus.idle.obs;

  final RxList<ChatThreadEntity> threads = <ChatThreadEntity>[].obs;
  final RxList<ChatMessageEntity> messages = <ChatMessageEntity>[].obs;
  final Rxn<ChatThreadEntity> selectedThread = Rxn<ChatThreadEntity>();

  final RxString threadsError = ''.obs;
  final RxString messagesError = ''.obs;
  final RxString sendError = ''.obs;

  int get totalUnread {
    return threads.fold<int>(0, (sum, thread) => sum + thread.unreadCount);
  }

  Future<void> loadThreads() async {
    threadsStatus.value = ChatStatus.loading;
    threadsError.value = '';
    debugPrint('[CHAT_CTRL] Loading threads');

    final result = await _getChatThreads();
    switch (result) {
      case Success(:final data):
        threads.assignAll(data);
        threadsStatus.value = ChatStatus.success;
      case Failure(:final error):
        threadsError.value = error.message;
        threadsStatus.value = ChatStatus.error;
    }
  }

  Future<void> refreshThreads() => loadThreads();

  Future<void> openThread(ChatThreadEntity thread) async {
    selectedThread.value = thread;
    messages.clear();
    await loadMessages(thread.id);
    if (thread.unreadCount > 0) {
      await _markChatThreadRead(thread.id);
      final index = threads.indexWhere((item) => item.id == thread.id);
      if (index >= 0) {
        threads[index] = ChatThreadEntity(
          id: thread.id,
          participantName: thread.participantName,
          participantAvatarUrl: thread.participantAvatarUrl,
          lastMessage: thread.lastMessage,
          lastMessageAt: thread.lastMessageAt,
          contextLabel: thread.contextLabel,
        );
      }
    }
  }

  Future<void> loadMessages(String threadId) async {
    messagesStatus.value = ChatStatus.loading;
    messagesError.value = '';
    debugPrint('[CHAT_CTRL] Loading messages for thread: $threadId');

    final result = await _getChatMessages(threadId);
    switch (result) {
      case Success(:final data):
        final sorted = [...data]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        messages.assignAll(sorted);
        messagesStatus.value = ChatStatus.success;
      case Failure(:final error):
        messagesError.value = error.message;
        messagesStatus.value = ChatStatus.error;
    }
  }

  Future<bool> sendMessage(String body) async {
    final thread = selectedThread.value;
    final text = body.trim();
    if (thread == null || text.isEmpty) return false;

    sendStatus.value = ChatSendStatus.sending;
    sendError.value = '';

    final result = await _sendChatMessage(threadId: thread.id, body: text);
    switch (result) {
      case Success(:final data):
        messages.add(data);
        _bumpThread(thread, text, data.createdAt);
        sendStatus.value = ChatSendStatus.success;
        return true;
      case Failure(:final error):
        sendError.value = error.message;
        sendStatus.value = ChatSendStatus.error;
        return false;
    }
  }

  void _bumpThread(ChatThreadEntity thread, String body, DateTime at) {
    final updated = ChatThreadEntity(
      id: thread.id,
      participantName: thread.participantName,
      participantAvatarUrl: thread.participantAvatarUrl,
      lastMessage: body,
      lastMessageAt: at,
      unreadCount: 0,
      contextLabel: thread.contextLabel,
    );

    selectedThread.value = updated;
    threads.removeWhere((item) => item.id == thread.id);
    threads.insert(0, updated);
  }
}
