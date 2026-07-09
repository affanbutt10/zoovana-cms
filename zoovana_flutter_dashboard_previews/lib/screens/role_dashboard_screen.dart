import 'package:flutter/cupertino.dart';
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
    // Hook up your real data refetch here.
    await Future.delayed(const Duration(milliseconds: 900));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Native large-title-collapses-into-small-title nav bar.
              CupertinoSliverNavigationBar(
                largeTitle: Text(config.title),
                middle: Text(config.title), // shown once collapsed
                backgroundColor: const Color(0xF2F5F6F9),
                border: null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavIconButton(icon: CupertinoIcons.chat_bubble, onTap: () {}),
                    const SizedBox(width: 8),
                    _NavIconButton(icon: CupertinoIcons.settings, onTap: () {}),
                  ],
                ),
              ),
              // Native pull-to-refresh (iOS spinner) above the content.
              CupertinoSliverRefreshControl(onRefresh: _handleRefresh),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(config.greeting,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF98A2B3), letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(config.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0B1E5B), letterSpacing: -0.7)),
                    const SizedBox(height: 18),
                    _SearchBar(),
                    const SizedBox(height: 20),
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
                        Text(config.sectionTitle, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: Color(0xFF0B1E5B), letterSpacing: -0.3)),
                        GestureDetector(
                          onTap: () {},
                          child: Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: config.accentDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    UpcomingCarousel(
                      cards: config.cards,
                      accent: config.accent,
                      accentDark: config.accentDark,
                      accentGlow: config.accentGlow,
                      onReschedule: (card) {},
                      onCancel: (card) {},
                    ),
                  ]),
                ),
              ),
            ],
          ),
          // FAB sits above the content, bottom-right, ignoring the scaffold's own layout.
          Positioned(
            right: 20,
            bottom: 24,
            child: SpeedDialFab(actions: config.fabActions, accent: config.accent, accentDark: config.accentDark),
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 34,
      onPressed: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0x120B1E5B)),
        ),
        child: Icon(icon, size: 15, color: const Color(0xFF0B1E5B)),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x120B1E5B)),
      ),
      child: const Row(
        children: [
          Icon(CupertinoIcons.search, size: 15, color: Color(0xFF98A2B3)),
          SizedBox(width: 8),
          Text('Search…', style: TextStyle(fontSize: 13, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500)),
        ],
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
        boxShadow: [BoxShadow(color: config.heroGradient.first.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 20))],
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
          .map((w) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: w == config.widgets.first ? 10 : 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: w.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: w.solid ? null : Border.all(color: const Color(0x0F0B1E5B)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A0B1E5B), blurRadius: 2, offset: Offset(0, 1)),
                        BoxShadow(color: Color(0x1F0B1E5B), blurRadius: 24, offset: Offset(0, 12)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.title.toUpperCase(), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: w.fg.withOpacity(0.65))),
                        const SizedBox(height: 8),
                        Text(w.value, style: TextStyle(fontSize: w.solid ? 19 : 15, fontWeight: FontWeight.w800, color: w.fg, letterSpacing: -0.4)),
                        const SizedBox(height: 2),
                        Text(w.sub, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: w.fg.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
