import 'package:flutter/material.dart';

/// Extension on [BuildContext] providing convenient screen-size and theme helpers.
///
/// Usage:
/// ```dart
/// final width  = context.screenWidth;
/// final height = context.screenHeight;
/// final theme  = context.theme;
/// final colors = context.colorScheme;
/// ```
extension ContextExtension on BuildContext {
  // ── Screen size ────────────────────────────────────────────────────────────

  /// Full width of the current screen in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Full height of the current screen in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Screen size as a [Size] object.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Returns `true` when the screen width is less than 600 dp (phone).
  bool get isMobile => screenWidth < 600;

  /// Returns `true` when the screen width is between 600 dp and 1200 dp (tablet).
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Returns `true` when the screen width is 1200 dp or more (desktop).
  bool get isDesktop => screenWidth >= 1200;

  /// The device pixel ratio.
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// The padding (e.g. status bar, notch) around the screen.
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// The insets occupied by system UI (e.g. keyboard).
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  // ── Theme ──────────────────────────────────────────────────────────────────

  /// The nearest [ThemeData] in the widget tree.
  ThemeData get theme => Theme.of(this);

  /// The [ColorScheme] from the nearest [ThemeData].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The [TextTheme] from the nearest [ThemeData].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns `true` when the current theme brightness is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Pops the current route off the navigator.
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Pushes a named route onto the navigator.
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
}
