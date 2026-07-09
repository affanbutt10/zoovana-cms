# Zoovana — config-driven role dashboard (Flutter)

This mirrors the HTML/JS preview: **one screen, one set of widgets, five
data configs** — never five separate screens.

## File map

```
lib/
  models/dashboard_models.dart     — RoleDashboardConfig + supporting data classes
  data/role_configs.dart           — the 5 role configs (owner/volunteer/shelter/shop/provider)
  widgets/activity_rings.dart      — Apple-Watch-style animated rings (CustomPainter)
  widgets/segmented_bar_chart.dart — Week/Month/Year control + animated bar chart
  widgets/upcoming_carousel.dart   — horizontal cards using CupertinoContextMenu for long-press peek
  widgets/speed_dial_fab.dart      — expandable "+" FAB with labeled mini actions
  screens/role_dashboard_screen.dart — assembles everything; takes a RoleDashboardConfig
  main.dart                        — demo app with a role switcher (replace with real auth/role logic)
```

## Instructions for the agent

1. **Copy `lib/` into the existing app**, merging folder-by-folder. If the
   project already has `models/`, `widgets/`, `screens/` directories, drop
   these files alongside the existing ones rather than replacing the
   directories wholesale.

2. **Replace the demo role switcher in `main.dart`.** In the real app, the
   active role should come from the authenticated user's account type, not
   a UI switcher. Something like:

   ```dart
   final config = roleConfigs[currentUser.accountType]!;
   return RoleDashboardScreen(config: config);
   ```

3. **Wire real data into `role_configs.dart`.** Every number in that file
   (ring percentages, chart datasets, card content) is currently static
   placeholder data mirroring the design preview. Replace the `const`
   configs with ones built from your API/state layer — e.g. a
   `RoleDashboardConfig.fromApiResponse(...)` factory, or a provider/riverpod
   selector that maps your existing models onto these fields.

4. **Hook up real actions:**
   - `RoleDashboardScreen._handleRefresh()` — call your actual refetch.
   - `UpcomingCarousel(onReschedule:, onCancel:)` — wire to your booking API.
   - `FabActionData.onTap` per role — wire to your existing "add pet",
     "book service", "log hours", etc. flows/routes.

5. **Keep this screen singular.** If a future role needs a section the
   others don't (e.g. Shelter's "capacity meter" vs Owner's plain widgets),
   prefer adding an optional field to `RoleDashboardConfig` (e.g.
   `Widget? extraSection`) over forking the screen — that's what keeps all
   five roles visually and behaviorally consistent for free.

6. **Fonts/theme:** this uses the Cupertino system font stack by default
   (renders as SF Pro on iOS). If the app already has a Material theme
   layered on top of Cupertino widgets (common in Flutter), make sure
   `CupertinoTheme` isn't being overridden by a conflicting `ThemeData`
   elsewhere, or these widgets will silently fall back to Roboto.

## What's native vs. custom

Deliberately built on top of Flutter/Cupertino's existing widgets instead of
reinventing them:
- `CupertinoSliverNavigationBar` → the large-title-collapses-to-small-title behavior
- `CupertinoSliverRefreshControl` → pull-to-refresh
- `CupertinoContextMenu` → long-press "peek" with blurred background + quick actions
- `CupertinoSlidingSegmentedControl` → the Week/Month/Year sliding-pill control

Custom-built (no Cupertino equivalent exists):
- `ActivityRings` (CustomPainter, staggered entrance animation)
- `SegmentedBarChart`'s animated bars
- `SpeedDialFab`
