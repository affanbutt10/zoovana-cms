# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Instant Theme Swap (No Crossfade)
  - **CRITICAL**: This test MUST FAIL on unfixed code — failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior — it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the instant theme swap
  - **Scoped PBT Approach**: Scope the property to the concrete failing cases — light→dark and dark→light user-triggered toggles — to ensure reproducibility
  - Write a widget test that calls `AppThemeController.instance.toggleTheme()` and pumps a single frame
  - Assert that the `ThemeData` seen by a descendant widget is NOT yet the fully-resolved new theme (i.e., an intermediate lerp value is expected mid-animation)
  - Specifically: after one frame, `Theme.of(context).brightness` should be neither fully `Brightness.light` nor fully `Brightness.dark`
  - Run test on UNFIXED code — the descendant will already see the fully-resolved new `ThemeData` in frame 1 (no lerp in progress)
  - **EXPECTED OUTCOME**: Test FAILS (this is correct — it proves the instant-swap bug exists)
  - Document counterexamples found (e.g., "After 1 frame, brightness is already `Brightness.dark` — no interpolation occurred")
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Toggle Behavior Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for all non-toggle inputs (startup, persistence, system UI, redundant calls, navigation)
  - Observe: on cold start with persisted `'dark'` preference, app renders with `Brightness.dark` immediately (no animation)
  - Observe: after `toggleTheme()`, `SharedPreferences` contains the updated mode string (`'dark'` or `'light'`)
  - Observe: after `toggleTheme()`, `SystemChrome.setSystemUIOverlayStyle` is called with correct `statusBarIconBrightness`
  - Observe: calling `setThemeMode(currentMode)` is a no-op — no rebuild, no animation, no `SharedPreferences` write
  - Observe: navigating between routes renders the active theme correctly on all screens
  - Write property-based tests capturing these observed behaviors:
    - Generate random sequences of non-toggle inputs and assert theme state is unchanged
    - Generate random `ThemeMode` values for `setThemeMode` and assert the last non-redundant call wins
    - Assert startup theme load applies the persisted mode immediately with no animation delay
  - Verify all tests PASS on UNFIXED code (confirms baseline behavior to preserve)
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. Fix instant theme swap — add animated crossfade to `App` widget

  - [x] 3.1 Convert `App` from `StatelessWidget` to `StatefulWidget` with animation state
    - Convert `App` to `StatefulWidget` (or extract `_AppThemeAnimator` `StatefulWidget`)
    - Add `SingleTickerProviderStateMixin` to the `State` class
    - Declare `late AnimationController _controller` with `duration: const Duration(milliseconds: 300)`
    - Declare `late CurvedAnimation _animation` wrapping `_controller` with `Curves.easeInOut`
    - Declare `late ThemeData _previousTheme` and `late ThemeData _currentTheme` state fields
    - Initialize both theme fields from `_buildTheme` in `initState` using the current `AppThemeController.instance.isDarkMode`
    - Dispose `_controller` and `_animation` in `dispose`
    - _Bug_Condition: isBugCondition(event) where event.previousMode != event.nextMode AND MaterialApp.router receives new themeMode in same frame_
    - _Expected_Behavior: UI crossfades between old and new ThemeData over ~300 ms; no hard visual cut visible_
    - _Preservation: Startup theme load, SharedPreferences persistence, SystemChrome overlay updates, redundant-call no-op, per-route theme correctness all remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 3.2 Wire `AppThemeController` notifications to the animation
    - In the `AnimatedBuilder` (or a `ListenableBuilder`) callback, detect when `AppThemeController.instance.themeMode` has changed
    - On change: capture the outgoing `_currentTheme` as `_previousTheme`, compute the new `_currentTheme` via `_buildTheme`, then call `_controller.forward(from: 0)` to start the crossfade
    - Keep the existing `SystemChrome.setSystemUIOverlayStyle` call firing based on `AppThemeController.instance.isDarkMode` (target mode, not interpolated value) so the status bar updates at animation start
    - _Bug_Condition: isBugCondition(event) where event.previousMode != event.nextMode_
    - _Expected_Behavior: _controller.forward(from: 0) drives ThemeData.lerp from _previousTheme to _currentTheme over 300 ms_
    - _Preservation: SystemChrome call still fires on every toggle (3.3); redundant-call guard in AppThemeController prevents spurious notifications (3.4)_
    - _Requirements: 2.1, 2.2, 2.3, 3.3, 3.4_

  - [x] 3.3 Interpolate `ThemeData` with `ThemeData.lerp` and pass to `MaterialApp.router`
    - In the `AnimatedBuilder` builder, compute: `final interpolated = ThemeData.lerp(_previousTheme, _currentTheme, _animation.value)`
    - Pass `interpolated` as both `theme:` and `darkTheme:` to `MaterialApp.router`
    - Set `themeMode: ThemeMode.light` on `MaterialApp.router` so Flutter always uses the `theme` slot (which holds the lerped value)
    - Make no changes to `AppThemeController` — its public API, persistence logic, and `notifyListeners` call remain untouched
    - _Bug_Condition: isBugCondition(event) where no animated interpolation is applied between old and new ThemeData_
    - _Expected_Behavior: ThemeData.lerp produces intermediate values during the 300 ms animation; descendants see a smooth crossfade_
    - _Preservation: _buildTheme helper unchanged; AppThemeController unchanged; startup applies theme immediately (animation.value = 1.0 at rest) (3.1)_
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.5_

  - [x] 3.4 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Animated Crossfade on Theme Toggle
    - **IMPORTANT**: Re-run the SAME test from task 1 — do NOT write a new test
    - The test from task 1 encodes the expected behavior (mid-lerp value after one frame)
    - When this test passes, it confirms the animated crossfade is working
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed — intermediate lerp value is visible after one frame)
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 3.5 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Toggle Behavior Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 — do NOT write new tests
    - Run all preservation property tests from step 2
    - **EXPECTED OUTCOME**: All tests PASS (confirms no regressions in startup, persistence, system UI, redundant-call no-op, and per-route theming)
    - Confirm all preservation tests still pass after fix (no regressions)

- [x] 4. Checkpoint — Ensure all tests pass
  - Run the full test suite and confirm every test passes
  - Verify the bug condition exploration test (task 1) now passes — animated crossfade confirmed
  - Verify all preservation tests (task 2) still pass — no regressions
  - Ensure all tests pass; ask the user if any questions arise
