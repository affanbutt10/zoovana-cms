import 'package:flutter/material.dart';

/// Premium color system for Zoovana CMS.
/// Blue-first palette matching the website branding.
///
/// v2 — same brand hues as before (primary is still exactly 0xFF3B82F6),
/// but with three additions that make the system feel more "dynamic" and
/// "premium" without inventing a single new color:
///
///   1. Tonal ramps generated from the existing base colors via HSL, instead
///      of hand-picked hex values — so depth/elevation scales stay perfectly
///      on-brand.
///   2. Interaction + elevation tokens (hover/press/focus/disabled, surface
///      elevation tint, colored shadows) derived by blending/opacity, the
///      same trick Material 3 uses for "surface tint" depth.
///   3. An optional `ThemeExtension<AppColorsScheme>` so theme changes can
///      be *animated* (AnimatedTheme cross-fade) instead of snapping
///      instantly — static mutable fields can't do that, they just mutate
///      in place and rely on you calling setState everywhere.
///
/// The old static API (`AppColors.primary`, `AppColors.applyTheme(...)`,
/// etc.) is fully preserved below, so nothing in your existing codebase
/// breaks. New capabilities are additive.
class AppColors {
  AppColors._();

  static bool isDarkMode = false;

  // ───────────────────────────────────────────────────────────────────────────
  // CORE BRAND COLORS (unchanged — Blue-first, matching website)
  // ───────────────────────────────────────────────────────────────────────────

  /// Primary: Royal Blue — Dominant website color (buttons, CTAs, headers)
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryDarker = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryLighter = Color(0xFF93C5FD);
  static const Color primaryGlow = Color(0xFFDBEAFE);

  /// Secondary: Deep Navy — Hero text, dark sections, authority
  static const Color secondary = Color(0xFF0B1E5B);
  static const Color secondaryDark = Color(0xFF081647);
  static const Color secondaryLight = Color(0xFF1E3A8A);

  /// Accent: Teal — Logo color, used sparingly for highlights
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentDark = Color(0xFF3DBDB5);
  static const Color accentLight = Color(0xFF7FE8E2);
  static const Color accentGlow = Color(0xFFE0F7F5);

  /// Highlight: Warm Amber — Badges, rewards, achievements
  static const Color highlight = Color(0xFFF5C842);
  static const Color highlightDark = Color(0xFFD4A72C);
  static const Color highlightLight = Color(0xFFFDE68A);

  /// Coral: Logo bug accent — alerts, important badges
  static const Color coral = Color(0xFFEF4444);
  static const Color coralLight = Color(0xFFFCA5A5);

  // ───────────────────────────────────────────────────────────────────────────
  // NEUTRAL SCALE (unchanged)
  // ───────────────────────────────────────────────────────────────────────────

  static const Color ink = Color(0xFF0F172A);
  static const Color inkLight = Color(0xFF1E293B);
  static const Color inkLighter = Color(0xFF334155);

  static const Color slate = Color(0xFF475569);
  static const Color slateLight = Color(0xFF64748B);
  static const Color slateLighter = Color(0xFF94A3B8);

  static const Color mist = Color(0xFFCBD5E1);
  static const Color mistLight = Color(0xFFE2E8F0);
  static const Color mistLighter = Color(0xFFF1F5F9);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ───────────────────────────────────────────────────────────────────────────
  // SEMANTIC COLORS (unchanged)
  // ───────────────────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  // ───────────────────────────────────────────────────────────────────────────
  // THEME-AWARE COLORS (unchanged — dynamic based on mode)
  // ───────────────────────────────────────────────────────────────────────────

  static Color background = const Color(0xFFFFFFFF);
  static Color backgroundAlt = const Color(0xFFF8FAFC);
  static Color backgroundTint = const Color(0xFFF0F7FF);
  static Color surface = const Color(0xFFFFFFFF);
  static Color surfaceElevated = const Color(0xFFFFFFFF);
  static Color surfaceVariant = const Color(0xFFF1F5F9);
  static Color surfaceGlass = const Color(0xCCFFFFFF);

  static Color textPrimary = const Color(0xFF0B1E5B);
  static Color textSecondary = const Color(0xFF475569);
  static Color textTertiary = const Color(0xFF94A3B8);
  static Color textDisabled = const Color(0xFFCBD5E1);
  static Color textOnPrimary = const Color(0xFFFFFFFF);
  static Color textOnSecondary = const Color(0xFFFFFFFF);

  static Color divider = const Color(0xFFE2E8F0);
  static Color dividerStrong = const Color(0xFFCBD5E1);
  static Color border = const Color(0xFFE2E8F0);
  static Color borderStrong = const Color(0xFFCBD5E1);

