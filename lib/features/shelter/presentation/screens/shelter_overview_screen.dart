import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/role_dashboard_drawer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/shelter_operation_entity.dart';
import '../../domain/entities/shelter_stat_entity.dart';
import '../controllers/shelter_controller.dart';

class ShelterOverviewScreen extends StatefulWidget {
  const ShelterOverviewScreen({super.key});

  @override
  State<ShelterOverviewScreen> createState() => _ShelterOverviewScreenState();
}

class _ShelterOverviewScreenState extends State<ShelterOverviewScreen> {
  late final ShelterController _controller;

  static const _careModules = [
    _ShelterModule(
      label: 'Animals',
      subtitle: 'Profiles, intake and availability',
      icon: Icons.pets_rounded,
      color: AppColors.primary,
      route: AppRoutes.shelterAnimals,
    ),
    _ShelterModule(
      label: 'Medical',
      subtitle: 'Treatment records and health',
      icon: Icons.medical_services_rounded,
      color: AppColors.error,
      route: AppRoutes.shelterMedical,
    ),
    _ShelterModule(
      label: 'Vaccinations',
      subtitle: 'Due dates and immunization history',
      icon: Icons.vaccines_rounded,
      color: AppColors.accentDark,
      route: AppRoutes.shelterVaccinations,
    ),
    _ShelterModule(
      label: 'Kennels',
      subtitle: 'Capacity, assignments and cleaning',
      icon: Icons.grid_view_rounded,
      color: AppColors.warningDark,
      route: AppRoutes.shelterKennels,
    ),
    _ShelterModule(
      label: 'Animal Care',
      subtitle: 'Daily tasks and care completion',
      icon: Icons.checklist_rounded,
      color: AppColors.success,
      route: AppRoutes.shelterAnimalCare,
    ),
  ];

