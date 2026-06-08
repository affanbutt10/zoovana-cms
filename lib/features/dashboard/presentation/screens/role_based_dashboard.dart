import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/role_controller.dart';
import '../../../admin/presentation/screens/admin_screen.dart';
import 'dashboard_screen.dart';
import 'generic_dashboard.dart';
import 'shelter_dashboard.dart';

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
            final activeRole = roleController.selectedRole.value ?? user.roles.first;
            final roleName = activeRole.name.toLowerCase().replaceAll(' ', '_');

            // Route to role-specific dashboard
            return _buildDashboardForRole(roleName);
          },
        );
      },
    );
  }

  Widget _buildDashboardForRole(String roleName) {
    switch (roleName) {
      case 'shop_owner':
        // Shop owners get the full comprehensive CMS dashboard
        return const DashboardScreen();
      
      case 'shelter':
        // Shelters get a shelter-themed comprehensive dashboard
        return const ShelterDashboard();
      
      case 'volunteer':
        return const GenericDashboard(roleName: 'volunteer');
      
      case 'animalowner':
        return const GenericDashboard(roleName: 'animal owner');
      
      case 'serviceprovider':
        return const GenericDashboard(roleName: 'service provider');
      
      case 'user':
        return const GenericDashboard(roleName: 'user');
      
      default:
        // Fallback for any unknown roles
        return GenericDashboard(roleName: roleName);
    }
  }
}