  static Color overlay = const Color(0x660B1E5B);
  static Color overlayStrong = const Color(0x990B1E5B);

  // ───────────────────────────────────────────────────────────────────────────
  // GLASSMORPHISM (unchanged)
  // ───────────────────────────────────────────────────────────────────────────

  static Color glassBackground = const Color(0xCCFFFFFF);
  static Color glassBorder = const Color(0xFFE2E8F0);
  static Color glassHighlight = const Color(0xFFFFFFFF);
  static Color glassShadow = const Color(0x1A000000);

  // ───────────────────────────────────────────────────────────────────────────
  // GRADIENTS (unchanged, existing ones)
  // ───────────────────────────────────────────────────────────────────────────

  static List<Color> get primaryGradient => isDarkMode
      ? [
          const Color(0xFF60A5FA),
          const Color(0xFF3B82F6),
          const Color(0xFF2563EB),
        ]
      : [
          const Color(0xFF60A5FA),
          const Color(0xFF3B82F6),
          const Color(0xFF2563EB),
        ];

  static List<Color> get primaryGradientSoft => isDarkMode
      ? [
          const Color(0xFF1E3A8A),
          const Color(0xFF1E40AF),
          const Color(0xFF2563EB),
        ]
      : [
          const Color(0xFFDBEAFE),
          const Color(0xFFBFDBFE),
          const Color(0xFF93C5FD),
        ];

  static List<Color> get secondaryGradient => isDarkMode
      ? [
          const Color(0xFF0F172A),
          const Color(0xFF0B1E5B),
          const Color(0xFF1E3A8A),
        ]
      : [
          const Color(0xFF1E3A8A),
          const Color(0xFF0B1E5B),
          const Color(0xFF081647),
        ];

  static List<Color> get heroGradient => isDarkMode
      ? [
          const Color(0xFF0A0E1A),
          const Color(0xFF0F1419),
          const Color(0xFF1A1F2E),
        ]
      : [
          const Color(0xFFFFFFFF),
          const Color(0xFFF0F7FF),
          const Color(0xFFDBEAFE),
        ];

  static const List<Color> heroGradientDark = [
    Color(0xFF0A0E1A),
    Color(0xFF0F1419),
    Color(0xFF1A1F2E),
  ];

  static List<Color> get splashGradient => isDarkMode
      ? [
          const Color(0xFF020617),
          const Color(0xFF0B1E5B),
          const Color(0xFF1E3A8A),
        ]
      : [
          const Color(0xFF020617),
          const Color(0xFF0B1E5B),
          const Color(0xFF1E3A8A),
        ];

