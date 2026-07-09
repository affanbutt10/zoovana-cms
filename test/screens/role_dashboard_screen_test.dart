import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/models/dashboard_models.dart';
import 'package:zoovana_cms/screens/role_dashboard_screen.dart';

void main() {
  testWidgets('renders owner and provider dashboard configs', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(home: RoleDashboardScreen(config: _config('My Zoovana'))),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('My Zoovana'), findsOneWidget);
    expect(find.text('Good morning, Zoovana'), findsWidgets);
    expect(find.text('Booking overview'), findsOneWidget);

    await tester.pumpWidget(
      CupertinoApp(
        home: RoleDashboardScreen(config: _config('Service Provider')),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Service Provider'), findsOneWidget);
    expect(find.text('Good morning, Zoovana'), findsWidgets);
    expect(find.text('Booking overview'), findsOneWidget);
  });
}

RoleDashboardConfig _config(String title) {
  return RoleDashboardConfig(
    title: title,
    subtitle: 'Dashboard',
    greeting: 'Good morning',
    name: 'Zoovana',
    accent: CupertinoColors.activeBlue,
    accentDark: CupertinoColors.systemBlue,
    accentGlow: const Color(0xFFDBEAFE),
    heroGradient: const [Color(0xFF0B1E5B), Color(0xFF1D4ED8)],
    rings: const [
      RingData(color: CupertinoColors.activeBlue, pct: 72, label: 'Active'),
      RingData(color: CupertinoColors.systemYellow, pct: 48, label: 'Pending'),
      RingData(color: CupertinoColors.systemRed, pct: 91, label: 'Complete'),
    ],
    widgets: const [
      WidgetCardData(
        bg: CupertinoColors.activeBlue,
        fg: CupertinoColors.white,
        title: 'Open',
        value: '4',
        sub: 'Today',
      ),
      WidgetCardData(
        bg: CupertinoColors.white,
        fg: Color(0xFF0B1E5B),
        title: 'Next',
        value: 'Ready',
        sub: 'Synced',
        solid: false,
      ),
    ],
    chartLabel: 'Booking overview',
    chartSub: 'Total',
    datasets: const {
      'week': ChartDataset(
        total: '4',
        values: [20, 40, 60, 80, 100, 50, 30],
        labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      ),
    },
    sectionTitle: 'Upcoming',
    cards: const [
      UpcomingCardData(
        tag: 'TODAY',
        icon: '+',
        title: 'Sample item',
        subtitle: 'Preview card',
      ),
    ],
    fabActions: const [FabActionData(label: 'Add', icon: CupertinoIcons.add)],
  );
}
