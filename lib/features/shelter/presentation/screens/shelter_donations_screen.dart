import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../domain/entities/shelter_donation_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterDonationsScreen extends StatefulWidget {
  const ShelterDonationsScreen({super.key});

  @override
  State<ShelterDonationsScreen> createState() => _ShelterDonationsScreenState();
}

class _ShelterDonationsScreenState extends State<ShelterDonationsScreen> {
  final ShelterController controller = Get.find<ShelterController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ZoovanaAppBar(title: 'Donations', showBack: true),
      body: Obx(() {
        if (controller.donationsStatus.value == ShelterStatus.loading) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, _) =>
                const SkeletonCard(width: double.infinity, height: 142),
          );
        }

        if (controller.donationsStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            icon: Icons.error_outline,
            title: 'Unable to load donations',
            message: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: controller.loadDonations,
          );
        }

        if (controller.donations.isEmpty) {
          return RoleStatePanel(
            icon: Icons.payments_outlined,
            title: 'No donations yet',
            message: 'Shelter donations will appear here for review.',
            actionLabel: 'Refresh',
            onAction: controller.loadDonations,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadDonations,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final donation = controller.donations[index];
              return _DonationCard(
                donation: donation,
                onConfirm: () async {
                  if (!await requireAccount(
                    context,
                    action: 'confirm a donation',
                  )) {
                    return;
                  }
                  controller.updateDonationStatus(donation, 'confirmed');
                },
                onReject: () async {
                  if (!await requireAccount(
                    context,
                    action: 'reject a donation',
                  )) {
                    return;
                  }
                  controller.updateDonationStatus(donation, 'rejected');
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: controller.donations.length,
          ),
        );
      }),
    );
  }
}

class _DonationCard extends StatelessWidget {
  const _DonationCard({
    required this.donation,
    required this.onConfirm,
    required this.onReject,
  });

  final ShelterDonationEntity donation;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isPending = donation.status.toLowerCase() == 'pending';
    final isConfirmed = donation.status.toLowerCase() == 'confirmed';

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
                        donation.donorName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        donation.amountLabel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      if (donation.shelterName?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          donation.shelterName!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusChip(status: donation.status),
              ],
            ),
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
                      onPressed: onConfirm,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ] else if (isConfirmed) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text('Receipt ready'),
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
      'confirmed' => AppColors.success,
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
