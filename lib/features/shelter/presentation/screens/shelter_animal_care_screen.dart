import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../domain/entities/shelter_animal_care_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterAnimalCareScreen extends StatefulWidget {
  const ShelterAnimalCareScreen({super.key});

  @override
  State<ShelterAnimalCareScreen> createState() =>
      _ShelterAnimalCareScreenState();
}

class _ShelterAnimalCareScreenState extends State<ShelterAnimalCareScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadAnimalCareTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Animal Care', showBack: true),
      body: Obx(() {
        if (_controller.animalCareStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.animalCareStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Care tasks are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadAnimalCareTasks,
          );
        }
        if (_controller.animalCareTasks.isEmpty) {
          return const RoleStatePanel(
            title: 'All care tasks are clear',
            message:
                'Scheduled feeding, cleaning, medication, and care work will appear here.',
            icon: Icons.checklist_rounded,
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadAnimalCareTasks,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.animalCareTasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _AnimalCareCard(
              task: _controller.animalCareTasks[index],
              controller: _controller,
            ),
          ),
        );
      }),
    );
  }

  Widget _skeletonList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) =>
        const SkeletonCard(width: double.infinity, height: 152),
  );
}

class _AnimalCareCard extends StatelessWidget {
  const _AnimalCareCard({required this.task, required this.controller});

  final ShelterAnimalCareEntity task;
  final ShelterController controller;

  @override
  Widget build(BuildContext context) {
    final normalized = task.status.toLowerCase();
    final canStart = normalized == 'pending' || normalized == 'scheduled';
    final canComplete = normalized != 'completed' && normalized != 'cancelled';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.checklist_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskType,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      task.animalName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: task.status),
            ],
          ),
          if (task.assignedTo?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            _MetaRow(icon: Icons.person_outline, text: task.assignedTo!),
          ],
          if (task.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            _MetaRow(icon: Icons.notes_outlined, text: task.notes!),
          ],
          if (canStart || canComplete) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (canStart) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (!await requireAccount(
                          context,
                          action: 'start a care task',
                        )) {
                          return;
                        }
                        controller.updateAnimalCareStatus(task, 'in_progress');
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canComplete
                        ? () async {
                            if (!await requireAccount(
                              context,
                              action: 'complete a care task',
                            )) {
                              return;
                            }
                            controller.updateAnimalCareStatus(
                              task,
                              'completed',
                            );
                          }
                        : null,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Complete'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'completed' => AppColors.success,
      'in_progress' => AppColors.primary,
      'cancelled' => AppColors.error,
      _ => AppColors.warning,
    };

    return Chip(
      label: Text(status),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
  }
}
