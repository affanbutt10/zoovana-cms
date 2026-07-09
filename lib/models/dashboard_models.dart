import 'package:flutter/cupertino.dart';

/// One activity ring (Apple-Watch style).
class RingData {
  final Color color;
  final double pct; // 0-100
  final String label;
  const RingData({required this.color, required this.pct, required this.label});
}

/// Small "iOS widget"-style card (the streak / next-up pair under the rings).
class WidgetCardData {
  final Color bg;
  final Color fg;
  final String title;
  final String value;
  final String sub;
  final bool solid; // true = colored gradient bg, false = plain white card
  const WidgetCardData({
    required this.bg,
    required this.fg,
    required this.title,
    required this.value,
    required this.sub,
    this.solid = true,
  });
}

/// One dataset for the chart (values 0-100 to size the bars, plus a display total).
class ChartDataset {
  final String total;
  final List<double> values;
  final List<String> labels;
  const ChartDataset({
    required this.total,
    required this.values,
    required this.labels,
  });
}

/// A single "upcoming" carousel card.
class UpcomingCardData {
  final String id;
  final String tag;
  final String icon;
  final String title;
  final String subtitle;
  const UpcomingCardData({
    this.id = '',
    required this.tag,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// One action in the FAB speed-dial.
class FabActionData {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const FabActionData({required this.label, required this.icon, this.onTap});
}

/// Full config for a single role's dashboard. Swap this object to
/// re-skin the whole screen (accent, rings, chart data, cards, FAB).
class RoleDashboardConfig {
  final String title;
  final String subtitle;
  final String greeting;
  final String name;
  final Color accent;
  final Color accentDark;
  final Color accentGlow;
  final List<Color> heroGradient;
  final List<RingData> rings;
  final List<WidgetCardData> widgets;
  final String chartLabel;
  final String chartSub;
  final Map<String, ChartDataset> datasets; // keys: week / month / year
  final String sectionTitle;
  final List<UpcomingCardData> cards;
  final List<FabActionData> fabActions;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onSeeAll;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onOpenMessages;
  final VoidCallback? onOpenSettings;
  final void Function(UpcomingCardData card)? onReschedule;
  final void Function(UpcomingCardData card)? onCancel;

  const RoleDashboardConfig({
    required this.title,
    required this.subtitle,
    required this.greeting,
    required this.name,
    required this.accent,
    required this.accentDark,
    required this.accentGlow,
    required this.heroGradient,
    required this.rings,
    required this.widgets,
    required this.chartLabel,
    required this.chartSub,
    required this.datasets,
    required this.sectionTitle,
    required this.cards,
    required this.fabActions,
    this.onRefresh,
    this.onSeeAll,
    this.onOpenMenu,
    this.onOpenMessages,
    this.onOpenSettings,
    this.onReschedule,
    this.onCancel,
  });
}
