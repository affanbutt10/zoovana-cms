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
        InventoryScreen,
        PurchaseOrdersScreen,
        MarketplaceOrdersScreen,
        InvoicesScreen;
import '../features/suppliers/presentation/screens/suppliers_list_screen.dart';
import '../features/categories/presentation/screens/categories_list_screen.dart';
import '../features/dashboard/presentation/screens/role_based_dashboard.dart';
import '../features/branches/presentation/screens/branches_screen.dart';
import '../features/chat/presentation/screens/chat_conversation_screen.dart';
import '../features/chat/presentation/screens/chat_inbox_screen.dart';
import '../features/donation/presentation/screens/donation_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/lost_found/presentation/screens/lost_found_screen.dart';
import '../features/pet_owner/presentation/screens/pet_owner_bookings_screen.dart';
import '../features/pet_owner/presentation/screens/pet_owner_dashboard_screen.dart';
import '../features/pet_owner/presentation/screens/pet_owner_pets_screen.dart';
import '../features/pet_owner/presentation/screens/pet_owner_services_screen.dart';
import '../features/products_management/presentation/screens/products_management_screen.dart';
import '../features/provider/presentation/screens/provider_bookings_screen.dart';
import '../features/provider/presentation/screens/provider_dashboard_screen.dart';
import '../features/provider/presentation/screens/provider_services_screen.dart';
import '../features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/shelter/presentation/screens/shelter_adoptions_screen.dart';
import '../features/shelter/presentation/screens/shelter_animal_care_screen.dart';
import '../features/shelter/presentation/screens/shelter_animals_screen.dart';
import '../features/shelter/presentation/screens/shelter_donations_screen.dart';
import '../features/shelter/presentation/screens/shelter_kennels_screen.dart';
import '../features/shelter/presentation/screens/shelter_list_screen.dart';
import '../features/shelter/presentation/screens/shelter_lost_found_screen.dart';
import '../features/shelter/presentation/screens/shelter_medical_screen.dart';
import '../features/shelter/presentation/screens/shelter_overview_screen.dart';
import '../features/shelter/presentation/screens/shelter_settings_screen.dart';
import '../features/shelter/presentation/screens/shelter_vaccinations_screen.dart';
import '../features/shelter/presentation/screens/shelter_volunteers_screen.dart';
import '../features/vendor_sites/presentation/bindings/vendor_site_binding.dart';
import '../features/vendor_sites/presentation/screens/vendor_site_list_screen.dart';
import '../features/vendors/presentation/bindings/vendor_binding.dart';
import '../features/vendors/presentation/screens/vendor_list_screen.dart';
import '../features/shop/presentation/controllers/shop_init_controller.dart';
import '../features/shop/presentation/screens/role_select_screen.dart';
import '../features/shop/presentation/screens/shop_init_loading_screen.dart';
import '../shared/widgets/customer_bottom_nav.dart';
import '../shared/widgets/premium_motion.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'navigation_keys.dart';
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
  navigatorKey: rootNavigatorKey,
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
        child: LoginScreen(
          accountRequired:
              state.uri.queryParameters['reason'] == 'account_required',
        ),
        duration: const Duration(milliseconds: 600),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const RegisterScreen()),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const VerifyEmailScreen()),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ResetPasswordScreen()),
    ),
    GoRoute(
      path: AppRoutes.pendingApproval,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const PendingApprovalScreen()),
    ),
    GoRoute(
      path: AppRoutes.roleSelect,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const RoleSelectScreen()),
    ),
    GoRoute(
      path: AppRoutes.shopInit,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShopInitLoadingScreen()),
    ),
    GoRoute(
      path: AppRoutes.admin,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const AdminScreen()),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomerBottomNavShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.donation,
              pageBuilder: (context, state) =>
                  _iosRoute(key: state.pageKey, child: const DonationScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.lostFound,
              pageBuilder: (context, state) =>
                  _iosRoute(key: state.pageKey, child: const LostFoundScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              pageBuilder: (context, state) {
                DashboardBinding().dependencies();
                return _iosRoute(
                  key: state.pageKey,
                  child: const RoleBasedDashboard(),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (context, state) =>
                  _iosRoute(key: state.pageKey, child: const ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) => _fadeRoute(
        key: state.pageKey,
        child: const HomeScreen(),
        duration: const Duration(milliseconds: 600),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.chatInbox,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ChatInboxScreen()),
    ),
    GoRoute(
      path: AppRoutes.chatConversation,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ChatConversationScreen()),
    ),
    GoRoute(
      path: AppRoutes.petOwnerDashboard,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const PetOwnerDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.legacyPetcare,
      redirect: (context, state) => AppRoutes.petOwnerDashboard,
    ),
    GoRoute(
      path: AppRoutes.petOwnerPets,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const PetOwnerPetsScreen()),
    ),
    GoRoute(
      path: AppRoutes.petOwnerServices,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const PetOwnerServicesScreen()),
    ),
    GoRoute(
      path: AppRoutes.petOwnerBookings,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const PetOwnerBookingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.petOwnerMessages,
      redirect: (context, state) => AppRoutes.chatInbox,
    ),
    GoRoute(
      path: AppRoutes.providerDashboard,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ProviderDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.providerServices,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ProviderServicesScreen()),
    ),
    GoRoute(
      path: AppRoutes.providerBookings,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ProviderBookingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.providerMessages,
      redirect: (context, state) => AppRoutes.chatInbox,
    ),
    GoRoute(
      path: AppRoutes.providerSettings,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.volunteerDashboard,
      pageBuilder: (context, state) => _iosRoute(
        key: state.pageKey,
        child: const VolunteerDashboardScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.shelterOverview,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterOverviewScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterList,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterListScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterAnimals,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterAnimalsScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterMedical,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterMedicalScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterVaccinations,
      pageBuilder: (context, state) => _iosRoute(
        key: state.pageKey,
        child: const ShelterVaccinationsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.shelterKennels,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterKennelsScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterAdoptions,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterAdoptionsScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterVolunteers,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterVolunteersScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterDonations,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterDonationsScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterLostFound,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterLostFoundScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterAnimalCare,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterAnimalCareScreen()),
    ),
    GoRoute(
      path: AppRoutes.shelterSettings,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const ShelterSettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.products,
      pageBuilder: (context, state) => _iosRoute(
        key: state.pageKey,
        child: const ProductsManagementScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.vendors,
      pageBuilder: (context, state) {
        VendorBinding().dependencies();
        return _iosRoute(key: state.pageKey, child: const VendorListScreen());
      },
    ),
    GoRoute(
      path: AppRoutes.vendorSites,
      pageBuilder: (context, state) {
        VendorSiteBinding().dependencies();
        return _iosRoute(
          key: state.pageKey,
          child: const VendorSiteListScreen(),
        );
      },
    ),
    // ── Dashboard module routes ──────────────────────────────
    GoRoute(
      path: AppRoutes.moduleBranches,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const BranchesScreen()),
    ),
    GoRoute(
      path: AppRoutes.moduleSuppliers,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const SuppliersListScreen()),
    ),
    GoRoute(
      path: AppRoutes.moduleCategories,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const CategoriesListScreen()),
    ),
    GoRoute(
      path: AppRoutes.moduleInventory,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const InventoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.modulePurchaseOrders,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const PurchaseOrdersScreen()),
    ),
    GoRoute(
      path: AppRoutes.moduleOrders,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const MarketplaceOrdersScreen()),
    ),
    GoRoute(
      path: AppRoutes.moduleInvoices,
      pageBuilder: (context, state) =>
          _iosRoute(key: state.pageKey, child: const InvoicesScreen()),
    ),
  ],
);

