# Bugfix Requirements Document

## Introduction

When the user taps the theme toggle button, the app switches between light and dark mode instantly with no visual transition. The abrupt change is jarring — colors, backgrounds, and text all flip in a single frame. The fix should introduce a smooth animated crossfade so the theme change feels polished and intentional.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the user triggers a theme toggle (e.g. taps the theme button) THEN the system switches all UI colors and surfaces to the new theme instantly in a single frame with no animation
1.2 WHEN the theme mode changes from light to dark THEN the system applies the new ThemeData immediately, causing a hard visual cut across the entire screen
1.3 WHEN the theme mode changes from dark to light THEN the system applies the new ThemeData immediately, causing a hard visual cut across the entire screen

### Expected Behavior (Correct)

2.1 WHEN the user triggers a theme toggle THEN the system SHALL animate the transition between the old and new theme over a perceptible duration (e.g. ~300 ms) so the change appears smooth
2.2 WHEN the theme mode changes from light to dark THEN the system SHALL crossfade or otherwise interpolate UI colors so no hard visual cut is visible
2.3 WHEN the theme mode changes from dark to light THEN the system SHALL crossfade or otherwise interpolate UI colors so no hard visual cut is visible

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the app launches and loads the persisted theme preference THEN the system SHALL CONTINUE TO apply the correct theme (light or dark) on startup without any animation
3.2 WHEN the user toggles the theme THEN the system SHALL CONTINUE TO persist the new theme mode to shared preferences so it survives app restarts
3.3 WHEN the theme is toggled THEN the system SHALL CONTINUE TO update the system UI overlay style (status bar icon brightness, navigation bar color) to match the active theme
3.4 WHEN the theme is already set to the requested mode THEN the system SHALL CONTINUE TO ignore the redundant call and make no changes
3.5 WHEN the app is navigating between routes THEN the system SHALL CONTINUE TO apply the active theme correctly on all screens regardless of when the toggle occurred
