import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/role_configs.dart';
import '../../../../screens/role_dashboard_screen.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/role_controller.dart';
import '../../../admin/presentation/screens/admin_screen.dart';
import '../../../pet_owner/presentation/controllers/pet_owner_controller.dart';
import '../../../provider/presentation/controllers/provider_controller.dart';
import '../../../shelter/presentation/controllers/shelter_controller.dart';
import '../../../volunteer/presentation/controllers/volunteer_controller.dart';
import '../../../../shared/widgets/ios_dashboard_chrome.dart';
import '../../../../shared/widgets/role_dashboard_drawer.dart';
import '../controllers/dashboard_controller.dart';
import 'generic_dashboard.dart';

/// Role-Based Dashboard Router
///
/// This widget determines which dashboard to display based on the user's
/// active role. It follows the pattern described in ROLE_BASED_UI_IMPLEMENTATION.md:
///
/// - Backend owns: roles, is_superuser, default_tenant_id
/// - Frontend owns: which home screen to open, which tabs to show
///
/// The dashboard selection logic:
/// 1. Super admin → Admin dashboard
/// 2. No roles → Pending approval (handled by redirect logic)
/// 3. Active role determines dashboard:
///    - shop_owner → DashboardScreen (comprehensive CMS dashboard)
///    - shelter → ShelterDashboard (shelter-themed comprehensive dashboard)
///    - Other roles → GenericDashboard (fallback)
class RoleBasedDashboard extends StatelessWidget {
  const RoleBasedDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return GetBuilder<RoleController>(
          builder: (roleController) {
            final session = authController.session.value;
            final user = session?.user;

            // Super admin gets the admin dashboard
            if (user?.isSuperuser == true) {
              return const AdminScreen();
            }

            // No roles → should be handled by redirect logic, but show generic as fallback
            if (user == null || user.roles.isEmpty) {
              return const GenericDashboard(roleName: 'user');
            }

            // Get active role (from RoleController or first role as fallback)
            final activeRole =
                roleController.selectedRole.value ?? user.roles.first;
            final roleName = activeRole.name.toLowerCase().replaceAll(' ', '_');

            return Scaffold(
              drawer: const RoleDashboardDrawer(),
              onDrawerChanged: RoleDashboardDrawerController.setOpen,
              body: Builder(
                builder: (scaffoldContext) {
                  return Obx(() {
                    _ensureRoleDataLoaded(roleName);
                    final displayName = user.fullName.trim().isEmpty
                        ? _displayRoleName(roleName)
                        : user.fullName.trim();
                    final config = buildRoleDashboardConfig(
                      context: scaffoldContext,
                      roleName: roleName,
                      displayName: displayName,
                    );
                    return IosSwitcher(
                      child: KeyedSubtree(
                        key: ValueKey(roleName),
                        child: RoleDashboardScreen(config: config),
                      ),
                    );
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  void _ensureRoleDataLoaded(String roleName) {
    switch (dashboardConfigKeyForRole(roleName)) {
      case 'owner':
        final controller = Get.find<PetOwnerController>();
        if (controller.overviewStatus.value == PetOwnerStatus.idle) {
          Future.microtask(controller.loadOverview);
        }
      case 'volunteer':
        final controller = Get.find<VolunteerController>();
        if (controller.status.value == VolunteerStatus.idle) {
          Future.microtask(() async {
            await controller.loadDashboard();
            await controller.loadShelters();
          });
        }
      case 'shelter':
        final controller = Get.find<ShelterController>();
        if (controller.overviewStatus.value == ShelterStatus.idle) {
          Future.microtask(controller.loadOverview);
        }
      case 'provider':
        final controller = Get.find<ProviderController>();
        if (controller.overviewStatus.value == ProviderStatus.idle) {
          Future.microtask(controller.loadOverview);
        }
      case 'shop':
        final controller = Get.find<DashboardController>();
        if (controller.status.value == DashboardStatus.idle) {
          Future.microtask(controller.loadDashboard);
        }
    }
  }

  String _displayRoleName(String roleName) {
    return roleName
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
