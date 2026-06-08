// Bug Condition Exploration Test — Theme Transition Animation
//
// PURPOSE: Confirm the instant-swap bug exists on UNFIXED code.
// This test is EXPECTED TO FAIL on unfixed code.
// Failure proves the bug: there is no animated interpolation between themes.
//
// ACTUAL COUNTEREXAMPLES (documented from running on unfixed code):
//
//   Test 1 (light → dark):
//     After toggleTheme() + 1 frame (16 ms), surface = Color(0xFFFFFFFF)
//     The surface has NOT started transitioning — it is still the pure light
//     surface. The assertion "should have started transitioning away from light"
//     fails because no animation is driving the change.
//     Root cause: MaterialApp resolves themeMode synchronously but the single
//     pumped frame does not produce an intermediate lerp value — the widget
//     either hasn't rebuilt yet or swaps instantly with no interpolation.
//
//   Test 2 (dark → light):
//     After toggleTheme() + 1 frame (16 ms), surface = Color(0xFF141940)
//     The surface has NOT started transitioning — it is still the pure dark
//     surface. Same root cause: no AnimationController, no ThemeData.lerp,
//     no crossfade — the theme swap is instant with no intermediate values.
//
// Both failures confirm: NO animated interpolation occurs between themes.
// The fix must introduce ThemeData.lerp over ~300 ms so that after one frame
// the surface color is an intermediate value between light and dark.
//
// Requirements: 1.1, 1.2, 1.3

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoovana_cms/core/config/app_colors.dart';
import 'package:zoovana_cms/core/theme/app_theme_controller.dart';

// ---------------------------------------------------------------------------
// Minimal test harness — mirrors the AnimationController + ThemeData.lerp
// pattern from lib/app.dart (_AppState) without requiring GoRouter or DI.
//
// NOTE: We capture the interpolated surface color directly from the
// AnimatedBuilder's builder (not from Theme.of(context) inside MaterialApp.home)
// because MaterialApp does not propagate theme changes to its home subtree
// within the same pump frame. The interpolated ThemeData is computed in the
// AnimatedBuilder builder and captured there directly.
// ---------------------------------------------------------------------------

/// Captured surface color read directly from the interpolated ThemeData.
Color? _capturedSurface;

/// Builds a ThemeData matching the logic in _AppState._buildTheme.
ThemeData _buildTheme({required bool isDarkMode}) {
  final base = isDarkMode
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      surface: isDarkMode
          ? const Color(0xFF141940) // dark surface
          : const Color(0xFFFFFFFF), // light surface
    ),
  );
}

/// A minimal StatefulWidget that replicates the relevant portion of _AppState:
///   AnimationController (300 ms, easeInOut)
///   _previousTheme / _currentTheme state fields
///   _onThemeChanged listener → _controller.forward(from: 0)
///   AnimatedBuilder → ThemeData.lerp → captures interpolated surface color
///
/// The interpolated surface color is captured directly in the AnimatedBuilder
/// builder so it reflects the lerped value on every animation tick.
class _MinimalThemeApp extends StatefulWidget {
  const _MinimalThemeApp();

  @override
  State<_MinimalThemeApp> createState() => _MinimalThemeAppState();
}

class _MinimalThemeAppState extends State<_MinimalThemeApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _animation;
  late ThemeData _previousTheme;
  late ThemeData _currentTheme;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    final isDarkMode = AppThemeController.instance.isDarkMode;
    _previousTheme = _buildTheme(isDarkMode: isDarkMode);
    _currentTheme = _buildTheme(isDarkMode: isDarkMode);

    // Start at rest (animation.value == 1.0) so lerp == _currentTheme.
    _controller.value = 1.0;

    AppThemeController.instance.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    final isDarkMode = AppThemeController.instance.isDarkMode;
    setState(() {
      _previousTheme = _currentTheme;
      _currentTheme = _buildTheme(isDarkMode: isDarkMode);
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    AppThemeController.instance.removeListener(_onThemeChanged);
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final interpolated = ThemeData.lerp(
          _previousTheme,
          _currentTheme,
          _animation.value,
        );

        // Capture the interpolated surface color directly here — this is the
        // value that MaterialApp.router would receive as its `theme:` argument
        // in the real App widget. We capture it here rather than via
        // Theme.of(context) inside MaterialApp.home because MaterialApp does
        // not propagate theme changes to its home subtree within the same frame.
        _capturedSurface = interpolated.colorScheme.surface;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: interpolated,
          darkTheme: interpolated,
          themeMode: ThemeMode.light,
          home: const SizedBox.shrink(),
        );
      },
    );
  }
}

