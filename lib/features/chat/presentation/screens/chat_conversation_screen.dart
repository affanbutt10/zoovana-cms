import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../controllers/chat_controller.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({super.key});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  late final ChatController _controller;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Worker _messagesWorker;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ChatController>();
    _messagesWorker = ever(_controller.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesWorker.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    if (!await requireAccount(context, action: 'send a message')) return;
    final text = _messageController.text;
    final sent = await _controller.sendMessage(text);
    if (sent) {
      _messageController.clear();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final thread = _controller.selectedThread.value;
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primaryGlow,
                child: Text(
                  _initial(thread?.participantName),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread?.participantName ?? 'Conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (thread?.contextLabel != null)
                      Text(
                        thread!.contextLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: thread == null
            ? const RoleStatePanel(
                title: 'No conversation selected',
                message: 'Choose a conversation from Messages to continue.',
                icon: Icons.chat_bubble_outline_rounded,
              )
            : Column(
                children: [
                  Expanded(child: _MessagesList(controller: _scrollController)),
                  Obx(() {
                    final error = _controller.sendError.value;
                    if (error.isEmpty ||
                        _controller.sendStatus.value != ChatSendStatus.error) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      width: double.infinity,
                      color: AppColors.errorLight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        error,
                        style: AppTextStyles.errorText,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                  _Composer(controller: _messageController, onSend: _send),
                ],
              ),
      );
    });
  }

  String _initial(String? name) {
    final value = name?.trim() ?? '';
    if (value.isEmpty) return '?';
    return value.characters.first.toUpperCase();
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatController>();
    return Obx(() {
      switch (chat.messagesStatus.value) {
        case ChatStatus.idle:
        case ChatStatus.loading:
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) => Align(
              alignment: index.isEven
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: SkeletonCard(width: index.isEven ? 210 : 170, height: 54),
            ),
          );
        case ChatStatus.error:
          return RoleStatePanel(
            title: 'Messages are unavailable',
            message: chat.messagesError.value.isEmpty
                ? 'Unable to load this conversation.'
                : chat.messagesError.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: () {
              final id = chat.selectedThread.value?.id;
              if (id != null) chat.loadMessages(id);
            },
          );
        case ChatStatus.success:
          if (chat.messages.isEmpty) {
            return const RoleStatePanel(
              title: 'Start the conversation',
              message:
                  'Send a message about the booking or care service when you are ready.',
              icon: Icons.chat_outlined,
            );
          }
          return ListView.builder(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            itemCount: chat.messages.length,
            itemBuilder: (context, index) {
              final message = chat.messages[index];
              final showDate =
                  index == 0 ||
                  !_sameDay(
                    chat.messages[index - 1].createdAt,
                    message.createdAt,
                  );
              return Column(
                children: [
                  if (showDate) _DateDivider(date: message.createdAt),
                  _MessageBubble(message: message),
                ],
              );
            },
          );
      }
    });
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final value = DateTime(date.year, date.month, date.day);
    final label = value == today
        ? 'Today'
        : value == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : '${date.day}/${date.month}/${date.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(label, style: AppTextStyles.labelSmall),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isMine
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final color = message.isMine ? AppColors.primary : AppColors.surfaceVariant;
    final textColor = message.isMine
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body,
              style: AppTextStyles.bodyMedium.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              _time(message.createdAt),
              style: AppTextStyles.labelSmall.copyWith(
                color: textColor.withValues(alpha: 0.68),
                fontSize: 9,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _time(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatController>();
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                return Obx(() {
                  final sending =
                      chat.sendStatus.value == ChatSendStatus.sending;
                  final canSend = value.text.trim().isNotEmpty && !sending;
                  return IconButton.filled(
                    onPressed: canSend ? onSend : null,
                    icon: sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    tooltip: 'Send',
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