  static List<Color> get cardGradient => isDarkMode
      ? [const Color(0xFF141824), const Color(0xFF1C2130)]
      : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)];

  static const List<Color> accentGradient = [
    Color(0xFF7FE8E2),
    Color(0xFF4ECDC4),
    Color(0xFF3DBDB5),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // ✨ NEW: PREMIUM GRADIENTS — built only from existing hues
  // ───────────────────────────────────────────────────────────────────────────

  /// Radial "glow" behind hero cards / feature callouts. Same primary hue,
  /// just faded to transparent — reads as premium ambient light, not a
  /// new color.
  static List<Color> get radialGlow => isDarkMode
      ? [primary.withValues(alpha: 0.28), primary.withValues(alpha: 0.0)]
      : [
          primaryGlow.withValues(alpha: 0.9),
          primaryGlow.withValues(alpha: 0.0),
        ];

  /// Subtle multi-stop "mesh" background — tonal ramp of primary rather
  /// than a hardcoded new palette. Use with a blur for a soft premium
  /// backdrop behind auth/onboarding screens.
  static List<Color> get meshGradient => [
    tonal(primary, isDarkMode ? 0.22 : 0.90),
    tonal(primary, isDarkMode ? 0.32 : 0.80),
    tonal(accent, isDarkMode ? 0.28 : 0.85),
  ];

  /// Skeleton / shimmer loading gradient — neutral, not brand-colored,
  /// so it doesn't compete with real content once it loads.
  static List<Color> get shimmerGradient => isDarkMode
      ? [surfaceVariant, surfaceVariant.withValues(alpha: 0.4), surfaceVariant]
      : [mistLighter, white, mistLighter];

  // ───────────────────────────────────────────────────────────────────────────
  // ✨ NEW: TONAL RAMP — generate tints/shades from ANY existing color
  // ───────────────────────────────────────────────────────────────────────────

  /// Returns [base] re-lit to a target lightness (0.0 = black, 1.0 = white)
  /// while preserving its hue and saturation. This is how the extra depth
  /// below is produced — no new hex values, just HSL math on your palette.
  static Color tonal(Color base, double lightness) {
    final hsl = HSLColor.fromColor(base);
    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }

  /// Full 50–950 tonal ramp of [primary], generated on demand. Handy for
  /// charts, progress rings, or anywhere you need "primary, but a shade
  /// lighter/darker" without picking a new arbitrary hex.
  static Map<int, Color> get primaryRamp => {
    50: tonal(primary, 0.96),
    100: tonal(primary, 0.91),
    200: tonal(primary, 0.83),
    300: tonal(primary, 0.74), // ≈ primaryLighter
    400: tonal(primary, 0.66), // ≈ primaryLight
    500: primary, // base — untouched
    600: tonal(primary, 0.50), // ≈ primaryDark
    700: tonal(primary, 0.42), // ≈ primaryDarker
    800: tonal(primary, 0.34),
    900: tonal(primary, 0.26),
    950: tonal(primary, 0.16),
  };

  // ───────────────────────────────────────────────────────────────────────────
  // ✨ NEW: INTERACTION STATES — hover / press / focus / disabled
  // ───────────────────────────────────────────────────────────────────────────

  /// Standard blend factor for interaction feedback, tuned per state.
  /// All derived from [primary] by opacity/lightness blend, never a new hue.
  static Color get primaryHover =>
      isDarkMode ? tonal(primary, 0.66) : tonal(primary, 0.42);

  static Color get primaryPressed =>
      isDarkMode ? tonal(primary, 0.34) : tonal(primary, 0.34);

  /// A soft ring/halo color for focus states (e.g. TextField focus border).
  static Color get primaryFocusRing => primary.withValues(alpha: 0.35);

  static Color get primaryDisabled =>
      blend(primary, isDarkMode ? black : white, isDarkMode ? 0.35 : 0.45);

  // ───────────────────────────────────────────────────────────────────────────
  // ✨ NEW: ELEVATION SYSTEM — Material-3-style surface tint, on-brand
  // ───────────────────────────────────────────────────────────────────────────

  /// Overlay opacity per elevation level, applied as a [primary] tint over
  /// the base [surface] color — this is what gives cards a sense of "lift"
  /// without resorting to plain grey shadows.
  static const List<double> _elevationOverlayOpacity = [
    0.0, // level 0 — flush with background
    0.05, // level 1 — resting card
    0.08, // level 2 — hovered card
    0.11, // level 3 — dropdown / menu
    0.12, // level 4 — dialog
    0.14, // level 5 — modal / bottom sheet
  ];

  /// Surface color at a given elevation (0–5), tinted with primary the
  /// way Material 3 does it — reads as premium depth using only your
  /// existing brand blue.
  static Color surfaceAtElevation(int level) {
    final clamped = level.clamp(0, _elevationOverlayOpacity.length - 1);
    return blend(primary, surface, _elevationOverlayOpacity[clamped]);
  }

  /// Colored ("glow") shadow for primary buttons/cards — subtle blue
  /// shadow instead of flat black, a common premium-UI signature.
  static Color get primaryShadow => primary.withValues(alpha: 0.25);
  static Color get primaryShadowStrong => primary.withValues(alpha: 0.40);

  static List<BoxShadow> premiumShadow({double elevation = 1}) => [
    BoxShadow(
      color: primaryShadow,
      blurRadius: 16 * elevation,
      offset: Offset(0, 6 * elevation),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: (isDarkMode ? black : ink).withValues(alpha: 0.06),
      blurRadius: 4 * elevation,
      offset: Offset(0, 1 * elevation),
    ),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // PRODUCT STATUS (unchanged)
  // ───────────────────────────────────────────────────────────────────────────

  static const Color statusActive = Color(0xFF3B82F6);
  static const Color statusInactive = Color(0xFFEF4444);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusDraft = Color(0xFF94A3B8);
  static const Color statusArchived = Color(0xFFCBD5E1);

  // ───────────────────────────────────────────────────────────────────────────
  // CHART & DATA VISUALIZATION (unchanged)
  // ───────────────────────────────────────────────────────────────────────────

  static const List<Color> chartPalette = [
    Color(0xFF3B82F6),
    Color(0xFF0B1E5B),
    Color(0xFF4ECDC4),
    Color(0xFFF5C842),
    Color(0xFFEF4444),
    Color(0xFF10B981),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // THEME APPLICATION (unchanged behavior, same as before)
  // ───────────────────────────────────────────────────────────────────────────

  static void applyTheme({required bool isDarkMode}) {
    AppColors.isDarkMode = isDarkMode;

    if (isDarkMode) {
      background = const Color(0xFF0A0E1A);
      backgroundAlt = const Color(0xFF0F1419);
      backgroundTint = const Color(0xFF1A1F2E);
      surface = const Color(0xFF141824);
      surfaceElevated = const Color(0xFF1C2130);
      surfaceVariant = const Color(0xFF1E2433);
      surfaceGlass = const Color(0x26FFFFFF);

      textPrimary = const Color(0xFFF1F5F9);
      textSecondary = const Color(0xFFCBD5E1);
      textTertiary = const Color(0xFF94A3B8);
      textDisabled = const Color(0xFF64748B);
      textOnPrimary = const Color(0xFFFFFFFF);
      textOnSecondary = const Color(0xFFFFFFFF);

      divider = const Color(0xFF1E293B);
      dividerStrong = const Color(0xFF334155);
      border = const Color(0xFF1E293B);
      borderStrong = const Color(0xFF334155);

      overlay = const Color(0x99000000);
      overlayStrong = const Color(0xCC000000);

      glassBackground = const Color(0x1AFFFFFF);
      glassBorder = const Color(0x40FFFFFF);
      glassHighlight = const Color(0x0DFFFFFF);
      glassShadow = const Color(0x66000000);
    } else {
      background = const Color(0xFFFFFFFF);
      backgroundAlt = const Color(0xFFF8FAFC);
      backgroundTint = const Color(0xFFF0F7FF);
      surface = const Color(0xFFFFFFFF);
      surfaceElevated = const Color(0xFFFFFFFF);
      surfaceVariant = const Color(0xFFF1F5F9);
      surfaceGlass = const Color(0xCCFFFFFF);

      textPrimary = const Color(0xFF0B1E5B);
      textSecondary = const Color(0xFF475569);
      textTertiary = const Color(0xFF94A3B8);
      textDisabled = const Color(0xFFCBD5E1);
      textOnPrimary = const Color(0xFFFFFFFF);
      textOnSecondary = const Color(0xFFFFFFFF);

      divider = const Color(0xFFE2E8F0);
      dividerStrong = const Color(0xFFCBD5E1);
      border = const Color(0xFFE2E8F0);
      borderStrong = const Color(0xFFCBD5E1);

      overlay = const Color(0x660B1E5B);
      overlayStrong = const Color(0x990B1E5B);

      glassBackground = const Color(0xCCFFFFFF);
      glassBorder = const Color(0xFFE2E8F0);
      glassHighlight = const Color(0xFFFFFFFF);
      glassShadow = const Color(0x1A000000);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UTILITY METHODS (unchanged)
  // ───────────────────────────────────────────────────────────────────────────

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color blend(Color foreground, Color background, double factor) {
    return Color.lerp(background, foreground, factor)!;
  }
}

// ═════════════════════════════════════════════════════════════════════════
// ✨ NEW (optional): ThemeExtension for real, ANIMATED theme switching.
//
// Your current `applyTheme()` mutates static fields in place — it works,
// but Flutter has no way to know something changed except a manual
// setState/rebuild, and it can never animate the transition (colors just
// snap). Wrapping the same tokens in a ThemeExtension lets you drop this
// into `ThemeData(extensions: [...])` and get a smooth cross-fade for
// free via `AnimatedTheme` / `ThemeData.lerp`, with zero new colors —
// it just re-packages the same light/dark values above.
//
// This is fully optional and additive: keep using `AppColors.xxx` exactly
// as you do today, and adopt `context.colors` gradually wherever a screen
// would benefit from animated theme transitions (e.g. a dark-mode toggle).
// ═════════════════════════════════════════════════════════════════════════

@immutable
class AppColorsScheme extends ThemeExtension<AppColorsScheme> {
  const AppColorsScheme({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.glassBackground,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color glassBackground;

  static const light = AppColorsScheme(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0B1E5B),
    textSecondary: Color(0xFF475569),
    border: Color(0xFFE2E8F0),
    glassBackground: Color(0xCCFFFFFF),
  );

  static const dark = AppColorsScheme(
    background: Color(0xFF0A0E1A),
    surface: Color(0xFF141824),
    surfaceElevated: Color(0xFF1C2130),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    border: Color(0xFF1E293B),
    glassBackground: Color(0x1AFFFFFF),
  );

  @override
  AppColorsScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? glassBackground,
  }) {
    return AppColorsScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      glassBackground: glassBackground ?? this.glassBackground,
    );
  }

  @override
  AppColorsScheme lerp(ThemeExtension<AppColorsScheme>? other, double t) {
    if (other is! AppColorsScheme) return this;
    return AppColorsScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
    );
  }
}

/// Convenience accessor: `context.colors.textPrimary`
extension AppColorsContext on BuildContext {
  AppColorsScheme get colors =>
      Theme.of(this).extension<AppColorsScheme>() ?? AppColorsScheme.light;
}
