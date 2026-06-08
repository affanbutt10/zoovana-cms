// Feature: zoovana-auth-rbac-shop-init, Property 9: GoRouter redirect correctness
//
// Validates: Requirements 12.1–12.5, 19.1, 19.2
//
// Property 9: GoRouter redirect produces correct route for all auth state
// combinations — for all combinations of AuthStatus × RoleController.selectedRole
// × ShopInitStatus, computeRedirect returns the expected route constant per the
// 7-step logic table.

import 'package:glados/glados.dart';
import 'package:zoovana_cms/features/auth/domain/entities/auth_session_entity.dart';
import 'package:zoovana_cms/features/auth/domain/entities/role_entity.dart';
import 'package:zoovana_cms/features/auth/domain/entities/user_entity.dart';
import 'package:zoovana_cms/features/auth/presentation/controllers/auth_controller.dart';
import 'package:zoovana_cms/features/shop/presentation/controllers/shop_init_controller.dart';
import 'package:zoovana_cms/routes/app_routes.dart';
import 'package:zoovana_cms/routes/redirect_logic.dart';

// ---------------------------------------------------------------------------
// Test helpers — build minimal entities for redirect logic testing
// ---------------------------------------------------------------------------

/// Creates a [UserEntity] with the given flags.
UserEntity _makeUser({
  bool isSuperuser = false,
  bool isEmailVerified = true,
  List<RoleEntity> roles = const [],
}) {
  return UserEntity(
    id: 'user-1',
    email: 'test@example.com',
    fullName: 'Test User',
    isSuperuser: isSuperuser,
    isEmailVerified: isEmailVerified,
    roles: roles,
    defaultTenantId: 'tenant-1',
  );
}

/// Creates an [AuthSessionEntity] wrapping the given [UserEntity].
AuthSessionEntity _makeSession(UserEntity user) {
  return AuthSessionEntity(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresIn: 1800,
    user: user,
    status: AuthSessionStatus.active,
  );
}

/// A [RoleEntity] representing a shop owner.
const _shopOwnerRole = RoleEntity(
  id: 'role-shop-owner',
  name: 'shop_owner',
  scope: 'tenant',
);

/// A [RoleEntity] representing a regular staff member.
const _staffRole = RoleEntity(
  id: 'role-staff',
  name: 'staff',
  scope: 'tenant',
);

/// A [RoleEntity] representing an admin.
const _adminRole = RoleEntity(
  id: 'role-admin',
  name: 'admin',
  scope: 'global',
);

// ---------------------------------------------------------------------------
// Generators
// ---------------------------------------------------------------------------

extension RedirectAny on Any {
  /// Generates a non-public, non-admin route string.
  Generator<String> get nonPublicRoute => simple(
        generate: (random, size) {
          const routes = [
            AppRoutes.dashboard,
            AppRoutes.shopDashboard,
            AppRoutes.products,
            AppRoutes.settings,
          ];
          return routes[random.nextInt(routes.length)];
        },
        shrink: (_) => [],
      );

  /// Generates a public route string.
  Generator<String> get publicRoute => simple(
        generate: (random, size) {
          final routes = publicRoutes.toList();
          return routes[random.nextInt(routes.length)];
        },
        shrink: (_) => [],
      );

  /// Generates any route string (public or non-public).
  Generator<String> get anyRoute => simple(
        generate: (random, size) {
          const routes = [
            AppRoutes.splash,
            AppRoutes.login,
            AppRoutes.register,
            AppRoutes.verifyEmail,
            AppRoutes.forgotPassword,
            AppRoutes.resetPassword,
            AppRoutes.pendingApproval,
            AppRoutes.dashboard,
            AppRoutes.shopDashboard,
            AppRoutes.roleSelect,
            AppRoutes.shopInit,
            AppRoutes.admin,
            AppRoutes.products,
            AppRoutes.settings,
          ];
          return routes[random.nextInt(routes.length)];
        },
        shrink: (_) => [],
      );

  /// Generates a [ShopInitStatus] value.
  Generator<ShopInitStatus> get shopInitStatus => simple(
        generate: (random, size) {
          final values = ShopInitStatus.values;
          return values[random.nextInt(values.length)];
        },
        shrink: (_) => [],
      );
}

