import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_logo.dart';

/// Generic Dashboard
/// 
/// A fallback dashboard for roles that don't have a specific dashboard implementation.
/// Displays basic user information and common actions.
class GenericDashboard extends StatelessWidget {
  final String roleName;
  
  const GenericDashboard({
    super.key,
    required this.roleName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            shadowColor: AppColors.divider,
            elevation: 0,
            scrolledUnderElevation: 1,
            toolbarHeight: 60,
            titleSpacing: 16,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogoTile(size: 34, radius: 10, showShadow: false),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_capitalize(roleName),
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary, fontSize: 11)),
                    Text('Dashboard',
                        style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AppBarBtn(icon: Icons.notifications_none_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    _AppBarBtn(
                        icon: Icons.settings_outlined,
                        onTap: () => context.push(AppRoutes.settings)),
                  ],
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.dashboard_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome!',
                                  style: AppTextStyles.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900)),
                              Text('${_capitalize(roleName)} Dashboard',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.primary, size: 48),
                        const SizedBox(height: 16),
                        Text('Dashboard Coming Soon',
                            style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(
                          'The ${_capitalize(roleName)} dashboard is currently under development. Check back soon for role-specific features and tools.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(icon, size: 19, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
