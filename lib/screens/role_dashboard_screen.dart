import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Scaffold, SliverPersistentHeaderDelegate;
import 'package:flutter/services.dart';
import '../models/dashboard_models.dart';
import '../widgets/activity_rings.dart';
import '../widgets/segmented_bar_chart.dart';
import '../widgets/upcoming_carousel.dart';
import '../widgets/speed_dial_fab.dart';

/// Single reusable dashboard screen. Pass a different [RoleDashboardConfig]
/// to completely re-skin it for Owner / Volunteer / Shelter / Shop / Provider
/// — this file itself never needs to change per role.
class RoleDashboardScreen extends StatelessWidget {
  final RoleDashboardConfig config;

  const RoleDashboardScreen({super.key, required this.config});

  Future<void> _handleRefresh() async {
    await config.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _CollapsingDashboardChromeDelegate(
                  config: config,
                  topPadding: topPadding,
                ),
              ),
              // Native pull-to-refresh (iOS spinner) above the content.
              CupertinoSliverRefreshControl(onRefresh: _handleRefresh),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _RingsCard(config: config),
                    const SizedBox(height: 12),
                    _WidgetsRow(config: config),
                    const SizedBox(height: 24),
                    SegmentedBarChart(
                      chartLabel: config.chartLabel,
                      chartSub: config.chartSub,
                      datasets: config.datasets,
                      accent: config.accent,
                      accentDark: config.accentDark,
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          config.sectionTitle,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B1E5B),
                            letterSpacing: -0.3,
                          ),
                        ),
                        GestureDetector(
                          onTap: config.onSeeAll,
                          child: Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: config.accentDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    UpcomingCarousel(
                      cards: config.cards,
                      accent: config.accent,
                      accentDark: config.accentDark,
                      accentGlow: config.accentGlow,
                      onReschedule: config.onReschedule,
                      onCancel: config.onCancel,
                    ),
                  ]),
                ),
              ),
            ],
          ),
          if (config.fabActions.isNotEmpty)
            Positioned(
              right: 20,
              bottom: bottomPadding + 92,
              child: SpeedDialFab(
                actions: config.fabActions,
                accent: config.accent,
                accentDark: config.accentDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _CollapsingDashboardChromeDelegate
    extends SliverPersistentHeaderDelegate {
  const _CollapsingDashboardChromeDelegate({
    required this.config,
    required this.topPadding,
  });

  final RoleDashboardConfig config;
  final double topPadding;

  static const double _toolbarHeight = 54;
  static const double _largeTitleHeight = 112;

  @override
  double get minExtent => topPadding + _toolbarHeight;

  @override
  double get maxExtent => topPadding + _toolbarHeight + _largeTitleHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / _largeTitleHeight).clamp(0.0, 1.0);
    final frostOpacity = ((progress - 0.62) / 0.38).clamp(0.0, 1.0);
    final compactTitleOpacity = ((progress - 0.72) / 0.28).clamp(0.0, 1.0);
    final largeTitleOpacity = (1 - (progress / 0.82)).clamp(0.0, 1.0);
    final compactTitle = '${config.greeting}, ${config.name}';

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: frostOpacity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F9).withValues(alpha: 0.78),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF0B1E5B).withValues(alpha: 0.06),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 50 - (progress * 20),
            left: 18,
            right: 18,
            child: Opacity(
              opacity: largeTitleOpacity,
              child: Transform.translate(
                offset: Offset(0, -8 * progress),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B1E5B),
                        letterSpacing: 0,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      compactTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B1E5B),
                        letterSpacing: 0,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: _toolbarHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: compactTitleOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 92),
                    child: Text(
                      compactTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B1E5B),
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                  child: Row(
                    children: [
                      _NavIconButton(
                        icon: CupertinoIcons.line_horizontal_3,
                        onTap:
                            config.onOpenMenu ??
                            () => Scaffold.maybeOf(context)?.openDrawer(),
                      ),
                      const Spacer(),
                      _NavIconButton(
                        icon: CupertinoIcons.chat_bubble,
                        onTap: config.onOpenMessages ?? () {},
                      ),
                      const SizedBox(width: 10),
                      _NavIconButton(
                        icon: CupertinoIcons.settings,
                        onTap: config.onOpenSettings ?? () {},
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

  @override
  bool shouldRebuild(covariant _CollapsingDashboardChromeDelegate oldDelegate) {
    return oldDelegate.config != config || oldDelegate.topPadding != topPadding;
  }
}

class _NavIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIconButton({required this.icon, required this.onTap});

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x120B1E5B)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0B1E5B),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
              BoxShadow(
                color: Color(0x140B1E5B),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(widget.icon, size: 22, color: const Color(0xFF0B1E5B)),
        ),
      ),
    );
  }
}

class _RingsCard extends StatelessWidget {
  final RoleDashboardConfig config;
  const _RingsCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.heroGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: config.heroGradient.first.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        children: [
          ActivityRings(rings: config.rings, size: 96),
          const SizedBox(width: 16),
          Expanded(child: RingsLegend(rings: config.rings)),
        ],
      ),
    );
  }
}

class _WidgetsRow extends StatelessWidget {
  final RoleDashboardConfig config;
  const _WidgetsRow({required this.config});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: config.widgets
          .map(
            (w) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: w == config.widgets.first ? 10 : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: w.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: w.solid
                        ? null
                        : Border.all(color: const Color(0x0F0B1E5B)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A0B1E5B),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                      BoxShadow(
                        color: Color(0x1F0B1E5B),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: w.fg.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        w.value,
                        style: TextStyle(
                          fontSize: w.solid ? 19 : 15,
                          fontWeight: FontWeight.w800,
                          color: w.fg,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        w.sub,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: w.fg.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
