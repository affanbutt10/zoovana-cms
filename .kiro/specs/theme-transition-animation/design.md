# Theme Transition Animation Bugfix Design

## Overview

When the user taps the theme toggle button, `AppThemeController.setThemeMode` calls
`notifyListeners()`, which causes the `AnimatedBuilder` in `lib/app.dart` to rebuild
`MaterialApp.router` synchronously with the new `ThemeMode`. Flutter applies the new
`ThemeData` in the same frame — no interpolation, no crossfade, just a hard visual cut.

The fix wraps the `MaterialApp.router` subtree in an `AnimatedTheme`-style overlay so
that the transition between the old and new theme is crossfaded over ~300 ms. The
approach uses Flutter's built-in `AnimatedTheme` widget (or an equivalent
`AnimationController` + `ThemeData.lerp` strategy) so that no third-party dependency
is introduced and the existing `AppThemeController` / `AnimatedBuilder` wiring is
preserved.

---

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug — `AppThemeController.setThemeMode` is called with a mode different from the current mode, causing `notifyListeners()` to fire and `MaterialApp.router` to rebuild with the new `ThemeData` in a single frame.
- **Property (P)**: The desired behavior when the bug condition holds — the UI SHALL crossfade between the old and new theme over ~300 ms so no hard visual cut is visible.
- **Preservation**: All behaviors that must remain unchanged by the fix — startup theme loading, persistence to shared preferences, system UI overlay updates, redundant-call guard, and per-route theme correctness.
- **AppThemeController**: The `ChangeNotifier` singleton in `lib/core/theme/app_theme_controller.dart` that owns `ThemeMode` state and persists it via `SharedPreferences`.
- **AnimatedBuilder**: The widget in `lib/app.dart` that listens to `AppThemeController.instance` and rebuilds `MaterialApp.router` on every notification.
- **themeMode**: The `ThemeMode` property passed directly to `MaterialApp.router`; changing it causes Flutter to swap `ThemeData` synchronously.
- **AnimatedTheme**: A Flutter built-in widget that interpolates between two `ThemeData` values using `ThemeData.lerp`, producing a smooth visual transition.

---

## Bug Details

### Bug Condition

The bug manifests when `AppThemeController.setThemeMode` is called with a mode that
differs from the current mode. The `AnimatedBuilder` rebuilds `MaterialApp.router`
synchronously, passing the new `ThemeMode` directly. Flutter resolves the active
`ThemeData` in the same frame with no interpolation.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type ThemeModeChangeEvent
         { previousMode: ThemeMode, nextMode: ThemeMode, triggeredBy: 'user_tap' | 'programmatic' }
  OUTPUT: boolean

  RETURN input.previousMode != input.nextMode
         AND MaterialApp.router receives new themeMode in same frame as notifyListeners()
         AND NO animated interpolation is applied between old ThemeData and new ThemeData