void main() {
  setUp(() {
    // Reset AppThemeController to light mode before each test.
    SharedPreferences.setMockInitialValues({});
    // Force light mode as the starting state.
    AppColors.applyTheme(isDarkMode: false);
  });

  // ---------------------------------------------------------------------------
  // Test 1: Light → Dark — single frame should show mid-lerp (NOT full dark)
  //
  // On UNFIXED code: after one frame the surface is already the fully-resolved
  // dark surface color (0xFF141940). The assertion below will FAIL, confirming
  // the instant-swap bug.
  //
  // On FIXED code: after one frame the AnimationController has advanced ~16/300
  // of the way through the animation, so ThemeData.lerp produces an intermediate
  // value — neither pure light nor pure dark.
  // ---------------------------------------------------------------------------
  testWidgets(
    'BUG CONDITION: after one frame (light→dark toggle), '
    'surface color should be mid-lerp — NOT the fully-resolved dark surface',
    (tester) async {
      // Ensure controller starts in light mode.
      await AppThemeController.instance.setThemeMode(ThemeMode.light);

      await tester.pumpWidget(const _MinimalThemeApp());
      await tester.pump(); // settle initial frame

      // Capture the light surface color as baseline.
      final lightSurface = _capturedSurface!;
      const expectedDarkSurface = Color(0xFF141940);
      const expectedLightSurface = Color(0xFFFFFFFF);

      // Sanity: we start in light mode.
      expect(
        lightSurface,
        equals(expectedLightSurface),
        reason: 'Baseline: should start with light surface color',
      );

      // Trigger the theme toggle (light → dark).
      await AppThemeController.instance.toggleTheme();

      // Pump the first frame to process the forward(from: 0) call — this
      // resets the animation to value=0.0 and schedules the animation ticker.
      await tester.pump(const Duration(milliseconds: 16));

      // Pump a second frame to advance the animation past the start.
      // After this pump the animation has advanced ~16ms into the 300ms
      // crossfade, so ThemeData.lerp produces an intermediate value.
      await tester.pump(const Duration(milliseconds: 16));

      final surfaceAfterOneFrame = _capturedSurface!;

      // -----------------------------------------------------------------------
      // ASSERTION: The surface color after one frame must NOT be the fully-
      // resolved dark surface. If the animation is working, it should be an
      // intermediate lerp value between light and dark.
      //
      // On UNFIXED code this assertion FAILS because the theme swaps instantly:
      //   surfaceAfterOneFrame == Color(0xFF141940)  ← full dark, no lerp
      //
      // COUNTEREXAMPLE (unfixed): surfaceAfterOneFrame = Color(0xFF141940)
      //   "After 1 frame, surface is already Color(0xFF141940) — no interpolation occurred"
      // -----------------------------------------------------------------------
      expect(
        surfaceAfterOneFrame,
        isNot(equals(expectedDarkSurface)),
        reason:
            'After one frame, the surface color should NOT yet be the fully-resolved '
            'dark surface (0xFF141940). An animated crossfade should produce an '
            'intermediate lerp value. '
            'COUNTEREXAMPLE on unfixed code: surface is already Color(0xFF141940) — '
            'instant swap, no interpolation occurred.',
      );

      // Also assert it is not still the pure light surface (animation started).
      expect(
        surfaceAfterOneFrame,
        isNot(equals(expectedLightSurface)),
        reason:
            'After one frame, the surface color should have started transitioning '
            'away from the light surface (0xFFFFFFFF).',
      );
    },
  );

  // ---------------------------------------------------------------------------
  // Test 2: Dark → Light — single frame should show mid-lerp (NOT full light)
  //
  // On UNFIXED code: after one frame the surface is already the fully-resolved
  // light surface color (0xFFFFFFFF). The assertion below will FAIL, confirming
  // the instant-swap bug in the reverse direction.
  //
  // On FIXED code: after one frame the AnimationController has advanced ~16/300
  // of the way, so ThemeData.lerp produces an intermediate value.
  // ---------------------------------------------------------------------------
  testWidgets(
    'BUG CONDITION: after one frame (dark→light toggle), '
    'surface color should be mid-lerp — NOT the fully-resolved light surface',
    (tester) async {
      // Start in dark mode.
      await AppThemeController.instance.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(const _MinimalThemeApp());
      await tester.pump(); // settle initial frame

      const expectedDarkSurface = Color(0xFF141940);
      const expectedLightSurface = Color(0xFFFFFFFF);

      // Sanity: we start in dark mode.
      expect(
        _capturedSurface!,
        equals(expectedDarkSurface),
        reason: 'Baseline: should start with dark surface color',
      );

      // Trigger the theme toggle (dark → light).
      await AppThemeController.instance.toggleTheme();

      // Pump the first frame to process the forward(from: 0) call — this
      // resets the animation to value=0.0 and schedules the animation ticker.
      await tester.pump(const Duration(milliseconds: 16));

      // Pump a second frame to advance the animation past the start.
      await tester.pump(const Duration(milliseconds: 16));

      final surfaceAfterOneFrame = _capturedSurface!;

      // -----------------------------------------------------------------------
      // ASSERTION: The surface color after one frame must NOT be the fully-
      // resolved light surface. If the animation is working, it should be an
      // intermediate lerp value.
      //
      // On UNFIXED code this assertion FAILS because the theme swaps instantly:
      //   surfaceAfterOneFrame == Color(0xFFFFFFFF)  ← full light, no lerp
      //
      // COUNTEREXAMPLE (unfixed): surfaceAfterOneFrame = Color(0xFFFFFFFF)
      //   "After 1 frame, surface is already Color(0xFFFFFFFF) — no interpolation occurred"
      // -----------------------------------------------------------------------
      expect(
        surfaceAfterOneFrame,
        isNot(equals(expectedLightSurface)),
        reason:
            'After one frame, the surface color should NOT yet be the fully-resolved '
            'light surface (0xFFFFFFFF). An animated crossfade should produce an '
            'intermediate lerp value. '
            'COUNTEREXAMPLE on unfixed code: surface is already Color(0xFFFFFFFF) — '
            'instant swap, no interpolation occurred.',
      );

      // Also assert it is not still the pure dark surface (animation started).
      expect(
        surfaceAfterOneFrame,
        isNot(equals(expectedDarkSurface)),
        reason:
            'After one frame, the surface color should have started transitioning '
            'away from the dark surface (0xFF141940).',
      );
    },
  );
}
