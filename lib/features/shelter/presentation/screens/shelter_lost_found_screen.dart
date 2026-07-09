import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/skeleton_card.dart';
import '../../../../shared/widgets/zoovana_app_bar.dart';
import '../../domain/entities/shelter_lost_found_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterLostFoundScreen extends StatefulWidget {
  const ShelterLostFoundScreen({super.key});

  @override
  State<ShelterLostFoundScreen> createState() => _ShelterLostFoundScreenState();
}

class _ShelterLostFoundScreenState extends State<ShelterLostFoundScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    _controller.loadLostFoundReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ZoovanaAppBar(title: 'Lost & Found', showBack: true),
      body: Obx(() {
        if (_controller.lostFoundStatus.value == ShelterStatus.loading) {
          return _skeletonList();
        }
        if (_controller.lostFoundStatus.value == ShelterStatus.error) {
          return RoleStatePanel(
            title: 'Reports are unavailable',
            message: _controller.errorMessage.value,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: _controller.loadLostFoundReports,
          );
        }
        if (_controller.lostFoundReports.isEmpty) {
          return const RoleStatePanel(
            title: 'No open reports',
            message:
                'Lost and found reports will appear here for matching and resolution.',
            icon: Icons.manage_search_rounded,
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadLostFoundReports,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.lostFoundReports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _LostFoundCard(
              report: _controller.lostFoundReports[index],
              controller: _controller,
            ),
          ),
        );
      }),
    );
  }

  Widget _skeletonList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) =>
        const SkeletonCard(width: double.infinity, height: 152),
  );
}

class _LostFoundCard extends StatelessWidget {
  const _LostFoundCard({required this.report, required this.controller});

  final ShelterLostFoundEntity report;
  final ShelterController controller;

  @override
  Widget build(BuildContext context) {
    final normalized = report.status.toLowerCase();
    final canResolve = normalized != 'resolved' && normalized != 'closed';

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
              Icon(_typeIcon(report.type), color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      [
                        if (report.animalName?.isNotEmpty ?? false)
                          report.animalName!,
                        report.type,
                      ].join(' • '),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: report.status),
            ],
          ),
          if (report.location?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            _MetaRow(icon: Icons.place_outlined, text: report.location!),
          ],
          if (report.reporterName?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            _MetaRow(icon: Icons.person_outline, text: report.reporterName!),
          ],
          if (canResolve) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (!await requireAccount(
                        context,
                        action: 'close a report',
                      )) {
                        return;
                      }
                      controller.updateLostFoundStatus(report, 'closed');
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (!await requireAccount(
                        context,
                        action: 'resolve a report',
                      )) {
                        return;
                      }
                      controller.updateLostFoundStatus(report, 'resolved');
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    return type.toLowerCase() == 'found'
        ? Icons.pets_rounded
        : Icons.search_rounded;
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
      'resolved' => AppColors.success,
      'closed' => AppColors.slate,
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
