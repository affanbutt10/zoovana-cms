import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_colors.dart';
import '../../../../../core/config/app_text_styles.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/widgets/app_logo.dart';
import '../../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../../shared/widgets/role_dashboard_drawer.dart';
import '../../../auth/presentation/controllers/role_controller.dart';
import '../controllers/dashboard_controller.dart';

// ═══════════════════════════════════════════════════════════════
//  ZOOVANA CMS — DASHBOARD SCREEN
//
//  Scroll order:
//  1. SliverAppBar  — pinned
//  2. KPI Cards     — horizontal scroll, 4 cards
//  3. Revenue Trend — sparkline chart
//  4. Sales by Category — horizontal bar chart
//  5. Recent Orders — card list
// ═══════════════════════════════════════════════════════════════

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const _DashboardBody();
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fade;
  late final List<Animation<Offset>> _slide;

  static const int _n = 7;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = List.generate(_n, (i) {
      final s = (i * 0.11).clamp(0.0, 0.85);
      final e = (s + 0.28).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });
    _slide = List.generate(_n, (i) {
      final s = (i * 0.11).clamp(0.0, 0.85);
      final e = (s + 0.33).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.14),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _r(int i, Widget child) => FadeTransition(
    opacity: _fade[i],
    child: SlideTransition(position: _slide[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleDashboardDrawer(),
      onDrawerChanged: RoleDashboardDrawerController.setOpen,
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── 1. SliverAppBar ───────────────────────────────
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: buildFrostedAppBarBackground(),
              surfaceTintColor: Colors.transparent,
              shadowColor: AppColors.divider,
              elevation: 0,
              scrolledUnderElevation: 1,
              toolbarHeight: 60,
              titleSpacing: 16,
              automaticallyImplyLeading: false,
              leading: Builder(
                builder: (context) => Center(
                  child: IosIconButton(
                    tooltip: 'Open menu',
                    icon: CupertinoIcons.line_horizontal_3,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              title: _r(
                0,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogoTile(size: 34, radius: 10, showShadow: false),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Active role',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Obx(() {
                            final roleController = Get.find<RoleController>();
                            final role =
                                roleController.selectedRole.value ??
                                (roleController.roles.isNotEmpty
                                    ? roleController.roles.first
                                    : null);
                            return Text(
                              _displayRoleName(role?.name),
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                _r(
                  0,
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AppBarBtn(icon: CupertinoIcons.bell, onTap: () {}),
                        const SizedBox(width: 8),
                        _AppBarBtn(
                          icon: CupertinoIcons.gear,
                          onTap: () => context.push(AppRoutes.settings),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            SliverToBoxAdapter(child: _r(1, const _CommerceHero())),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // ── 2. KPI Cards ──────────────────────────────────
            SliverToBoxAdapter(
              child: _r(2, const _SectionLabel(title: 'Overview')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _r(2, const _KpiRow())),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // ── 3. Revenue Trend ──────────────────────────────
            SliverToBoxAdapter(
              child: _r(3, const _SectionLabel(title: 'Revenue Trend')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _r(3, const _RevenueTrendChart())),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── 4. Sales by Category ──────────────────────────
            SliverToBoxAdapter(
              child: _r(4, const _SectionLabel(title: 'Sales by Category')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _r(4, const _SalesByCategoryChart())),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // ── 5. Recent Orders ──────────────────────────────
            SliverToBoxAdapter(
              child: _r(
                5,
                _SectionLabel(
                  title: 'Recent Orders',
                  action: 'View All',
                  onAction: () => context.push(AppRoutes.moduleOrders),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _r(5, const _RecentOrders())),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }

  String _displayRoleName(String? roleName) {
    if (roleName == null || roleName.isEmpty) return 'Zoovana Member';
    const labels = {
      'animalowner': 'Animal Lover',
      'serviceprovider': 'Pet Care Provider',
      'shop_owner': 'Shop Owner',
      'shelter': 'Shelter',
      'volunteer': 'Volunteer',
      'marketplace_client': 'Marketplace Client',
    };
    final normalized = roleName.toLowerCase().replaceAll(' ', '_');
    return labels[normalized] ??
        normalized
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────

class _CommerceHero extends StatelessWidget {
  const _CommerceHero();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final overview = controller.overview.value;
        return RoleDashboardHeader(
          eyebrow: 'Commerce command center',
          title: 'Sell smarter across every shop',
          subtitle:
              'Track revenue, inventory pressure, order flow, and category performance from one premium operating view.',
          icon: CupertinoIcons.bag_fill,
          accent: AppColors.accentLight,
          stats: [
            RoleHeroStat(
              label: 'Revenue',
              value: 'SAR ${overview?.totalRevenue ?? 0}',
              icon: CupertinoIcons.money_dollar_circle,
            ),
            RoleHeroStat(
              label: 'Orders',
              value: '${overview?.totalOrders ?? 0}',
              icon: CupertinoIcons.cart,
            ),
            RoleHeroStat(
              label: 'Low stock',
              value: '${overview?.lowStockCount ?? 0}',
              icon: CupertinoIcons.exclamationmark_triangle,
            ),
          ],
          primaryAction: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.products),
            icon: const Icon(CupertinoIcons.add, size: 18),
            label: const Text('Product'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IosIconButton(
      icon: icon,
      onTap: onTap,
      foregroundColor: AppColors.textSecondary,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionLabel({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  KPI CARDS - Real data from API
// ═══════════════════════════════════════════════════════════════

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      // Loading state
      if (controller.status.value == DashboardStatus.loading) {
        return SizedBox(
          height: 128,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
        );
      }

      // Error state
      if (controller.status.value == DashboardStatus.error) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.errorMessage.value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => controller.loadDashboard(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Success state - show real data
      final overview = controller.overview.value;
      if (overview == null) {
        return const SizedBox(height: 128);
      }

      final cards = [
        _KpiData(
          'Total Revenue',
          'SAR ${overview.totalRevenue}',
          '${overview.revenueChangePercentage.toStringAsFixed(1)}%',
          overview.revenueChangePercentage >= 0,
          Icons.payments_rounded,
          AppColors.primary,
          false,
        ),
        _KpiData(
          'Total Orders',
          '${overview.totalOrders}',
          '${overview.ordersChangePercentage.toStringAsFixed(1)}%',
          overview.ordersChangePercentage >= 0,
          Icons.shopping_cart_rounded,
          AppColors.accent,
          false,
        ),
        _KpiData(
          'Active Shops',
          '${overview.activeShops}',
          '+${overview.newShopsCount} new',
          true,
          Icons.storefront_rounded,
          AppColors.success,
          false,
        ),
        _KpiData(
          'Low Stock',
          '${overview.lowStockCount}',
          'Needs attention',
          false,
          Icons.warning_amber_rounded,
          AppColors.error,
          overview.lowStockCount > 0,
        ),
      ];

      return SizedBox(
        height: 128,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _KpiCard(data: cards[i]),
        ),
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final alert = data.isAlert && data.value != '0';
    final col = alert ? AppColors.error : data.color;
    return Container(
      width: 146,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: alert
              ? AppColors.error.withValues(alpha: 0.38)
              : AppColors.divider,
          width: alert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: col.withValues(alpha: alert ? 0.12 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(data.icon, color: col, size: 16),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (data.trendUp ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        data.trendUp
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 9,
                        color: data.trendUp
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          data.trend,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: data.trendUp
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: alert ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _KpiData {
  final String label, value, trend;
  final bool trendUp;
  final IconData icon;
  final Color color;
  final bool isAlert;
  const _KpiData(
    this.label,
    this.value,
    this.trend,
    this.trendUp,
    this.icon,
    this.color,
    this.isAlert,
  );
}

// ═══════════════════════════════════════════════════════════════
//  REVENUE TREND CHART - Real data from API
// ═══════════════════════════════════════════════════════════════

class _RevenueTrendChart extends StatelessWidget {
  const _RevenueTrendChart();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final overview = controller.overview.value;

      // Show empty state if no data
      if (overview == null || overview.revenueTrend.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceAtElevation(1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.show_chart, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  'No revenue data available',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Extract values and labels from real data
      final values = overview.revenueTrend.map((e) => e.amount).toList();
      final labels = overview.revenueTrend.map((e) => e.period).toList();
      final latestRevenue = values.isNotEmpty ? values.last : 0.0;
      final percentChange = overview.revenueChangePercentage;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAtElevation(1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAR ${latestRevenue.toStringAsFixed(2)}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Revenue this month',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _TrendBadge(
                  label:
                      '${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                  up: percentChange >= 0,
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 110,
              child: CustomPaint(
                painter: _LinePainter(
                  values: values,
                  lineColor: AppColors.primary,
                  fillColor: AppColors.primary.withValues(alpha: 0.07),
                  dotColor: AppColors.primary,
                  surfaceColor: AppColors.surface,
                ),
                size: const Size(double.infinity, 110),
              ),
            ),
            const SizedBox(height: 8),
            if (labels.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels
                    .map(
                      (l) => Text(
                        l,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════
//  SALES BY CATEGORY CHART - Real data from API
// ═══════════════════════════════════════════════════════════════

class _SalesByCategoryChart extends StatelessWidget {
  const _SalesByCategoryChart();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final overview = controller.overview.value;

      // Show empty state if no data
      if (overview == null || overview.salesByCategory.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceAtElevation(1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.pie_chart, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  'No sales data available',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Convert real data to chart format
      final colors = [
        AppColors.primary,
        AppColors.accent,
        AppColors.highlight,
        AppColors.success,
        AppColors.coral,
      ];

      final cats = overview.salesByCategory.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final color = colors[index % colors.length];
        return _CatBar(
          category.categoryName,
          category.percentage / 100, // Convert percentage to fraction
          color,
        );
      }).toList();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceAtElevation(1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Top Categories',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'This month',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...cats.map((c) => _HorizBar(cat: c)),
          ],
        ),
      );
    });
  }
}

class _HorizBar extends StatelessWidget {
  final _CatBar cat;
  const _HorizBar({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                cat.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '${(cat.fraction * 100).toInt()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: cat.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (_, c) => Stack(
              children: [
                Container(
                  height: 7,
                  width: c.maxWidth,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  height: 7,
                  width: c.maxWidth * cat.fraction,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cat.color.withValues(alpha: 0.7), cat.color],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: cat.color.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatBar {
  final String label;
  final double fraction;
  final Color color;
  const _CatBar(this.label, this.fraction, this.color);
}

class _TrendBadge extends StatelessWidget {
  final String label;
  final bool up;
  const _TrendBadge({required this.label, required this.up});

  @override
  Widget build(BuildContext context) {
    final color = up ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor, fillColor, dotColor, surfaceColor;
  const _LinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final range = (maxV - minV).clamp(1.0, double.infinity);
    final stepX = size.width / (values.length - 1);

    Offset pt(int i) {
      final x = i * stepX;
      final y =
          size.height -
          ((values[i] - minV) / range) * size.height * 0.82 -
          size.height * 0.06;
      return Offset(x, y);
    }

    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 0; i < values.length - 1; i++) {
      final a = pt(i), b = pt(i + 1);
      path.cubicTo(
        (a.dx + b.dx) / 2,
        a.dy,
        (a.dx + b.dx) / 2,
        b.dy,
        b.dx,
        b.dy,
      );
    }
    canvas.drawPath(
      Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = fillColor,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (int i = 0; i < values.length; i++) {
      final p = pt(i);
      canvas.drawCircle(p, 5, Paint()..color = surfaceColor);
      canvas.drawCircle(p, 3.5, Paint()..color = dotColor);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.values != values || old.lineColor != lineColor;
}

// ═══════════════════════════════════════════════════════════════
//  RECENT ORDERS
// ═══════════════════════════════════════════════════════════════

class _RecentOrders extends StatelessWidget {
  const _RecentOrders();

  static const _orders = [
    _OData(
      '#4821',
      'Premium Dog Food × 2',
      'SAR 148.00',
      _OS.fulfilled,
      '2 hr ago',
    ),
    _OData('#4820', 'Cat Grooming Kit', 'SAR 89.50', _OS.pending, '5 hr ago'),
    _OData(
      '#4819',
      'Vet Supplement Pack',
      'SAR 220.00',
      _OS.processing,
      '1 day ago',
    ),
    _OData(
      '#4818',
      'Bird Cage Deluxe',
      'SAR 375.00',
      _OS.cancelled,
      '2 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAtElevation(1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ..._orders.asMap().entries.map(
            (e) => Column(
              children: [
                _ORow(order: e.value),
                if (e.key < _orders.length - 1)
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: AppColors.divider,
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.push(AppRoutes.moduleOrders),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  'View All Orders',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ORow extends StatelessWidget {
  final _OData order;
  const _ORow({required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.number,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.items,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.date,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.total,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _OBadge(status: order.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OBadge extends StatelessWidget {
  final _OS status;
  const _OBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _OS.fulfilled => ('Fulfilled', AppColors.success),
      _OS.pending => ('Pending', AppColors.warning),
      _OS.processing => ('Processing', AppColors.primary),
      _OS.cancelled => ('Cancelled', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _OData {
  final String number, items, total, date;
  final _OS status;
  const _OData(this.number, this.items, this.total, this.status, this.date);
}

enum _OS { fulfilled, pending, processing, cancelled }

// ═══════════════════════════════════════════════════════════════
//  MODULE DETAIL SCREENS  — each with dummy data
// ═══════════════════════════════════════════════════════════════

// ── Shared scaffold for all module screens ────────────────────

class _ModuleScaffold extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;
  final Widget body;

  const _ModuleScaffold({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            shadowColor: AppColors.divider,
            elevation: 0,
            scrolledUnderElevation: 1,
            toolbarHeight: 60,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: accentColor, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          body,
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── Shared list tile ──────────────────────────────────────────

class _ListTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;

  const _ListTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppColors.primary).withValues(
                        alpha: 0.11,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: (badgeColor ?? AppColors.primary).withValues(
                          alpha: 0.25,
                        ),
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: badgeColor ?? AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _divider() =>
    Divider(height: 1, indent: 78, endIndent: 20, color: AppColors.divider);

Widget _listCard(List<Widget> children) => Container(
  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
  decoration: BoxDecoration(
    color: AppColors.surfaceAtElevation(1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.divider),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: children
        .asMap()
        .entries
        .map(
          (e) => Column(
            children: [e.value, if (e.key < children.length - 1) _divider()],
          ),
        )
        .toList(),
  ),
);

// ── BRANCHES ─────────────────────────────────────────────────

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Branches',
      accentColor: AppColors.secondary,
      icon: Icons.account_tree_rounded,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _listCard([
            _ListTile(
              icon: Icons.store_rounded,
              color: AppColors.secondary,
              title: 'Riyadh — Al Olaya',
              subtitle: '23 products · 4 staff',
              badge: 'Active',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.store_rounded,
              color: AppColors.secondary,
              title: 'Jeddah — Al Hamra',
              subtitle: '18 products · 3 staff',
              badge: 'Active',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.store_rounded,
              color: AppColors.secondary,
              title: 'Dammam — Corniche',
              subtitle: '11 products · 2 staff',
              badge: 'Active',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.store_rounded,
              color: AppColors.secondary,
              title: 'Mecca — Al Aziziyah',
              subtitle: '7 products · 1 staff',
              badge: 'Pending',
              badgeColor: AppColors.warning,
            ),
            _ListTile(
              icon: Icons.store_rounded,
              color: AppColors.secondary,
              title: 'Medina — Al Haram',
              subtitle: '0 products · 0 staff',
              badge: 'Inactive',
              badgeColor: AppColors.textTertiary,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── SUPPLIERS ────────────────────────────────────────────────

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Suppliers',
      accentColor: AppColors.accent,
      icon: Icons.local_shipping_rounded,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _listCard([
            _ListTile(
              icon: Icons.business_rounded,
              color: AppColors.accent,
              title: 'PetNutrition Co.',
              subtitle: 'Food & supplements · 42 SKUs',
              badge: 'Preferred',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.business_rounded,
              color: AppColors.accent,
              title: 'VetSupply Arabia',
              subtitle: 'Medical & grooming · 28 SKUs',
              badge: 'Active',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.business_rounded,
              color: AppColors.accent,
              title: 'PawsAccessories',
              subtitle: 'Toys & accessories · 61 SKUs',
              badge: 'Active',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.business_rounded,
              color: AppColors.accent,
              title: 'AquaLife Imports',
              subtitle: 'Aquatic products · 15 SKUs',
              badge: 'Review',
              badgeColor: AppColors.warning,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── CATEGORIES ───────────────────────────────────────────────

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Categories',
      accentColor: AppColors.highlight,
      icon: Icons.category_rounded,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _listCard([
            _ListTile(
              icon: Icons.restaurant_rounded,
              color: AppColors.highlight,
              title: 'Pet Food',
              subtitle: '34 products',
              badge: '34',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.content_cut_rounded,
              color: AppColors.highlight,
              title: 'Grooming',
              subtitle: '21 products',
              badge: '21',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.medical_services_rounded,
              color: AppColors.highlight,
              title: 'Medicine',
              subtitle: '18 products',
              badge: '18',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.toys_rounded,
              color: AppColors.highlight,
              title: 'Toys & Accessories',
              subtitle: '29 products',
              badge: '29',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.home_rounded,
              color: AppColors.highlight,
              title: 'Housing & Cages',
              subtitle: '12 products',
              badge: '12',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.water_rounded,
              color: AppColors.highlight,
              title: 'Aquatic',
              subtitle: '14 products',
              badge: '14',
              badgeColor: AppColors.primary,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── INVENTORY ────────────────────────────────────────────────

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Inventory',
      accentColor: AppColors.success,
      icon: Icons.warehouse_rounded,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _listCard([
            _ListTile(
              icon: Icons.inventory_2_rounded,
              color: AppColors.success,
              title: 'Premium Dog Food 5kg',
              subtitle: 'SKU: PF-001 · 48 units',
              badge: 'In Stock',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.inventory_2_rounded,
              color: AppColors.success,
              title: 'Cat Grooming Kit',
              subtitle: 'SKU: GK-012 · 12 units',
              badge: 'Low',
              badgeColor: AppColors.warning,
            ),
            _ListTile(
              icon: Icons.inventory_2_rounded,
              color: AppColors.success,
              title: 'Vet Supplement Pack',
              subtitle: 'SKU: VS-034 · 0 units',
              badge: 'Out',
              badgeColor: AppColors.error,
            ),
            _ListTile(
              icon: Icons.inventory_2_rounded,
              color: AppColors.success,
              title: 'Bird Cage Deluxe',
              subtitle: 'SKU: BC-007 · 6 units',
              badge: 'Low',
              badgeColor: AppColors.warning,
            ),
            _ListTile(
              icon: Icons.inventory_2_rounded,
              color: AppColors.success,
              title: 'Aquarium Starter Kit',
              subtitle: 'SKU: AQ-019 · 22 units',
              badge: 'In Stock',
              badgeColor: AppColors.success,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── PURCHASE ORDERS ──────────────────────────────────────────

class PurchaseOrdersScreen extends StatelessWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Purchase Orders',
      accentColor: AppColors.warning,
      icon: Icons.shopping_cart_rounded,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _listCard([
            _ListTile(
              icon: Icons.receipt_rounded,
              color: AppColors.warning,
              title: 'PO-2024-0041',
              subtitle: 'PetNutrition Co. · SAR 3,200',
              badge: 'Received',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.receipt_rounded,
              color: AppColors.warning,
              title: 'PO-2024-0040',
              subtitle: 'VetSupply Arabia · SAR 1,850',
              badge: 'In Transit',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.receipt_rounded,
              color: AppColors.warning,
              title: 'PO-2024-0039',
              subtitle: 'PawsAccessories · SAR 920',
              badge: 'Pending',
              badgeColor: AppColors.warning,
            ),
            _ListTile(
              icon: Icons.receipt_rounded,
              color: AppColors.warning,
              title: 'PO-2024-0038',
              subtitle: 'AquaLife Imports · SAR 540',
              badge: 'Cancelled',
              badgeColor: AppColors.error,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── MARKETPLACE ORDERS ───────────────────────────────────────

class MarketplaceOrdersScreen extends StatelessWidget {
  const MarketplaceOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Marketplace Orders',
      accentColor: AppColors.secondary,
      icon: Icons.storefront_rounded,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _listCard([
            _ListTile(
              icon: Icons.shopping_bag_rounded,
              color: AppColors.secondary,
              title: '#4821 — Premium Dog Food × 2',
              subtitle: 'SAR 148.00 · 2 hr ago',
              badge: 'Fulfilled',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.shopping_bag_rounded,
              color: AppColors.secondary,
              title: '#4820 — Cat Grooming Kit',
              subtitle: 'SAR 89.50 · 5 hr ago',
              badge: 'Pending',
              badgeColor: AppColors.warning,
            ),
            _ListTile(
              icon: Icons.shopping_bag_rounded,
              color: AppColors.secondary,
              title: '#4819 — Vet Supplement Pack',
              subtitle: 'SAR 220.00 · 1 day ago',
              badge: 'Processing',
              badgeColor: AppColors.primary,
            ),
            _ListTile(
              icon: Icons.shopping_bag_rounded,
              color: AppColors.secondary,
              title: '#4818 — Bird Cage Deluxe',
              subtitle: 'SAR 375.00 · 2 days ago',
              badge: 'Cancelled',
              badgeColor: AppColors.error,
            ),
            _ListTile(
              icon: Icons.shopping_bag_rounded,
              color: AppColors.secondary,
              title: '#4817 — Aquarium Starter Kit',
              subtitle: 'SAR 290.00 · 3 days ago',
              badge: 'Fulfilled',
              badgeColor: AppColors.success,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── INVOICES ─────────────────────────────────────────────────

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModuleScaffold(
      title: 'Invoices',
      accentColor: AppColors.coral,
      icon: Icons.receipt_long_rounded,
      body: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _listCard([
            _ListTile(
              icon: Icons.description_rounded,
              color: AppColors.coral,
              title: 'INV-2024-0089',
              subtitle: 'PetWorld Store · SAR 1,240',
              badge: 'Paid',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.description_rounded,
              color: AppColors.coral,
              title: 'INV-2024-0088',
              subtitle: 'FurFriends Shop · SAR 680',
              badge: 'Paid',
              badgeColor: AppColors.success,
            ),
            _ListTile(
              icon: Icons.description_rounded,
              color: AppColors.coral,
              title: 'INV-2024-0087',
              subtitle: 'AquaZone · SAR 420',
              badge: 'Overdue',
              badgeColor: AppColors.error,
            ),
            _ListTile(
              icon: Icons.description_rounded,
              color: AppColors.coral,
              title: 'INV-2024-0086',
              subtitle: 'PawsParadise · SAR 890',
              badge: 'Pending',
              badgeColor: AppColors.warning,
            ),
            _ListTile(
              icon: Icons.description_rounded,
              color: AppColors.coral,
              title: 'INV-2024-0085',
              subtitle: 'VetCare Center · SAR 2,100',
              badge: 'Paid',
              badgeColor: AppColors.success,
            ),
          ]),
        ),
      ),
    );
  }
}
