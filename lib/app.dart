import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/config/app_colors.dart';
import 'core/theme/app_theme_controller.dart';
import 'routes/app_router.dart';

/// Root widget of the Zoovana CMS application.
///
/// Wraps [MaterialApp.router] with [ScreenUtilInit] for responsive layout
/// support. Navigation is handled by [appRouter] (GoRouter).
///
/// Requirements: 17.6
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _animation;
  late ThemeData _previousTheme;
  late ThemeData _currentTheme;
  int _themeVersion = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Initialize both themes to the current mode so lerp at value=1.0
    // produces the correct theme immediately on startup (no animation).
    final isDarkMode = AppThemeController.instance.isDarkMode;
    _previousTheme = _buildTheme(isDarkMode: isDarkMode);
    _currentTheme = _buildTheme(isDarkMode: isDarkMode);

    // Set controller to completed so animation.value == 1.0 at startup,
    // meaning ThemeData.lerp(_previousTheme, _currentTheme, 1.0) == _currentTheme.
    _controller.value = 1.0;

    _syncSystemUi(isDarkMode: isDarkMode);
    AppThemeController.instance.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    final isDarkMode = AppThemeController.instance.isDarkMode;
    _syncSystemUi(isDarkMode: isDarkMode);

    setState(() {
      _themeVersion++;
      _previousTheme = _currentTheme;
      _currentTheme = _buildTheme(isDarkMode: isDarkMode);
    });

    _controller.forward(from: 0);
  }

  void _syncSystemUi({required bool isDarkMode}) {
    final iconBrightness = isDarkMode ? Brightness.light : Brightness.dark;
    final statusBarBrightness = isDarkMode ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
        statusBarBrightness: statusBarBrightness,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: iconBrightness,
      ),
    );
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
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final interpolated = ThemeData.lerp(
              _previousTheme,
              _currentTheme,
              _animation.value,
            );

            return MaterialApp.router(
              title: 'Zoovana',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              theme: interpolated,
              darkTheme: interpolated,
              themeMode: ThemeMode.light,
              builder: (context, child) {
                return KeyedSubtree(
                  key: ValueKey(_themeVersion),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }

  ThemeData _buildTheme({required bool isDarkMode}) {
    final base = isDarkMode
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return base.copyWith(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.error,
          ).copyWith(
            onPrimary: AppColors.textOnPrimary,
            onSecondary: AppColors.white,
            onSurface: AppColors.textPrimary,
            onError: AppColors.white,
            outline: AppColors.divider,
          ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textDisabled),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),
      dividerTheme: DividerThemeData(color: AppColors.divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