// ---------------------------------------------------------------------------
// Property 9 tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Case 1: loading status → always /splash
  // -------------------------------------------------------------------------
  group('Property 9 — loading status always redirects to /splash', () {
    Glados(any.anyRoute).test(
      'loading + any route (not /splash) → /splash',
      (location) {
        if (location == AppRoutes.splash) return; // skip — already at splash

        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.loading,
          session: null,
          roles: const [],
          selectedRole: null,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, equals(AppRoutes.splash),
            reason: 'loading status must always redirect to /splash');
      },
    );

    test('loading + /splash → null (no redirect)', () {
      final result = computeRedirect(
        location: AppRoutes.splash,
        authStatus: AuthStatus.loading,
        session: null,
        roles: const [],
        selectedRole: null,
        shopInitStatus: ShopInitStatus.idle,
      );

      expect(result, isNull,
          reason: 'loading + already at /splash must return null');
    });
  });

  // -------------------------------------------------------------------------
  // Case 2: unauthenticated + non-public route → /login
  // -------------------------------------------------------------------------
  group('Property 9 — unauthenticated + non-public route → /login', () {
    Glados(any.nonPublicRoute).test(
      'unauthenticated + non-public route → /login',
      (location) {
        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.unauthenticated,
          session: null,
          roles: const [],
          selectedRole: null,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, equals(AppRoutes.login),
            reason: 'unauthenticated + non-public route must redirect to /login');
      },
    );
  });

  // -------------------------------------------------------------------------
  // Case 3: unauthenticated + public route → null
  // -------------------------------------------------------------------------
  group('Property 9 — unauthenticated + public route → null', () {
    Glados(any.publicRoute).test(
      'unauthenticated + public route → null (allow through)',
      (location) {
        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.unauthenticated,
          session: null,
          roles: const [],
          selectedRole: null,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, isNull,
            reason: 'unauthenticated + public route must return null (allow through)');
      },
    );
  });

  // -------------------------------------------------------------------------
  // Case 4: pendingApproval → /pending-approval
  // -------------------------------------------------------------------------
  group('Property 9 — pendingApproval → /pending-approval', () {
    Glados(any.anyRoute).test(
      'pendingApproval + any route (not /pending-approval) → /pending-approval',
      (location) {
        if (location == AppRoutes.pendingApproval) return; // skip

        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.pendingApproval,
          session: null,
          roles: const [],
          selectedRole: null,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, equals(AppRoutes.pendingApproval),
            reason: 'pendingApproval must always redirect to /pending-approval');
      },
    );

    test('pendingApproval + /pending-approval → null (no redirect)', () {
      final result = computeRedirect(
        location: AppRoutes.pendingApproval,
        authStatus: AuthStatus.pendingApproval,
        session: null,
        roles: const [],
        selectedRole: null,
        shopInitStatus: ShopInitStatus.idle,
      );

      expect(result, isNull,
          reason: 'pendingApproval + already at /pending-approval must return null');
    });
  });

  // -------------------------------------------------------------------------
  // Case 5: authenticated + public route → /dashboard
  // -------------------------------------------------------------------------
  group('Property 9 — authenticated + public route → /dashboard', () {
    Glados(any.publicRoute).test(
      'authenticated + public route → /dashboard',
      (location) {
        final user = _makeUser(isEmailVerified: true);
        final session = _makeSession(user);

        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.authenticated,
          session: session,
          roles: const [_staffRole],
          selectedRole: _staffRole,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, equals(AppRoutes.dashboard),
            reason: 'authenticated user on public route must be sent to /dashboard');
      },
    );
  });

  // -------------------------------------------------------------------------
  // Case 6: authenticated + email not verified → /verify-email
  // -------------------------------------------------------------------------
  group('Property 9 — authenticated + email not verified → /verify-email', () {
    Glados(any.nonPublicRoute).test(
      'authenticated + email not verified + non-public route → /verify-email',
      (location) {
        if (location == AppRoutes.verifyEmail) return; // skip — already there

        final user = _makeUser(isEmailVerified: false);
        final session = _makeSession(user);

        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.authenticated,
          session: session,
          roles: const [],
          selectedRole: null,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, equals(AppRoutes.verifyEmail),
            reason: 'unverified email must redirect to /verify-email');
      },
    );

    // Note: /verify-email is in the public routes set, so an authenticated user
    // at /verify-email is caught by Step 3 (public route → /dashboard) before
    // Step 4 (email not verified). The redirect logic sends unverified users TO
    // /verify-email from non-public routes; the /verify-email route itself is
    // public so authenticated users there are redirected to /dashboard.
    test('authenticated + email not verified + /verify-email → /dashboard (public route rule)', () {
      final user = _makeUser(isEmailVerified: false);
      final session = _makeSession(user);

      final result = computeRedirect(
        location: AppRoutes.verifyEmail,
        authStatus: AuthStatus.authenticated,
        session: session,
        roles: const [],
        selectedRole: null,
        shopInitStatus: ShopInitStatus.idle,
      );

      // /verify-email is a public route, so Step 3 fires: authenticated + public → /dashboard
      expect(result, equals(AppRoutes.dashboard),
          reason: '/verify-email is public, so authenticated user is sent to /dashboard by Step 3');
    });
  });

  // -------------------------------------------------------------------------
  // Case 7: authenticated + multiple roles + no selected role → /role-select
  // -------------------------------------------------------------------------
  group('Property 9 — multiple roles + no selected role → /role-select', () {
    test('authenticated + 2 roles + no selected role + non-role-select route → /role-select', () {
      final user = _makeUser(
        isEmailVerified: true,
        roles: [_staffRole, _adminRole],
      );
      final session = _makeSession(user);

      final result = computeRedirect(
        location: AppRoutes.dashboard,
        authStatus: AuthStatus.authenticated,
        session: session,
        roles: const [_staffRole, _adminRole],
        selectedRole: null,
        shopInitStatus: ShopInitStatus.idle,
      );

      expect(result, equals(AppRoutes.roleSelect),
          reason: 'multiple roles with no selection must redirect to /role-select');
    });

    test('authenticated + 2 roles + no selected role + /role-select → null', () {
      final user = _makeUser(
        isEmailVerified: true,
        roles: [_staffRole, _adminRole],
      );
      final session = _makeSession(user);

      final result = computeRedirect(
        location: AppRoutes.roleSelect,
        authStatus: AuthStatus.authenticated,
        session: session,
        roles: const [_staffRole, _adminRole],
        selectedRole: null,
        shopInitStatus: ShopInitStatus.idle,
      );

      expect(result, isNull,
          reason: 'already at /role-select must return null');
    });

    Glados(any.nonPublicRoute).test(
      'authenticated + multiple roles + no selected role + non-role-select → /role-select',
      (location) {
        if (location == AppRoutes.roleSelect) return; // skip

        final user = _makeUser(isEmailVerified: true);
        final session = _makeSession(user);

        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.authenticated,
          session: session,
          roles: const [_staffRole, _adminRole],
          selectedRole: null,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, equals(AppRoutes.roleSelect),
            reason: 'multiple roles with no selection must redirect to /role-select');
      },
    );
  });

  // -------------------------------------------------------------------------
  // Case 8: authenticated + single role + no selected role → null
  // -------------------------------------------------------------------------
  group('Property 9 — single role + no selected role → null (auto-select in progress)', () {
    Glados(any.nonPublicRoute).test(
      'authenticated + single role + no selected role → null',
      (location) {
        final user = _makeUser(isEmailVerified: true, roles: [_staffRole]);
        final session = _makeSession(user);

        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.authenticated,
          session: session,
          roles: const [_staffRole],
          selectedRole: null,
          shopInitStatus: ShopInitStatus.idle,
        );

        expect(result, isNull,
            reason: 'single role with no selection must return null (auto-select in progress)');
      },
    );
  });

  // -------------------------------------------------------------------------
  // Case 9: authenticated + non-superuser + /admin → /dashboard
  // -------------------------------------------------------------------------
  group('Property 9 — non-superuser + /admin → /dashboard', () {
    test('authenticated + non-superuser + /admin → /dashboard', () {
      final user = _makeUser(
        isSuperuser: false,
        isEmailVerified: true,
        roles: [_staffRole],
      );
      final session = _makeSession(user);

      final result = computeRedirect(
        location: AppRoutes.admin,
        authStatus: AuthStatus.authenticated,
        session: session,
        roles: const [_staffRole],
        selectedRole: _staffRole,
        shopInitStatus: ShopInitStatus.idle,
      );

      expect(result, equals(AppRoutes.dashboard),
          reason: 'non-superuser accessing /admin must be redirected to /dashboard');
    });

    test('authenticated + superuser + /admin → null (allow through)', () {
      final user = _makeUser(
        isSuperuser: true,
        isEmailVerified: true,
        roles: [_adminRole],
      );
      final session = _makeSession(user);

      final result = computeRedirect(
        location: AppRoutes.admin,
        authStatus: AuthStatus.authenticated,
        session: session,
        roles: const [_adminRole],
        selectedRole: _adminRole,
        shopInitStatus: ShopInitStatus.idle,
      );

      expect(result, isNull,
          reason: 'superuser accessing /admin must be allowed through');
    });
  });

  // -------------------------------------------------------------------------
  // Case 10: authenticated + shop_owner + shop not ready → /shop-init
  // -------------------------------------------------------------------------
  group('Property 9 — shop_owner + shop not ready → /shop-init', () {
    Glados(any.shopInitStatus).test(
      'shop_owner + non-ready shop init status + non-shop-init route → /shop-init',
      (shopInitStatus) {
        if (shopInitStatus == ShopInitStatus.ready) return; // skip ready case

        final user = _makeUser(
          isEmailVerified: true,
          roles: [_shopOwnerRole],
        );
        final session = _makeSession(user);

        final result = computeRedirect(
          location: AppRoutes.dashboard,
          authStatus: AuthStatus.authenticated,
          session: session,
          roles: const [_shopOwnerRole],
          selectedRole: _shopOwnerRole,
          shopInitStatus: shopInitStatus,
        );

        expect(result, equals(AppRoutes.shopInit),
            reason: 'shop_owner with non-ready shop must redirect to /shop-init');
      },
    );

    test('shop_owner + shop not ready + /shop-init → null (already there)', () {
      final user = _makeUser(
        isEmailVerified: true,
        roles: [_shopOwnerRole],
      );
      final session = _makeSession(user);

      final result = computeRedirect(
        location: AppRoutes.shopInit,
        authStatus: AuthStatus.authenticated,
        session: session,
        roles: const [_shopOwnerRole],
        selectedRole: _shopOwnerRole,
        shopInitStatus: ShopInitStatus.loading,
      );

      expect(result, isNull,
          reason: 'shop_owner already at /shop-init must return null');
    });
  });

  // -------------------------------------------------------------------------
  // Case 11: authenticated + shop_owner + shop ready → /shop-dashboard
  // -------------------------------------------------------------------------
  group('Property 9 — shop_owner + shop ready → /shop-dashboard', () {
    Glados(any.nonPublicRoute).test(
      'shop_owner + shop ready + non-shop-dashboard route → /shop-dashboard',
      (location) {
        if (location == AppRoutes.shopDashboard) return; // skip — already there

        final user = _makeUser(
          isEmailVerified: true,
          roles: [_shopOwnerRole],
        );
        final session = _makeSession(user);

        final result = computeRedirect(
          location: location,
          authStatus: AuthStatus.authenticated,
          session: session,
          roles: const [_shopOwnerRole],
          selectedRole: _shopOwnerRole,
          shopInitStatus: ShopInitStatus.ready,
        );

        expect(result, equals(AppRoutes.shopDashboard),
            reason: 'shop_owner with ready shop must redirect to /shop-dashboard');
      },
    );

    test('shop_owner + shop ready + /shop-dashboard → null (already there)', () {
      final user = _makeUser(
        isEmailVerified: true,
        roles: [_shopOwnerRole],
      );
      final session = _makeSession(user);

      final result = computeRedirect(
        location: AppRoutes.shopDashboard,
        authStatus: AuthStatus.authenticated,
        session: session,
        roles: const [_shopOwnerRole],
        selectedRole: _shopOwnerRole,
        shopInitStatus: ShopInitStatus.ready,
      );

      expect(result, isNull,
          reason: 'shop_owner already at /shop-dashboard must return null');
    });
  });
}
