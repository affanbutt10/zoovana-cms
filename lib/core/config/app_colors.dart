import 'package:flutter/material.dart';

/// Premium color system for Zoovana CMS.
/// Blue-first palette matching the website branding.
class AppColors {
  AppColors._();

  static bool isDarkMode = false;

  // ───────────────────────────────────────────────────────────────────────────
  // CORE BRAND COLORS (Blue-first, matching website)
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
  // NEUTRAL SCALE (Cool undertones to match blue theme)
  // ───────────────────────────────────────────────────────────────────────────

  /// Ink: Deep blue-black — primary text on light
  static const Color ink = Color(0xFF0F172A);
  static const Color inkLight = Color(0xFF1E293B);
  static const Color inkLighter = Color(0xFF334155);

  /// Slate: Cool grey-blue text and borders
  static const Color slate = Color(0xFF475569);
  static const Color slateLight = Color(0xFF64748B);
  static const Color slateLighter = Color(0xFF94A3B8);

  /// Mist: Cool subtle backgrounds
  static const Color mist = Color(0xFFCBD5E1);
  static const Color mistLight = Color(0xFFE2E8F0);
  static const Color mistLighter = Color(0xFFF1F5F9);

  /// Pure neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ───────────────────────────────────────────────────────────────────────────
  // SEMANTIC COLORS
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
  // THEME-AWARE COLORS (Dynamic based on mode)
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
  // GLASSMORPHISM
  // ───────────────────────────────────────────────────────────────────────────

  static Color glassBackground = const Color(0xCCFFFFFF);
  static Color glassBorder = const Color(0xFFE2E8F0);
  static Color glassHighlight = const Color(0xFFFFFFFF);
  static Color glassShadow = const Color(0x1A000000);

  // ───────────────────────────────────────────────────────────────────────────
  // GRADIENTS (Rich, multi-stop for depth)
  // ───────────────────────────────────────────────────────────────────────────

  /// Primary blue gradient — buttons, active states
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

  /// Soft blue gradient — backgrounds, cards
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

  /// Navy gradient — dark sections, splash screen
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

  /// Hero gradient — adaptive backgrounds
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

  /// Hero gradient — dark mode (legacy support)
  static const List<Color> heroGradientDark = [
    Color(0xFF0A0E1A),
    Color(0xFF0F1419),
    Color(0xFF1A1F2E),
  ];

  /// Splash gradient — cinematic dark blue
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

  /// Card gradient — subtle elevation
  static List<Color> get cardGradient => isDarkMode
      ? [
          const Color(0xFF141824),
          const Color(0xFF1C2130),
        ]
      : [
          const Color(0xFFFFFFFF),
          const Color(0xFFF8FAFC),
        ];

  /// Premium glow — teal accent for special elements
  static const List<Color> accentGradient = [
    Color(0xFF7FE8E2),
    Color(0xFF4ECDC4),
    Color(0xFF3DBDB5),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // PRODUCT STATUS (CMS-specific)
  // ───────────────────────────────────────────────────────────────────────────

  static const Color statusActive = Color(0xFF3B82F6);
  static const Color statusInactive = Color(0xFFEF4444);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusDraft = Color(0xFF94A3B8);
  static const Color statusArchived = Color(0xFFCBD5E1);

  // ───────────────────────────────────────────────────────────────────────────
  // CHART & DATA VISUALIZATION
  // ───────────────────────────────────────────────────────────────────────────

  static const List<Color> chartPalette = [
    Color(0xFF3B82F6), // Royal Blue
    Color(0xFF0B1E5B), // Deep Navy
    Color(0xFF4ECDC4), // Teal
    Color(0xFFF5C842), // Amber
    Color(0xFFEF4444), // Coral
    Color(0xFF10B981), // Emerald
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // THEME APPLICATION
  // ───────────────────────────────────────────────────────────────────────────

  static void applyTheme({required bool isDarkMode}) {
    AppColors.isDarkMode = isDarkMode;

    if (isDarkMode) {
      // Dark mode: Premium deep navy with rich contrast
      background = const Color(0xFF0A0E1A);           // Deeper, richer black-navy
      backgroundAlt = const Color(0xFF0F1419);        // Slightly lighter for cards
      backgroundTint = const Color(0xFF1A1F2E);       // Subtle blue tint
      surface = const Color(0xFF141824);              // Card surface
      surfaceElevated = const Color(0xFF1C2130);      // Elevated cards
      surfaceVariant = const Color(0xFF1E2433);       // Input fields, variants
      surfaceGlass = const Color(0x26FFFFFF);         // Glass effect

      textPrimary = const Color(0xFFF1F5F9);          // Bright white for primary text
      textSecondary = const Color(0xFFCBD5E1);        // Softer for secondary
      textTertiary = const Color(0xFF94A3B8);         // Muted for tertiary
      textDisabled = const Color(0xFF64748B);         // Disabled state
      textOnPrimary = const Color(0xFFFFFFFF);        // White on primary
      textOnSecondary = const Color(0xFFFFFFFF);      // White on secondary

      divider = const Color(0xFF1E293B);              // Subtle dividers
      dividerStrong = const Color(0xFF334155);        // Stronger dividers
      border = const Color(0xFF1E293B);               // Border color
      borderStrong = const Color(0xFF334155);         // Strong borders

      overlay = const Color(0x99000000);              // Modal overlay
      overlayStrong = const Color(0xCC000000);        // Strong overlay

      glassBackground = const Color(0x1AFFFFFF);      // Glass background
      glassBorder = const Color(0x40FFFFFF);          // Glass border (more visible)
      glassHighlight = const Color(0x0DFFFFFF);       // Glass highlight
      glassShadow = const Color(0x66000000);          // Deeper shadows
    } else {
      // Light mode: Clean blue-white (matching website)
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
  // UTILITY METHODS
  // ───────────────────────────────────────────────────────────────────────────

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color blend(Color foreground, Color background, double factor) {
    return Color.lerp(background, foreground, factor)!;
  }
}