// ── Helpers ──────────────────────────────────────────────────────────────────

CustomTransitionPage<void> _iosRoute({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: PremiumMotion.routeDuration,
    reverseTransitionDuration: PremiumMotion.routeReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final primaryCurve = CurvedAnimation(
        parent: animation,
        curve: PremiumMotion.curve,
        reverseCurve: PremiumMotion.curve,
      );
      final secondaryCurve = CurvedAnimation(
        parent: secondaryAnimation,
        curve: PremiumMotion.curve,
        reverseCurve: PremiumMotion.curve,
      );

      final incomingOffset = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(primaryCurve);
      final outgoingOffset = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.025, 0),
      ).animate(secondaryCurve);
      final incomingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8, curve: PremiumMotion.curve),
        ),
      );
      final outgoingFade = Tween<double>(
        begin: 1.0,
        end: 0.92,
      ).animate(secondaryCurve);

      return SlideTransition(
        position: outgoingOffset,
        child: FadeTransition(
          opacity: outgoingFade,
          child: FadeTransition(
            opacity: incomingFade,
            child: SlideTransition(position: incomingOffset, child: child),
          ),
        ),
      );
    },
  );
}

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
        CurvedAnimation(parent: secondaryAnimation, curve: PremiumMotion.curve),
      );

      // Incoming screen: fade in
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.85, curve: PremiumMotion.curve),
      );

      // Incoming screen: gentle scale settle (1.06 → 1.0)
      final scale = Tween<double>(begin: 1.06, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: PremiumMotion.curve),
        ),
      );

      return FadeTransition(
        opacity: fadeOut,
        child: FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}