  static const _communityModules = [
    _ShelterModule(
      label: 'Shelter Profiles',
      subtitle: 'Locations and service settings',
      icon: Icons.home_work_rounded,
      color: AppColors.secondaryLight,
      route: AppRoutes.shelterList,
    ),
    _ShelterModule(
      label: 'Adoptions',
      subtitle: 'Applications and placements',
      icon: Icons.favorite_rounded,
      color: AppColors.coral,
      route: AppRoutes.shelterAdoptions,
    ),
    _ShelterModule(
      label: 'Volunteers',
      subtitle: 'Applications, shifts and activity',
      icon: Icons.volunteer_activism_rounded,
      color: AppColors.primary,
      route: AppRoutes.shelterVolunteers,
    ),
    _ShelterModule(
      label: 'Donations',
      subtitle: 'Contributions and receipts',
      icon: Icons.payments_rounded,
      color: AppColors.successDark,
      route: AppRoutes.shelterDonations,
    ),
    _ShelterModule(
      label: 'Lost & Found',
      subtitle: 'Reports, matches and reunions',
      icon: Icons.travel_explore_rounded,
      color: AppColors.warningDark,
      route: AppRoutes.shelterLostFound,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ShelterController>();
    if (_controller.overviewStatus.value == ShelterStatus.idle) {
      _controller.loadOverview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleDashboardDrawer(),
      onDrawerChanged: RoleDashboardDrawerController.setOpen,
      body: RefreshIndicator(
        onRefresh: _controller.loadOverview,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: buildFrostedAppBarBackground(),
              surfaceTintColor: Colors.transparent,
              shadowColor: AppColors.divider,
              elevation: 0,
              scrolledUnderElevation: 1,
              leading: Builder(
                builder: (context) => Center(
                  child: IosIconButton(
                    tooltip: 'Open menu',
                    icon: CupertinoIcons.line_horizontal_3,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              titleSpacing: 16,
              title: Row(
                children: [
                  const AppLogoTile(size: 32, radius: 8, showShadow: false),
                  const SizedBox(width: 10),
                  Text(
                    'Shelter Operations',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.successDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IosIconButton(
                    tooltip: 'Shelter settings',
                    icon: CupertinoIcons.slider_horizontal_3,
                    onTap: () => context.push(AppRoutes.shelterSettings),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                final status = _controller.overviewStatus.value;
                if (status == ShelterStatus.loading) {
                  return const RoleDashboardSkeleton();
                }
                if (status == ShelterStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
                    child: RoleStatePanel(
                      title: 'Shelter operations are unavailable',
                      message: _controller.errorMessage.value.isEmpty
                          ? 'We could not refresh current shelter activity.'
                          : _controller.errorMessage.value,
                      icon: Icons.cloud_off_outlined,
                      actionLabel: 'Try again',
                      onAction: _controller.loadOverview,
                    ),
                  );
                }

                final overview = _controller.overview.value;
                final stats = overview?.stats ?? const <ShelterStatEntity>[];
                final activity =
                    overview?.recentActivity ??
                    const <ShelterOperationEntity>[];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoleDashboardHeader(
                        eyebrow: 'Shelter command center',
                        title: 'Care that stays on schedule',
                        subtitle: _priorityMessage(stats),
                        icon: Icons.home_rounded,
                        accent: AppColors.accentLight,
                        stats: stats
                            .take(3)
                            .map(
                              (stat) => RoleHeroStat(
                                label: stat.label,
                                value: stat.value,
                                detail: stat.trend,
                                icon: CupertinoIcons.heart_circle,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      _StatsGrid(stats: stats),
                      const SizedBox(height: 24),
                      const SectionHeader(
                        title: 'Animal care',
                        subtitle: 'Health, housing and daily operations',
                      ),
                      const SizedBox(height: 12),
                      _ModuleGroup(modules: _careModules),
                      const SizedBox(height: 24),
                      const SectionHeader(
                        title: 'Community operations',
                        subtitle: 'Adoptions, supporters and public services',
                      ),
                      const SizedBox(height: 12),
                      _ModuleGroup(modules: _communityModules),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Recent animal activity',
                        subtitle: activity.isEmpty
                            ? 'New intake and updates will appear here'
                            : 'Latest records across your shelter',
                        actionLabel: activity.isEmpty ? null : 'View animals',
                        onAction: activity.isEmpty
                            ? null
                            : () => context.push(AppRoutes.shelterAnimals),
                      ),
                      const SizedBox(height: 12),
                      if (activity.isEmpty)
                        RoleStatePanel(
                          title: 'No recent activity',
                          message:
                              'Animal intake and profile updates will be summarized here.',
                          icon: Icons.history_rounded,
                          actionLabel: 'Manage animals',
                          onAction: () =>
                              context.push(AppRoutes.shelterAnimals),
                        )
                      else
                        _ActivityGroup(items: activity),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _priorityMessage(List<ShelterStatEntity> stats) {
    final treatments = _statValue(stats, 'Treatments');
    final vaccinations = _statValue(stats, 'Vaccinations');
    if (treatments > 0 || vaccinations > 0) {
      return '$treatments treatment ${treatments == 1 ? 'case needs' : 'cases need'} attention and $vaccinations ${vaccinations == 1 ? 'vaccination is' : 'vaccinations are'} due.';
    }
    return 'Today’s care, housing, and community work are together in one clear view.';
  }

  int _statValue(List<ShelterStatEntity> stats, String label) {
    for (final stat in stats) {
      if (stat.label.toLowerCase().contains(label.toLowerCase())) {
        return int.tryParse(stat.value) ?? 0;
      }
    }
    return 0;
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<ShelterStatEntity> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const RoleStatePanel(
        title: 'Metrics are not available yet',
        message: 'Shelter totals will appear after the first records sync.',
        icon: Icons.query_stats_rounded,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        final presentation = _presentationFor(stat.label);
        return RoleMetricTile(
          label: stat.label,
          value: stat.value,
          trend: stat.trend,
          icon: presentation.$1,
          color: presentation.$2,
          onTap: () => context.push(presentation.$3),
        );
      },
    );
  }

  (IconData, Color, String) _presentationFor(String label) {
    final key = label.toLowerCase();
    if (key.contains('available')) {
      return (
        Icons.favorite_outline_rounded,
        AppColors.success,
        AppRoutes.shelterAnimals,
      );
    }
    if (key.contains('treatment')) {
      return (
        Icons.medical_services_outlined,
        AppColors.error,
        AppRoutes.shelterMedical,
      );
    }
    if (key.contains('vaccination')) {
      return (
        Icons.vaccines_outlined,
        AppColors.warning,
        AppRoutes.shelterVaccinations,
      );
    }
    return (Icons.pets_rounded, AppColors.primary, AppRoutes.shelterAnimals);
  }
}

class _ModuleGroup extends StatelessWidget {
  const _ModuleGroup({required this.modules});

  final List<_ShelterModule> modules;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        border: Border.all(color: AppColors.divider.withValues(alpha: .82)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < modules.length; index++) ...[
            _ModuleRow(module: modules[index]),
            if (index < modules.length - 1)
              Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({required this.module});

  final _ShelterModule module;

  @override
  Widget build(BuildContext context) {
    return IosPressable(
      onTap: () => context.push(module.route),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: module.color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(module.icon, color: module.color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.label,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    module.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ActivityGroup extends StatelessWidget {
  const _ActivityGroup({required this.items});

  final List<ShelterOperationEntity> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        border: Border.all(color: AppColors.divider.withValues(alpha: .82)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _ActivityRow(item: items[index]),
            if (index < items.length - 1)
              Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ShelterOperationEntity item;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    return IosPressable(
      onTap: () => context.push(AppRoutes.shelterAnimals),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(CupertinoIcons.heart, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.status,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final key = status.toLowerCase();
    if (key.contains('available') ||
        key.contains('active') ||
        key.contains('healthy')) {
      return AppColors.successDark;
    }
    if (key.contains('medical') ||
        key.contains('urgent') ||
        key.contains('treatment')) {
      return AppColors.error;
    }
    if (key.contains('pending') || key.contains('hold')) {
      return AppColors.warningDark;
    }
    return AppColors.primary;
  }
}

class _ShelterModule {
  const _ShelterModule({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}
