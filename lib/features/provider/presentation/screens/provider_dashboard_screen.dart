import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/auth/account_gate.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/role_dashboard_drawer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/models/provider_profile_model.dart';
import '../../domain/entities/provider_overview_entity.dart';
import '../controllers/provider_controller.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  late final ProviderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProviderController>();
    if (_controller.overviewStatus.value == ProviderStatus.idle) {
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
                  const AppLogoTile(size: 32, radius: 9, showShadow: false),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Service Provider',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Bookings & earnings',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IosIconButton(
                  tooltip: 'Messages',
                  onTap: () => context.push(AppRoutes.chatInbox),
                  icon: CupertinoIcons.chat_bubble_2,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'EN',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IosIconButton(
                  tooltip: 'Settings',
                  onTap: () => context.push(AppRoutes.providerSettings),
                  icon: CupertinoIcons.gear,
                ),
                const SizedBox(width: 12),
              ],
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                final status = _controller.overviewStatus.value;
                if (status == ProviderStatus.loading) {
                  return const RoleDashboardSkeleton();
                }
                if (status == ProviderStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
                    child: RoleStatePanel(
                      title: 'Your provider workspace is unavailable',
                      message: _controller.errorMessage.value.isEmpty
                          ? 'We could not refresh your services and bookings.'
                          : _controller.errorMessage.value,
                      icon: Icons.cloud_off_outlined,
                      actionLabel: 'Try again',
                      onAction: _controller.loadOverview,
                    ),
                  );
                }

                final profile = _controller.profile.value;
                if (profile == null) {
                  return _ApplyPanel(controller: _controller);
                }
                if (!profile.isApproved) {
                  return _StatusPanel(controller: _controller);
                }
                return _ApprovedDashboard(controller: _controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovedDashboard extends StatelessWidget {
  const _ApprovedDashboard({required this.controller});

  final ProviderController controller;

  @override
  Widget build(BuildContext context) {
    final overview = controller.overview.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoleDashboardHeader(
            eyebrow: 'Provider studio',
            title: overview?.pendingBookingCount == 0
                ? 'Your services are ready to sell'
                : '${overview?.pendingBookingCount ?? 0} booking ${overview?.pendingBookingCount == 1 ? 'request needs' : 'requests need'} attention',
            subtitle:
                'Keep revenue, response quality, active services, and client requests in one polished operating view.',
            icon: Icons.design_services_rounded,
            accent: AppColors.accentLight,
            stats: [
              RoleHeroStat(
                label: 'Revenue',
                value: overview?.monthlyRevenueLabel ?? 'SAR 0',
                icon: CupertinoIcons.money_dollar_circle,
              ),
              RoleHeroStat(
                label: 'Bookings',
                value: '${overview?.totalBookings ?? 0}',
                icon: CupertinoIcons.calendar,
                detail: '${overview?.pendingBookingCount ?? 0} pending',
              ),
              RoleHeroStat(
                label: 'Rating',
                value: (overview?.totalReviews ?? 0) == 0
                    ? 'N/A'
                    : (overview?.rating ?? 0).toStringAsFixed(1),
                icon: CupertinoIcons.star,
              ),
            ],
            primaryAction: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.providerServices),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Service'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _ProviderMetric(
                label: 'Monthly Revenue',
                value: overview?.monthlyRevenueLabel ?? 'SAR 0',
                detail: '+${overview?.monthlyRevenueChangePercent ?? 0}%',
                icon: Icons.payments_outlined,
              ),
              _ProviderMetric(
                label: 'Total Bookings',
                value: '${overview?.totalBookings ?? 0}',
                detail: '${overview?.pendingBookingCount ?? 0} pending',
                icon: Icons.calendar_month_rounded,
              ),
              _ProviderMetric(
                label: 'Profile Rating',
                value: (overview?.totalReviews ?? 0) == 0
                    ? 'N/A'
                    : (overview?.rating ?? 0).toStringAsFixed(1),
                detail: '${overview?.totalReviews ?? 0} reviews',
                icon: Icons.star_outline_rounded,
                color: AppColors.warning,
              ),
              _ProviderMetric(
                label: 'Response Rate',
                value: '${overview?.responseRate.toStringAsFixed(0) ?? '0'}%',
                detail: overview?.responseLabel ?? '',
                icon: Icons.trending_up_rounded,
              ),
              _ProviderMetric(
                label: 'Completed Jobs',
                value: '${overview?.completedJobs ?? 0}',
                detail: '+${overview?.completedThisWeek ?? 0} this week',
                icon: Icons.work_outline_rounded,
              ),
              _ProviderMetric(
                label: 'Active Services',
                value: '${overview?.activeServiceCount ?? 0}',
                detail: 'Manage listings',
                icon: Icons.design_services_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DashboardPanel(
            title: 'Earnings Trend',
            child: SizedBox(
              height: 150,
              child: _EarningsChart(
                points: overview?.earningsTrend ?? const [],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DashboardPanel(
            title: 'My Active Services',
            child: controller.services.isEmpty
                ? const _DashboardEmpty(
                    icon: Icons.design_services_outlined,
                    label: 'No active services yet',
                  )
                : Column(
                    children: controller.services
                        .take(3)
                        .map(
                          (service) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryGlow,
                              child: const Icon(Icons.pets_rounded),
                            ),
                            title: Text(
                              service.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              service.serviceTypes.isEmpty
                                  ? service.serviceType
                                  : service.serviceTypes.join(' · '),
                            ),
                            trailing: Text(service.priceLabel ?? ''),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProviderMetric extends StatelessWidget {
  const _ProviderMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.color = AppColors.primary,
  });
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.surfaceAtElevation(1),
      border: Border.all(color: AppColors.divider.withValues(alpha: .82)),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.07),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w900),
        ),
        Text(
          detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(color: color),
        ),
      ],
    ),
  );
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _DashboardEmpty extends StatelessWidget {
  const _DashboardEmpty({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    ),
  );
}

class _EarningsChart extends StatelessWidget {
  const _EarningsChart({required this.points});
  final List<ProviderEarningPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _DashboardEmpty(
        icon: Icons.show_chart_rounded,
        label: 'No earnings data yet',
      );
    }
    final maxAmount = points.fold<double>(
      0,
      (maximum, point) => point.amount > maximum ? point.amount : maximum,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((point) {
        final fraction = maxAmount == 0 ? .02 : point.amount / maxAmount;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                point.amount.toStringAsFixed(0),
                style: AppTextStyles.labelSmall,
              ),
              const SizedBox(height: 5),
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: fraction.clamp(.02, 1),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.accentLight, AppColors.primary],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(7),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(point.month, style: AppTextStyles.labelSmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ApplyPanel extends StatefulWidget {
  const _ApplyPanel({required this.controller});

  final ProviderController controller;

  @override
  State<_ApplyPanel> createState() => _ApplyPanelState();
}

class _ApplyPanelState extends State<_ApplyPanel> {
  final _businessName = TextEditingController();
  final _notes = TextEditingController();
  final _types = <String>{'boarding'};

  @override
  void dispose() {
    _businessName.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await requireAccount(context, action: 'apply as a provider')) return;
    if (_businessName.text.trim().isEmpty || _types.isEmpty) return;
    await widget.controller.apply(
      ProviderApplicationRequest(
        businessName: _businessName.text.trim(),
        serviceTypes: _types.toList(),
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RoleDashboardHeader(
            eyebrow: 'Provider onboarding',
            title: 'Build your care business',
            subtitle:
                'Tell us what you offer. Your profile will be reviewed before clients can book.',
            icon: Icons.storefront_rounded,
            accent: AppColors.accentLight,
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Business details',
            subtitle: 'Use information clients will recognize',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _businessName,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Business name',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
          const SizedBox(height: 18),
          Text('Services offered', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['boarding', 'daycare', 'grooming', 'walking']
                .map(
                  (type) => FilterChip(
                    label: Text(type.capitalizeFirst ?? type),
                    selected: _types.contains(type),
                    onSelected: (selected) {
                      setState(() {
                        selected ? _types.add(type) : _types.remove(type);
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _notes,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Experience and notes',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final loading =
                  widget.controller.mutationStatus.value ==
                  ProviderMutationStatus.loading;
              return FilledButton.icon(
                onPressed: loading ? null : _submit,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  loading ? 'Submitting application' : 'Submit for review',
                ),
              );
            }),
          ),
          Obx(() {
            final error = widget.controller.mutationError.value;
            if (error.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error, style: AppTextStyles.errorText),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.controller});

  final ProviderController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile.value!;
    final rejected = profile.isRejected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
      child: Column(
        children: [
          RoleStatePanel(
            title: rejected ? 'Application needs attention' : 'Review underway',
            message: rejected
                ? (profile.rejectionReason ??
                      'Your application was not approved. Review your details before trying again.')
                : 'Your provider profile is being reviewed. We will unlock services and bookings once it is approved.',
            icon: rejected
                ? Icons.report_gmailerrorred_rounded
                : Icons.hourglass_top_rounded,
            actionLabel: rejected ? 'Refresh status' : 'Check again',
            onAction: controller.loadOverview,
          ),
        ],
      ),
    );
  }
}