END FUNCTION
```

### Examples

- **Light → Dark (user tap)**: User taps the theme toggle. All backgrounds, text, and
  surfaces flip from light to dark in a single frame. Expected: a ~300 ms crossfade.
- **Dark → Light (user tap)**: User taps the theme toggle again. All surfaces flip from
  dark to light in a single frame. Expected: a ~300 ms crossfade.
- **Programmatic toggle**: `AppThemeController.instance.setThemeMode(ThemeMode.dark)` is
  called from code. Same instant-flip behavior. Expected: same ~300 ms crossfade.
- **Redundant call (edge case)**: `setThemeMode` is called with the current mode. The
  early-return guard fires; no rebuild occurs. Expected: no animation, no change — this
  is correct behavior and must be preserved.

---

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- On app launch, the persisted theme preference (light or dark) is applied immediately
  with no animation (3.1).
- After every toggle, the new `ThemeMode` is persisted to `SharedPreferences` so it
  survives app restarts (3.2).
- After every toggle, `SystemChrome.setSystemUIOverlayStyle` is called with the correct
  brightness values for the new theme (3.3).
- When `setThemeMode` is called with the already-active mode, the call is a no-op and
  no rebuild or animation is triggered (3.4).
- All screens rendered via GoRouter continue to display the active theme correctly
  regardless of when the toggle occurred (3.5).

**Scope:**
All inputs that do NOT involve a `ThemeMode` change (i.e., `isBugCondition` returns
false) must be completely unaffected by this fix. This includes:
- App startup / initial theme load
- Navigation between routes
- Any UI interaction that does not call `setThemeMode` with a different mode
- System UI overlay style updates (these must still fire on every toggle)

---

## Hypothesized Root Cause

Based on reading `lib/app.dart` and `lib/core/theme/app_theme_controller.dart`:

1. **Synchronous `themeMode` swap in `MaterialApp.router`**: The `AnimatedBuilder`
   rebuilds `MaterialApp.router` with the new `themeMode` in the same frame that
   `notifyListeners()` fires. Flutter's `MaterialApp` resolves `theme` vs `darkTheme`
   immediately — there is no built-in interpolation at the `MaterialApp` level.

2. **No `AnimatedTheme` wrapper**: The widget tree contains no `AnimatedTheme` (or
   equivalent `AnimationController` + `ThemeData.lerp`) between `MaterialApp.router`
   and the rest of the UI. Without it, every descendant widget receives the new
   `ThemeData` in a single frame.

3. **`_buildTheme` returns static `ThemeData`**: The helper always returns a fully
   resolved `ThemeData` for either light or dark; there is no intermediate lerp value
   being produced during the transition.

4. **`AnimatedBuilder` is the correct listener but the wrong animator**: Using
   `AnimatedBuilder` to listen to a `ChangeNotifier` is idiomatic, but it only
   rebuilds — it does not drive an animation curve between two states.

---

## Correctness Properties

Property 1: Bug Condition - Theme Toggle Triggers Animated Crossfade

_For any_ `ThemeModeChangeEvent` where `isBugCondition` returns true (i.e., the user or
code requests a mode different from the current mode), the fixed `App` widget SHALL
animate the transition between the old `ThemeData` and the new `ThemeData` over
approximately 300 ms using a smooth interpolation curve, so that no hard visual cut is
visible to the user.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Preservation - Non-Toggle Behavior Unchanged

_For any_ input where `isBugCondition` returns false (app startup, redundant toggle
call, route navigation, system UI updates), the fixed code SHALL produce exactly the
same observable behavior as the original code — correct theme on startup, persistence
after toggle, system overlay updates, no-op on redundant calls, and correct per-route
theming.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

---

## Fix Implementation

### Changes Required

Assuming the root cause analysis is correct (synchronous `themeMode` swap with no
interpolation layer):

**File**: `lib/app.dart`

**Function**: `App.build` → `AnimatedBuilder.builder`

**Specific Changes**:

1. **Introduce an animation state holder**: Convert `App` from `StatelessWidget` to
   `StatefulWidget` (or extract a dedicated `_AppThemeAnimator` `StatefulWidget`) so
   that an `AnimationController` and a `CurvedAnimation` can be owned and disposed
   properly.

2. **Add `AnimationController` for the crossfade**: Create an `AnimationController`
   with `duration: const Duration(milliseconds: 300)` and attach it to the widget's
   `TickerProvider` (via `SingleTickerProviderStateMixin`).

3. **Track previous and next `ThemeData`**: Store `_previousTheme` and `_currentTheme`
   as state fields. When `AppThemeController` notifies, capture the outgoing
   `ThemeData` as `_previousTheme`, update `_currentTheme`, and call
   `_controller.forward(from: 0)` to start the animation.

4. **Interpolate with `ThemeData.lerp`**: In the `AnimatedBuilder` builder, compute:
   ```dart
   final interpolated = ThemeData.lerp(
     _previousTheme,
     _currentTheme,
     _animation.value,   // CurvedAnimation over the controller
   );
   ```
   Pass `interpolated` as both `theme` and `darkTheme` to `MaterialApp.router`, and
   set `themeMode: ThemeMode.light` (so Flutter always uses the `theme` slot, which
   already holds the lerped value).

5. **Preserve system UI overlay call**: Keep the existing
   `SystemChrome.setSystemUIOverlayStyle` call; it should fire based on the
   `AppThemeController.instance.isDarkMode` value (the target mode), not the
   interpolated value, so the status bar updates at the start of the animation rather
   than lagging behind.

6. **No changes to `AppThemeController`**: The controller's public API, persistence
   logic, and `notifyListeners` call remain untouched.

---

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that
demonstrate the bug on unfixed code, then verify the fix works correctly and preserves
existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the instant theme swap BEFORE
implementing the fix. Confirm or refute the root cause analysis.

**Test Plan**: Write widget tests that call `AppThemeController.instance.toggleTheme()`
and then pump a single frame. Assert that the `ThemeData` visible to a descendant
widget is NOT yet the fully-resolved new theme (i.e., an intermediate lerp value is
expected). On unfixed code these assertions will fail, confirming the root cause.

**Test Cases**:
1. **Single-frame check (Light → Dark)**: After `toggleTheme()`, pump one frame and
   assert that `Theme.of(context).brightness` is neither fully `Brightness.light` nor
   fully `Brightness.dark` — an intermediate lerp is expected. (Will fail on unfixed
   code.)
2. **Single-frame check (Dark → Light)**: Same as above in the reverse direction.
   (Will fail on unfixed code.)
3. **Full animation completion**: After `toggleTheme()`, pump the full 300 ms and
   assert that `Theme.of(context).brightness == Brightness.dark`. (Should pass on
   both fixed and unfixed code, confirming the end state is correct.)
4. **Redundant call (edge case)**: Call `setThemeMode` with the current mode, pump
   frames, and assert no animation controller tick occurs. (May pass on unfixed code
   due to the early-return guard.)

**Expected Counterexamples**:
- After a single frame, the descendant widget already sees the fully-resolved new
  `ThemeData` (no lerp in progress).
- Possible causes: no `AnimationController`, no `ThemeData.lerp` call, `themeMode`
  swap applied synchronously.

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed widget
produces an animated transition.

**Pseudocode:**
```
FOR ALL event WHERE isBugCondition(event) DO
  result := pumpSingleFrameAfterToggle(app_fixed)
  ASSERT themeDataSeenByDescendant(result).isMidLerp == true
  
  result := pumpFullDuration(app_fixed, 300ms)
  ASSERT themeDataSeenByDescendant(result) == expectedFinalTheme(event.nextMode)
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed
code produces the same observable behavior as the original code.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT behavior_original(input) == behavior_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking
because:
- It generates many combinations of app state and input automatically.
- It catches edge cases (e.g., rapid successive toggles, navigation mid-animation)
  that manual unit tests might miss.
