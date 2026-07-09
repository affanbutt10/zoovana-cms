import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../domain/entities/shelter_profile_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterSettingsScreen extends StatefulWidget {
  const ShelterSettingsScreen({super.key});

  @override
  State<ShelterSettingsScreen> createState() => _ShelterSettingsScreenState();
}

class _ShelterSettingsScreenState extends State<ShelterSettingsScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    if (_controller.shelters.isEmpty) _controller.loadShelters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Shelter Settings', style: AppTextStyles.titleLarge),
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadShelters,
        child: Obx(() {
          if (_controller.sheltersStatus.value == ShelterStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.sheltersStatus.value == ShelterStatus.error) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                AppEmptyState(
                  message: _controller.errorMessage.value,
                  icon: Icons.error_outline_rounded,
                ),
              ],
            );
          }

          if (_controller.shelters.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                AppEmptyState(
                  message:
                      'Create a shelter profile before configuring settings.',
                  icon: Icons.settings_outlined,
                ),
              ],
            );
          }

          final activeCount = _controller.shelters
              .where((shelter) => shelter.status.toLowerCase() == 'active')
              .length;
          final volunteerCount = _controller.shelters
              .where((shelter) => shelter.acceptingVolunteers)
              .length;
          final donationCount = _controller.shelters
              .where((shelter) => shelter.donationsEnabled)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryPanel(
                shelters: _controller.shelters.length,
                activeShelters: activeCount,
                volunteerShelters: volunteerCount,
                donationShelters: donationCount,
              ),
              const SizedBox(height: 16),
              Text('Shelter Profiles', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              ..._controller.shelters.map(
                (shelter) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ShelterSettingsCard(shelter: shelter),
                ),
              ),
              const SizedBox(height: 8),
              Text('Shortcuts', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              _ShortcutTile(
                icon: Icons.home_work_rounded,
                label: 'Manage shelter profiles',
                route: AppRoutes.shelterList,
              ),
              _ShortcutTile(
                icon: Icons.volunteer_activism_rounded,
                label: 'Review volunteers',
                route: AppRoutes.shelterVolunteers,
              ),
              _ShortcutTile(
                icon: Icons.payments_rounded,
                label: 'Review donations',
                route: AppRoutes.shelterDonations,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.shelters,
    required this.activeShelters,
    required this.volunteerShelters,
    required this.donationShelters,
  });

  final int shelters;
  final int activeShelters;
  final int volunteerShelters;
  final int donationShelters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.successDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shelter configuration',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(label: 'Shelters', value: shelters),
              ),
              Expanded(
                child: _Metric(label: 'Active', value: activeShelters),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(label: 'Volunteers', value: volunteerShelters),
              ),
              Expanded(
                child: _Metric(label: 'Donations', value: donationShelters),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _ShelterSettingsCard extends StatelessWidget {
  const _ShelterSettingsCard({required this.shelter});

  final ShelterProfileEntity shelter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  shelter.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Chip(label: Text(shelter.status)),
            ],
          ),
          if (shelter.location?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              shelter.location!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FlagChip(
                enabled: shelter.acceptingVolunteers,
                label: 'Volunteers',
                icon: Icons.volunteer_activism_rounded,
              ),
              _FlagChip(
                enabled: shelter.donationsEnabled,
                label: 'Donations',
                icon: Icons.payments_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.enabled,
    required this.label,
    required this.icon,
  });

  final bool enabled;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.success : AppColors.textSecondary;
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(enabled ? '$label on' : '$label off'),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.success),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(route),
      ),
    );
  }
}
