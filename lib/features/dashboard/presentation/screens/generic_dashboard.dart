import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/role_dashboard_drawer.dart';

/// Generic Dashboard
///
/// A fallback dashboard for roles that don't have a specific dashboard implementation.
/// Displays basic user information and common actions.
class GenericDashboard extends StatelessWidget {
  final String roleName;

  const GenericDashboard({super.key, required this.roleName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleDashboardDrawer(),
      onDrawerChanged: RoleDashboardDrawerController.setOpen,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: buildFrostedAppBarBackground(),
            surfaceTintColor: Colors.transparent,
            shadowColor: AppColors.divider,
            elevation: 0,
            scrolledUnderElevation: 1,
            toolbarHeight: 60,
            titleSpacing: 16,
            automaticallyImplyLeading: false,
            leading: Builder(
              builder: (context) => Center(
                child: IosIconButton(
                  tooltip: 'Open menu',
                  icon: CupertinoIcons.line_horizontal_3,
                  onTap: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogoTile(size: 34, radius: 10, showShadow: false),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _capitalize(roleName),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Home Page',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
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
                    _AppBarBtn(icon: CupertinoIcons.bell, onTap: () {}),
                    const SizedBox(width: 8),
                    _AppBarBtn(
                      icon: CupertinoIcons.gear,
                      onTap: () => context.push(AppRoutes.settings),
                    ),
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
                  RoleDashboardHeader(
                    eyebrow: '${_capitalize(roleName)} workspace',
                    title: 'Welcome to Zoovana',
                    subtitle:
                        'Your role-specific tools will appear here as soon as this workspace is configured.',
                    icon: CupertinoIcons.square_grid_2x2_fill,
                    accent: AppColors.accentLight,
                  ),
                  const SizedBox(height: 24),
                  RoleStatePanel(
                    title: 'Dashboard coming soon',
                    message:
                        'The ${_capitalize(roleName)} dashboard is being prepared with role-specific tools and shortcuts.',
                    icon: CupertinoIcons.sparkles,
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
    return IosIconButton(
      icon: icon,
      onTap: onTap,
      foregroundColor: AppColors.textSecondary,
    );
  }
}
