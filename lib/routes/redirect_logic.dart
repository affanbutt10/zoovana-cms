// Feature: zoovana-auth-rbac-shop-init
// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 19.1, 19.2

import '../core/di/dependency_injection.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/domain/entities/auth_session_entity.dart';
import '../features/auth/domain/entities/role_entity.dart';
import '../features/shop/presentation/controllers/shop_init_controller.dart';
import 'app_routes.dart';

// ---------------------------------------------------------------------------
// Public routes — accessible without authentication
// ---------------------------------------------------------------------------

const publicRoutes = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.verifyEmail,   // accessible when unauthenticated (post-registration)
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
  AppRoutes.pendingApproval,
  AppRoutes.splash,
};

// ---------------------------------------------------------------------------
// App routes — accessible by any authenticated user regardless of role.
// These are the customer-facing mobile UI screens and shared utility screens.
// ---------------------------------------------------------------------------

const appRoutes = {
  AppRoutes.home,
  AppRoutes.donation,
  AppRoutes.lostFound,
  AppRoutes.profile,
  AppRoutes.settings,
  AppRoutes.dashboard,
};

// ---------------------------------------------------------------------------
// computeRedirect — pure function implementing the 7-step navigation guard
//
// This is the testable form of the redirect logic. It takes all required
// state as plain parameters (no GetX or GoRouter dependencies) so it can be
// unit- and property-tested directly.
//
// Returns the target route string to redirect to, or null to allow the
// current navigation to proceed unchanged.
//
// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 19.1, 19.2, 19.3, 19.4
// ---------------------------------------------------------------------------

String? computeRedirect({
  required String location,
  required AuthStatus authStatus,
  required AuthSessionEntity? session,
  required List<RoleEntity> roles,
  required RoleEntity? selectedRole,
  required ShopInitStatus shopInitStatus,
}) {
  // ── Demo / prototype mode ──────────────────────────────────────────────────
  // When demoMode is true, show the login screen first so the client can see
  // the auth flow, but skip all other guards once authenticated so every
  // screen is freely navigable.
  // Flip demoMode = false in dependency_injection.dart before going live.
  if (demoMode) {
    // Not yet authenticated — show login (or any public auth screen).
    if (authStatus == AuthStatus.unauthenticated ||
        authStatus == AuthStatus.loading) {
      if (location == AppRoutes.login) return null;
      return AppRoutes.login;
    }
    // Authenticated — go to home if on a public/auth route, else allow through.
    if (publicRoutes.contains(location)) return AppRoutes.home;
    return null;
  }

  final isPublic = publicRoutes.contains(location);

  // Step 0: Auth is still loading.
  if (authStatus == AuthStatus.loading) {
    // Stay on splash (or any public route) while auth initialises.
    if (isPublic) return null;
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  // Step 1: Unauthenticated — guard non-public routes.
  // /splash is allowed to stay — the splash screen navigates itself
  // after its exit animation completes, then the redirect fires again
  // on the new location (/home → /login for unauthenticated users).
  if (authStatus == AuthStatus.unauthenticated) {
    if (location == AppRoutes.splash) return null; // let splash finish
    return isPublic ? null : AppRoutes.login;
  }

  // Step 2: Pending approval — always redirect to pending-approval screen.
  if (authStatus == AuthStatus.pendingApproval) {
    return location == AppRoutes.pendingApproval
        ? null
        : AppRoutes.pendingApproval;
  }

  // From here on the user is fully authenticated.

  // Step 3: Authenticated user on a public route — send to home.
  // Exception: /verify-email is allowed even when authenticated, so a user
  // who just registered and then logs in can still complete verification.
  if (isPublic && location != AppRoutes.verifyEmail) {
    return AppRoutes.home;
  }

  // Step 4 (email verification) is intentionally skipped.
  // The backend controls access — if the user received a token, they are
  // allowed to use the app regardless of email verification status.

  // Step 5: Role not selected yet.
  if (selectedRole == null) {
    if (roles.length > 1) {
      // Multiple roles available — user must choose.
      // But don't block app routes if we're already navigating within the app
      // (e.g. bottom nav taps). Only enforce role selection from the initial
      // post-login redirect.
      final isAppRoute = appRoutes.contains(location);
      if (!isAppRoute) {
        return location == AppRoutes.roleSelect ? null : AppRoutes.roleSelect;
      }
    }
    // Single role, no roles, or already on an app route — allow through.
    return null;
  }

  // Step 6: Non-superuser trying to access /admin — redirect to home.
  if (session != null &&
      !session.user.isSuperuser &&
      location == AppRoutes.admin) {
    return AppRoutes.home;
  }

  // Step 7: Shop owner role routing based on shop init status.
  // idle/loading/error → force the init screen so it can run/retry.
  // ready → allow free navigation.
  // If the user is already on /shop-init, always allow it (handles retry).
  final selectedRoleName = selectedRole.name.toLowerCase();
  if (selectedRoleName == 'shop_owner') {
    if (shopInitStatus == ShopInitStatus.ready) {
      // Shop is ready — if still on the init screen, redirect to home.
      if (location == AppRoutes.shopInit) return AppRoutes.home;
      return null;
    }
    // Not ready yet — send to init screen so it can load or retry.
    return location == AppRoutes.shopInit ? null : AppRoutes.shopInit;
  }

  // No redirect needed.
  return null;
}
