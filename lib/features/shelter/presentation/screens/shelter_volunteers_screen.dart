import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../domain/entities/shelter_volunteer_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterVolunteersScreen extends StatefulWidget {
  const ShelterVolunteersScreen({super.key});

  @override
  State<ShelterVolunteersScreen> createState() =>
      _ShelterVolunteersScreenState();
}

class _ShelterVolunteersScreenState extends State<ShelterVolunteersScreen> {
  final ShelterController controller = Get.find<ShelterController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadVolunteers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ZoovanaAppBar(
        title: 'Volunteer Applications',
        showBack: true,
      ),
      body: Obx(() {
        if (controller.volunteersStatus.value == ShelterStatus.loading) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) =>
                const SkeletonCard(width: double.infinity, height: 142),
          );
        }

        if (controller.volunteersStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            icon: Icons.error_outline,
            title: 'Unable to load volunteers',
            message: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: controller.loadVolunteers,
          );
        }

        if (controller.shelterVolunteers.isEmpty) {
          return RoleStatePanel(
            icon: Icons.volunteer_activism_outlined,
            title: 'No volunteer applications',
            message: 'New shelter volunteer requests will appear here.',
            actionLabel: 'Refresh',
            onAction: controller.loadVolunteers,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadVolunteers,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final volunteer = controller.shelterVolunteers[index];
              return _VolunteerCard(
                volunteer: volunteer,
                onApprove: () async {
                  if (!await requireAccount(
                    context,
                    action: 'approve a volunteer',
                  )) {
                    return;
                  }
                  controller.updateVolunteerStatus(volunteer, 'approved');
                },
                onReject: () async {
                  if (!await requireAccount(
                    context,
                    action: 'reject a volunteer',
                  )) {
                    return;
                  }
                  controller.updateVolunteerStatus(volunteer, 'rejected');
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: controller.shelterVolunteers.length,
          ),
        );
      }),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  const _VolunteerCard({
    required this.volunteer,
    required this.onApprove,
    required this.onReject,
  });

  final ShelterVolunteerEntity volunteer;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isPending = volunteer.status.toLowerCase() == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        volunteer.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (volunteer.shelterName?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          volunteer.shelterName!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusChip(status: volunteer.status),
              ],
            ),
            if (volunteer.skills?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Text(
                volunteer.skills!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };

    return Chip(
      label: Text(status),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}