- It provides strong guarantees that non-toggle behavior is unchanged across the full
  input domain.

**Test Plan**: Observe behavior on UNFIXED code first for startup, persistence, and
system UI updates, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Startup theme preservation**: Verify that on cold start with a persisted `'dark'`
   preference, the app renders with `Brightness.dark` immediately (no animation delay).
2. **Persistence preservation**: After `toggleTheme()`, verify that
   `SharedPreferences` contains the new mode string (`'dark'` or `'light'`).
3. **System UI overlay preservation**: After `toggleTheme()`, verify that
   `SystemChrome.setSystemUIOverlayStyle` was called with the correct
   `statusBarIconBrightness` for the new mode.
4. **Redundant-call no-op preservation**: Call `setThemeMode(currentMode)` and verify
   no `AnimationController.forward` is triggered and no rebuild occurs.
5. **Per-route theme preservation**: Navigate to a non-root route, toggle the theme,
   and verify the route still displays the correct (animated) theme.

### Unit Tests

- Test that `AppThemeController.setThemeMode` with a new mode fires `notifyListeners`
  exactly once and updates `themeMode` and `isDarkMode` correctly.
- Test that `AppThemeController.setThemeMode` with the current mode is a no-op (no
  `notifyListeners`, no `SharedPreferences` write).
- Test that `_buildTheme(isDarkMode: false)` and `_buildTheme(isDarkMode: true)` return
  `ThemeData` with the expected `brightness` values.
- Test that `ThemeData.lerp(lightTheme, darkTheme, 0.5)` produces a mid-point theme
  (sanity check for the lerp approach).

### Property-Based Tests

- Generate random sequences of `toggleTheme()` calls and verify that after each
  sequence completes (all animations settled), the final `ThemeMode` matches the
  expected parity (even number of toggles → original mode, odd → opposite mode).
- Generate random `ThemeMode` values and verify that `setThemeMode` always leaves
  `AppThemeController.themeMode` equal to the last non-redundant call.
- Generate random non-toggle inputs (navigation events, widget rebuilds) and verify
  that the active `ThemeData` seen by descendant widgets is unchanged.

### Integration Tests

- Full toggle flow: launch app in light mode, tap theme toggle, verify crossfade
  animation plays for ~300 ms, verify final state is dark mode.
- Rapid toggle: tap theme toggle three times in quick succession, verify the animation
  handles interruption gracefully and the final state is correct.
- Navigation mid-animation: start a theme toggle, immediately navigate to a new route,
  verify the new route renders with the correct final theme after the animation
  completes.
- Cold-start persistence: toggle to dark, restart the app, verify dark theme is applied
  immediately on startup with no animation.
