import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../core/di/dependency_injection.dart';
import '../features/admin/presentation/screens/admin_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/controllers/role_controller.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/pending_approval_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';
import '../features/dashboard/presentation/bindings/dashboard_binding.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart'
    show
        DashboardScreen,
        InventoryScreen,
        PurchaseOrdersScreen,
        MarketplaceOrdersScreen,
        InvoicesScreen;
import '../features/suppliers/presentation/screens/suppliers_list_screen.dart';
import '../features/categories/presentation/screens/categories_list_screen.dart';
import '../features/dashboard/presentation/screens/role_based_dashboard.dart';
import '../features/branches/presentation/screens/branches_screen.dart';
import '../features/donation/presentation/screens/donation_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/lost_found/presentation/screens/lost_found_screen.dart';
import '../features/products_management/presentation/screens/products_management_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/vendor_sites/presentation/bindings/vendor_site_binding.dart';
import '../features/vendor_sites/presentation/screens/vendor_site_list_screen.dart';
import '../features/vendors/presentation/bindings/vendor_binding.dart';
import '../features/vendors/presentation/screens/vendor_list_screen.dart';
import '../features/shop/presentation/controllers/shop_init_controller.dart';
import '../features/shop/presentation/screens/role_select_screen.dart';
import '../features/shop/presentation/screens/shop_init_loading_screen.dart';
import '../shared/widgets/customer_bottom_nav.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'redirect_logic.dart';

// ---------------------------------------------------------------------------
// RouterNotifier
// ---------------------------------------------------------------------------

class RouterNotifier extends ChangeNotifier {
  RouterNotifier() {
    _bindWorkers();
  }

  void _bindWorkers() {
    ever(Get.find<AuthController>().status, (_) => notifyListeners());
    ever(Get.find<RoleController>().selectedRole, (_) => notifyListeners());
    ever(Get.find<ShopInitController>().status, (_) => notifyListeners());
    Future.microtask(notifyListeners);
  }
}

// ---------------------------------------------------------------------------
// appRouter
// ---------------------------------------------------------------------------

GoRouter? _appRouterInstance;

GoRouter get appRouter {
  _appRouterInstance ??= _buildRouter();
  return _appRouterInstance!;
}

GoRouter _buildRouter() => GoRouter(
  initialLocation: demoMode ? AppRoutes.login : AppRoutes.splash,
  refreshListenable: RouterNotifier(),
  redirect: (context, state) {
    final authController = Get.find<AuthController>();
    final roleController = Get.find<RoleController>();
    final shopInitController = Get.find<ShopInitController>();

    return computeRedirect(
      location: state.uri.toString(),
      authStatus: authController.status.value,
      session: authController.session.value,
      roles: roleController.roles.toList(),
      selectedRole: roleController.selectedRole.value,
      shopInitStatus: shopInitController.status.value,
    );
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => _fadeRoute(
        key: state.pageKey,
        child: const SplashScreen(),
        duration: Duration.zero, // splash appears instantly
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => _fadeRoute(
        key: state.pageKey,
        child: const LoginScreen(),
        duration: const Duration(milliseconds: 600),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.pendingApproval,
      builder: (context, state) => const PendingApprovalScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelect,
      builder: (context, state) => const RoleSelectScreen(),
    ),
    GoRoute(
      path: AppRoutes.shopInit,
      builder: (context, state) => const ShopInitLoadingScreen(),
    ),
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomerBottomNavShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => _fadeRoute(
                key: state.pageKey,
                child: const HomeScreen(),
                duration: const Duration(milliseconds: 600),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.donation,
              builder: (context, state) => const DonationScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.lostFound,
              builder: (context, state) => const LostFoundScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) {
                DashboardBinding().dependencies();
                return const RoleBasedDashboard();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.products,
      builder: (context, state) => const ProductsManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.vendors,
      builder: (context, state) {
        VendorBinding().dependencies();
        return const VendorListScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.vendorSites,
      builder: (context, state) {
        VendorSiteBinding().dependencies();
        return const VendorSiteListScreen();
      },
    ),
    // ── Dashboard module routes ──────────────────────────────
    GoRoute(
      path: AppRoutes.moduleBranches,
      builder: (context, state) => const BranchesScreen(),
    ),
    GoRoute(
      path: AppRoutes.moduleSuppliers,
      builder: (context, state) => const SuppliersListScreen(),
    ),
    GoRoute(
      path: AppRoutes.moduleCategories,
      builder: (context, state) => const CategoriesListScreen(),
    ),
    GoRoute(
      path: AppRoutes.moduleInventory,
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.modulePurchaseOrders,
      builder: (context, state) => const PurchaseOrdersScreen(),
    ),
    GoRoute(
      path: AppRoutes.moduleOrders,
      builder: (context, state) => const MarketplaceOrdersScreen(),
    ),
    GoRoute(
      path: AppRoutes.moduleInvoices,
      builder: (context, state) => const InvoicesScreen(),
    ),
  ],
);

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Premium scale-dissolve transition used for splash → home and other
/// key navigations. The incoming screen fades in while gently settling
/// from a slight zoom (1.06 → 1.0), giving a cinematic, buttery feel.
CustomTransitionPage<void> _fadeRoute({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 600),
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Outgoing screen fades out slightly (secondary animation)
      final fadeOut = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      );

      // Incoming screen: fade in
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
      );

      // Incoming screen: gentle scale settle (1.06 → 1.0)
      final scale = Tween<double>(begin: 1.06, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
        ),
      );

      return FadeTransition(
        opacity: fadeOut,
        child: FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        ),
      );
    },
  );
}
