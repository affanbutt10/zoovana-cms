// Preservation Property Tests — Theme Transition Animation Bugfix
//
// PURPOSE: Capture baseline behavior that MUST be preserved after the fix.
// These tests MUST PASS on UNFIXED code — they confirm the behaviors that
// the fix must not break.
//
// Requirements: 3.1, 3.2, 3.3, 3.4, 3.5
//
// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoovana_cms/core/config/app_colors.dart';
import 'package:zoovana_cms/core/theme/app_theme_controller.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Reset the AppThemeController to light mode before each test.
Future<void> _resetToLight() async {
  SharedPreferences.setMockInitialValues({});
  AppColors.applyTheme(isDarkMode: false);
  if (AppThemeController.instance.isDarkMode) {
    await AppThemeController.instance.setThemeMode(ThemeMode.light);
  }
}

/// Reset the AppThemeController to dark mode before a test.
// ignore: unused_element
Future<void> _resetToDark() async {
  SharedPreferences.setMockInitialValues({});
  AppColors.applyTheme(isDarkMode: true);
  if (!AppThemeController.instance.isDarkMode) {
    await AppThemeController.instance.setThemeMode(ThemeMode.dark);
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  // ---------------------------------------------------------------------------
  // 3.1 Startup: persisted 'dark' preference → Brightness.dark immediately
  // ---------------------------------------------------------------------------
  group('3.1 Startup theme preservation', () {
    test(
      'PROPERTY: cold start with persisted dark preference applies ThemeMode.dark immediately',
      () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
        AppColors.applyTheme(isDarkMode: false); // start from opposite

        await AppThemeController.instance.load();

        expect(
          AppThemeController.instance.themeMode,
          equals(ThemeMode.dark),
          reason:
              'After load() with persisted dark preference, themeMode must be ThemeMode.dark',
        );
        expect(
          AppThemeController.instance.isDarkMode,
          isTrue,
          reason:
              'isDarkMode must be true after loading persisted dark preference',
        );
      },
    );

    test(
      'PROPERTY: cold start with persisted light preference applies ThemeMode.light immediately',
      () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});
        AppColors.applyTheme(isDarkMode: true); // start from opposite

        await AppThemeController.instance.load();

        expect(
          AppThemeController.instance.themeMode,
          equals(ThemeMode.light),
          reason:
              'After load() with persisted light preference, themeMode must be ThemeMode.light',
        );
        expect(
          AppThemeController.instance.isDarkMode,
          isFalse,
          reason:
              'isDarkMode must be false after loading persisted light preference',
        );
      },
    );

    test(
      'PROPERTY: cold start with no persisted preference defaults to ThemeMode.light',
      () async {
        SharedPreferences.setMockInitialValues({});
        AppColors.applyTheme(isDarkMode: true); // start from opposite

        await AppThemeController.instance.load();

        expect(
          AppThemeController.instance.themeMode,
          equals(ThemeMode.light),
          reason:
              'With no persisted preference, themeMode must default to ThemeMode.light',
        );
      },
    );

    // Property-based: multiple persisted values all load correctly.
    test(
      'PROPERTY: startup load always reflects the persisted value (loop over all cases)',
      () async {
        final testCases = [
          ('dark', ThemeMode.dark, true),
          ('light', ThemeMode.light, false),
          ('unknown', ThemeMode.light, false), // unknown → defaults to light
        ];

        for (final (stored, expectedMode, expectedDark) in testCases) {
          SharedPreferences.setMockInitialValues({'app_theme_mode': stored});
          AppColors.applyTheme(isDarkMode: !expectedDark); // start from opposite

          await AppThemeController.instance.load();

          expect(
            AppThemeController.instance.themeMode,
            equals(expectedMode),
            reason: 'Stored "$stored" should load as $expectedMode',
          );
          expect(
            AppThemeController.instance.isDarkMode,
            equals(expectedDark),
            reason:
                'Stored "$stored" should set isDarkMode=$expectedDark',
          );
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // 3.2 Persistence: after toggleTheme(), SharedPreferences contains updated mode
  // ---------------------------------------------------------------------------
  group('3.2 Persistence preservation', () {
    setUp(() async => _resetToLight());

    test(
      'PROPERTY: after toggleTheme() from light, SharedPreferences contains "dark"',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.light);

        await AppThemeController.instance.toggleTheme();

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getString('app_theme_mode'),
          equals('dark'),
          reason:
              'After toggling from light to dark, prefs must contain "dark"',
        );
      },
    );

    test(
      'PROPERTY: after toggleTheme() from dark, SharedPreferences contains "light"',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.dark);

        await AppThemeController.instance.toggleTheme();

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getString('app_theme_mode'),
          equals('light'),
          reason:
              'After toggling from dark to light, prefs must contain "light"',
        );
      },
    );

    // Property-based: any sequence of setThemeMode calls persists the last mode.
    test(
      'PROPERTY: last non-redundant setThemeMode call wins in SharedPreferences',
      () async {
        // [sequence of modes, expected final persisted value]
        final testCases = [
          ([ThemeMode.dark, ThemeMode.light, ThemeMode.dark], 'dark'),
          ([ThemeMode.light, ThemeMode.dark, ThemeMode.light], 'light'),
          ([ThemeMode.dark, ThemeMode.dark, ThemeMode.dark], 'dark'),
          ([ThemeMode.light, ThemeMode.light, ThemeMode.light], 'light'),
          ([ThemeMode.dark, ThemeMode.light], 'light'),
          ([ThemeMode.light, ThemeMode.dark], 'dark'),
        ];

        for (final (sequence, expectedStored) in testCases) {
          SharedPreferences.setMockInitialValues({});
          // Reset to light before each sequence.
          await AppThemeController.instance.setThemeMode(ThemeMode.light);

          for (final mode in sequence) {
            await AppThemeController.instance.setThemeMode(mode);
          }

          final prefs = await SharedPreferences.getInstance();
          final stored = prefs.getString('app_theme_mode');
          expect(
            stored,
            equals(expectedStored),
            reason:
                'After sequence $sequence, SharedPreferences must contain '
                '"$expectedStored" but got "$stored"',
          );
        }
      },
    );

    // Property-based: controller themeMode always matches last non-redundant call.
    test(
      'PROPERTY: controller themeMode always equals the last non-redundant setThemeMode call',
      () async {
        final sequences = [
          [ThemeMode.dark, ThemeMode.light, ThemeMode.dark],
          [ThemeMode.light, ThemeMode.dark, ThemeMode.light],
          [ThemeMode.dark, ThemeMode.dark, ThemeMode.dark],
          [ThemeMode.light, ThemeMode.light, ThemeMode.light],
          [ThemeMode.dark],
          [ThemeMode.light],
          [ThemeMode.light, ThemeMode.dark],
          [ThemeMode.dark, ThemeMode.light],
          [ThemeMode.dark, ThemeMode.light, ThemeMode.dark, ThemeMode.light],
        ];

        for (final sequence in sequences) {
          SharedPreferences.setMockInitialValues({});
          await AppThemeController.instance.setThemeMode(ThemeMode.light);

          ThemeMode lastMode = ThemeMode.light;
          for (final mode in sequence) {
            await AppThemeController.instance.setThemeMode(mode);
            lastMode = mode;
          }

          expect(
            AppThemeController.instance.themeMode,
            equals(lastMode),
            reason:
                'After sequence $sequence, themeMode must equal the last call: $lastMode',
          );
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // 3.3 System UI: after toggleTheme(), isDarkMode reflects the correct brightness
  //
  // Note: SystemChrome.setSystemUIOverlayStyle cannot be intercepted in unit tests.
  // We verify the controller state that DRIVES the SystemChrome call in app.dart:
  //   isDarkMode == true  → iconBrightness = Brightness.light
  //   isDarkMode == false → iconBrightness = Brightness.dark
  // ---------------------------------------------------------------------------
  group('3.3 System UI overlay preservation', () {
    setUp(() async => _resetToLight());

    test(
      'PROPERTY: after toggle light→dark, isDarkMode=true → iconBrightness should be Brightness.light',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.light);

        await AppThemeController.instance.toggleTheme();

        expect(
          AppThemeController.instance.isDarkMode,
          isTrue,
          reason: 'After light→dark toggle, isDarkMode must be true',
        );
        // The expected iconBrightness that app.dart would pass to SystemChrome:
        final expectedIconBrightness = AppThemeController.instance.isDarkMode
            ? Brightness.light
            : Brightness.dark;
        expect(
          expectedIconBrightness,
          equals(Brightness.light),
          reason:
              'In dark mode, statusBarIconBrightness should be Brightness.light '
              '(light icons on dark background)',
        );
      },
    );

    test(
      'PROPERTY: after toggle dark→light, isDarkMode=false → iconBrightness should be Brightness.dark',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.dark);

        await AppThemeController.instance.toggleTheme();

        expect(
          AppThemeController.instance.isDarkMode,
          isFalse,
          reason: 'After dark→light toggle, isDarkMode must be false',
        );
        final expectedIconBrightness = AppThemeController.instance.isDarkMode
            ? Brightness.light
            : Brightness.dark;
        expect(
          expectedIconBrightness,
          equals(Brightness.dark),
          reason:
              'In light mode, statusBarIconBrightness should be Brightness.dark '
              '(dark icons on light background)',
        );
      },
    );

    // Property-based: for any ThemeMode, the derived brightness values are correct.
    test(
      'PROPERTY: brightness values derived from isDarkMode are always correct for any mode',
      () async {
        final testCases = [
          (ThemeMode.dark, Brightness.light, Brightness.dark),
          (ThemeMode.light, Brightness.dark, Brightness.light),
        ];

        for (final (mode, expectedIconBrightness, expectedStatusBarBrightness)
            in testCases) {
          SharedPreferences.setMockInitialValues({});
          await AppThemeController.instance.setThemeMode(mode);

          final isDark = AppThemeController.instance.isDarkMode;
          final iconBrightness = isDark ? Brightness.light : Brightness.dark;
          final statusBarBrightness =
              isDark ? Brightness.dark : Brightness.light;

          expect(
            iconBrightness,
            equals(expectedIconBrightness),
            reason:
                'For $mode, iconBrightness must be $expectedIconBrightness',
          );
          expect(
            statusBarBrightness,
            equals(expectedStatusBarBrightness),
            reason:
                'For $mode, statusBarBrightness must be $expectedStatusBarBrightness',
          );
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // 3.4 Redundant call no-op: setThemeMode(currentMode) is a no-op
  // ---------------------------------------------------------------------------
  group('3.4 Redundant call no-op preservation', () {
    setUp(() async => _resetToLight());

    test(
      'PROPERTY: setThemeMode(currentMode) does not change themeMode',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.light);

        // Call with the same mode — should be a no-op.
        await AppThemeController.instance.setThemeMode(ThemeMode.light);

        expect(
          AppThemeController.instance.themeMode,
          equals(ThemeMode.light),
          reason: 'Redundant setThemeMode(light) must not change themeMode',
        );
      },
    );

    test(
      'PROPERTY: setThemeMode(currentMode) does not write to SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.light);

        // Clear prefs to detect any spurious write.
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Redundant call — must not write to prefs.
        await AppThemeController.instance.setThemeMode(ThemeMode.light);

        final storedAfter = prefs.getString('app_theme_mode');
        expect(
          storedAfter,
          isNull,
          reason:
              'Redundant setThemeMode(light) must not write to SharedPreferences',
        );
      },
    );

    test(
      'PROPERTY: setThemeMode(currentMode) does not change isDarkMode',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.dark);
        expect(AppThemeController.instance.isDarkMode, isTrue);

        // Redundant call with same mode.
        await AppThemeController.instance.setThemeMode(ThemeMode.dark);

        expect(
          AppThemeController.instance.isDarkMode,
          isTrue,
          reason: 'Redundant setThemeMode(dark) must not change isDarkMode',
        );
      },
    );

    // Property-based: redundant calls for both modes are always no-ops.
    test(
      'PROPERTY: redundant setThemeMode calls are always no-ops for any mode',
      () async {
        final modes = [ThemeMode.light, ThemeMode.dark];

        for (final mode in modes) {
          SharedPreferences.setMockInitialValues({});
          await AppThemeController.instance.setThemeMode(mode);

          final prefs = await SharedPreferences.getInstance();
          await prefs.clear(); // clear to detect spurious writes

          // Call multiple times with the same mode.
          for (var i = 0; i < 5; i++) {
            await AppThemeController.instance.setThemeMode(mode);
          }

          expect(
            AppThemeController.instance.themeMode,
            equals(mode),
            reason:
                'After 5 redundant calls with $mode, themeMode must still be $mode',
          );
          expect(
            prefs.getString('app_theme_mode'),
            isNull,
            reason:
                'After 5 redundant calls with $mode, SharedPreferences must not have been written',
          );
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // 3.5 Per-route theming: active theme is applied correctly on all screens
  // ---------------------------------------------------------------------------
  group('3.5 Per-route theming preservation', () {
    setUp(() async => _resetToLight());

    testWidgets(
      'PROPERTY: theme is applied correctly on a second route in dark mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.dark);

        Brightness? routeBrightness;

        await tester.pumpWidget(
          AnimatedBuilder(
            animation: AppThemeController.instance,
            builder: (context, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData.light(useMaterial3: true),
                darkTheme: ThemeData.dark(useMaterial3: true),
                themeMode: AppThemeController.instance.themeMode,
                routes: {
                  '/': (context) => const Scaffold(body: Text('Home')),
                  '/second': (context) => Builder(
                        builder: (context) {
                          routeBrightness = Theme.of(context).brightness;
                          return const Scaffold(body: Text('Second'));
                        },
                      ),
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to the second route.
        final NavigatorState navigator =
            tester.state(find.byType(Navigator));
        navigator.pushNamed('/second');
        await tester.pumpAndSettle();

        expect(
          routeBrightness,
          equals(Brightness.dark),
          reason:
              'After navigating to /second with dark mode active, '
              'the route must see Brightness.dark',
        );
      },
    );

    testWidgets(
      'PROPERTY: theme is applied correctly on a second route in light mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        await AppThemeController.instance.setThemeMode(ThemeMode.light);

        Brightness? routeBrightness;

        await tester.pumpWidget(
          AnimatedBuilder(
            animation: AppThemeController.instance,
            builder: (context, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData.light(useMaterial3: true),
                darkTheme: ThemeData.dark(useMaterial3: true),
                themeMode: AppThemeController.instance.themeMode,
                routes: {
                  '/': (context) => const Scaffold(body: Text('Home')),
                  '/second': (context) => Builder(
                        builder: (context) {
                          routeBrightness = Theme.of(context).brightness;
                          return const Scaffold(body: Text('Second'));
                        },
                      ),
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final NavigatorState navigator =
            tester.state(find.byType(Navigator));
        navigator.pushNamed('/second');
        await tester.pumpAndSettle();

        expect(
          routeBrightness,
          equals(Brightness.light),
          reason:
              'After navigating to /second with light mode active, '
              'the route must see Brightness.light',
        );
      },
    );

    // Property-based: for any ThemeMode, all routes see the correct brightness.
    testWidgets(
      'PROPERTY: any active ThemeMode is reflected correctly on all routes',
      (tester) async {
        final testCases = [
          (ThemeMode.dark, Brightness.dark),
          (ThemeMode.light, Brightness.light),
        ];

        for (final (mode, expectedBrightness) in testCases) {
          SharedPreferences.setMockInitialValues({});
          await AppThemeController.instance.setThemeMode(mode);

          Brightness? capturedBrightness;

          await tester.pumpWidget(
            AnimatedBuilder(
              animation: AppThemeController.instance,
              builder: (context, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData.light(useMaterial3: true),
                  darkTheme: ThemeData.dark(useMaterial3: true),
                  themeMode: AppThemeController.instance.themeMode,
                  routes: {
                    '/': (context) => const Scaffold(body: Text('Home')),
                    '/route-a': (context) => Builder(
                          builder: (context) {
                            capturedBrightness = Theme.of(context).brightness;
                            return const Scaffold(body: Text('Route A'));
                          },
                        ),
                  },
                );
              },
            ),
          );
          await tester.pumpAndSettle();

          final NavigatorState navigator =
              tester.state(find.byType(Navigator));
          navigator.pushNamed('/route-a');
          await tester.pumpAndSettle();

          expect(
            capturedBrightness,
            equals(expectedBrightness),
            reason: 'With $mode active, /route-a must see $expectedBrightness',
          );
        }
      },
    );
  });
}
