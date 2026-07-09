import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../domain/entities/chat_thread_entity.dart';
import '../controllers/chat_controller.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  late final ChatController _controller;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ChatController>();
    if (_controller.threadsStatus.value == ChatStatus.idle) {
      _controller.loadThreads();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Messages', showBack: true),
      body: Obx(() {
        switch (_controller.threadsStatus.value) {
          case ChatStatus.idle:
          case ChatStatus.loading:
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, _) =>
                  const SkeletonCard(width: double.infinity, height: 82),
            );
          case ChatStatus.error:
            return _ErrorState(
              message: _controller.threadsError.value,
              onRetry: _controller.loadThreads,
            );
          case ChatStatus.success:
            if (_controller.threads.isEmpty) {
              return const RoleStatePanel(
                title: 'No conversations yet',
                message:
                    'Messages with care providers and pet owners will appear here.',
                icon: Icons.forum_outlined,
              );
            }
            final query = _query.trim().toLowerCase();
            final threads = query.isEmpty
                ? _controller.threads.toList()
                : _controller.threads.where((thread) {
                    return thread.participantName.toLowerCase().contains(
                          query,
                        ) ||
                        (thread.lastMessage?.toLowerCase().contains(query) ??
                            false) ||
                        (thread.contextLabel?.toLowerCase().contains(query) ??
                            false);
                  }).toList();
            return RefreshIndicator(
              onRefresh: _controller.refreshThreads,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _InboxSummary(unread: _controller.totalUnread),
                  const SizedBox(height: 14),
                  SearchBar(
                    controller: _searchController,
                    hintText: 'Search conversations',
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      if (_query.isNotEmpty)
                        IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                    ],
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 14),
                  if (threads.isEmpty)
                    const RoleStatePanel(
                      title: 'No conversations found',
                      message: 'Try a different name or message.',
                      icon: Icons.search_off_rounded,
                    )
                  else
                    for (var index = 0; index < threads.length; index++) ...[
                      _ThreadTile(
                        thread: threads[index],
                        onTap: () {
                          unawaited(_controller.openThread(threads[index]));
                          context.push(AppRoutes.chatConversation);
                        },
                      ),
                      if (index < threads.length - 1)
                        const SizedBox(height: 10),
                    ],
                ],
              ),
            );
        }
      }),
    );
  }
}

class _InboxSummary extends StatelessWidget {
  const _InboxSummary({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unread == 0 ? 'You are all caught up' : '$unread unread',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                unread == 0
                    ? 'New care conversations will appear here.'
                    : 'Open conversations that need your attention.',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (unread == 0 ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            unread == 0
                ? Icons.mark_chat_read_outlined
                : Icons.mark_chat_unread_outlined,
            color: unread == 0 ? AppColors.successDark : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.onTap});

  final ChatThreadEntity thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryGlow,
                foregroundImage: thread.participantAvatarUrl == null
                    ? null
                    : NetworkImage(thread.participantAvatarUrl!),
                child: Text(
                  _initial(thread.participantName),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.participantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (thread.lastMessageAt != null)
                          Text(
                            _shortDate(thread.lastMessageAt!),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread.lastMessage ??
                          thread.contextLabel ??
                          'Open conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: thread.hasUnread
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: thread.hasUnread
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (thread.hasUnread) ...[
                const SizedBox(width: 10),
                Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    thread.unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _shortDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${date.month}/${date.day}';
  }

  String _initial(String name) {
    if (name.trim().isEmpty) return '?';
    return name.trim().characters.first.toUpperCase();
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RoleStatePanel(
      title: 'Messages are unavailable',
      message: message.isEmpty ? 'Unable to load conversations.' : message,
      icon: Icons.cloud_off_outlined,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}
