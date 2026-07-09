import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/core/config/app_colors.dart';
import 'package:zoovana_cms/shared/widgets/role_dashboard_components.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }

  testWidgets('dashboard header renders content and optional action', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        RoleDashboardHeader(
          eyebrow: 'Pet care dashboard',
          title: 'Good to see you, Alex',
          subtitle: 'Your pets are all in one place.',
          icon: Icons.favorite,
          accent: AppColors.accent,
          primaryAction: const Text('Switch'),
        ),
      ),
    );

    expect(find.text('PET CARE DASHBOARD'), findsOneWidget);
    expect(find.text('Good to see you, Alex'), findsOneWidget);
    expect(find.text('Switch'), findsOneWidget);
  });

  testWidgets('metric and quick action expose their interactions', (
    tester,
  ) async {
    var metricTapped = false;
    var actionTapped = false;

    await tester.pumpWidget(
      app(
        Column(
          children: [
            SizedBox(
              height: 112,
              child: RoleMetricTile(
                label: 'My pets',
                value: '3',
                icon: Icons.pets,
                color: AppColors.primary,
                onTap: () => metricTapped = true,
              ),
            ),
            RoleQuickAction(
              label: 'Find care',
              icon: Icons.search,
              color: AppColors.accent,
              onTap: () => actionTapped = true,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('3'));
    await tester.tap(find.text('Find care'));

    expect(metricTapped, isTrue);
    expect(actionTapped, isTrue);
  });
}
