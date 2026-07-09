import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../shared/widgets/role_dashboard_components.dart';
import '../../../../shared/widgets/role_dashboard_drawer.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleDashboardDrawer(),
      onDrawerChanged: RoleDashboardDrawerController.setOpen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: buildFrostedAppBarBackground(),
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.divider,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: Builder(
          builder: (context) => Center(
            child: IosIconButton(
              tooltip: 'Open menu',
              icon: CupertinoIcons.line_horizontal_3,
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        titleSpacing: 16,
        title: Row(
          children: [
            const AppLogoTile(size: 32, radius: 9, showShadow: false),
            const SizedBox(width: 10),
            Text(
              'Admin Console',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: const [
          RoleDashboardHeader(
            eyebrow: 'Super admin',
            title: 'Platform control center',
            subtitle:
                'Manage Zoovana operations, role access, and high-level platform activity from one executive view.',
            icon: CupertinoIcons.lock_shield_fill,
            accent: AppColors.highlightLight,
          ),
          SizedBox(height: 20),
          RoleStatePanel(
            title: 'Admin modules are ready for connection',
            message:
                'Detailed operational cards can be added here as backend admin endpoints become available.',
            icon: CupertinoIcons.square_grid_2x2_fill,
          ),
        ],
      ),
    );
  }
}
