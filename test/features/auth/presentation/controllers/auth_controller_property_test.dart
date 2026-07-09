// Feature: zoovana-auth-rbac-shop-init, Property 5: Auth state restoration from token presence
//
// Validates: Requirements 4.7, 17.2
//
// Property 5: Auth state restoration from token presence — for any combination
// of token present/absent in SecureStorageService, AuthController.onInit()
// transitions status from loading to authenticated (token present) or
// unauthenticated (token absent), never remaining loading after init completes.

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:glados/glados.dart';
import 'package:zoovana_cms/core/error/result.dart';
import 'package:zoovana_cms/core/storage/secure_storage_service.dart';
import 'package:zoovana_cms/features/auth/domain/entities/auth_session_entity.dart';
import 'package:zoovana_cms/features/auth/domain/entities/role_entity.dart';
import 'package:zoovana_cms/features/auth/domain/entities/user_entity.dart';
import 'package:zoovana_cms/features/auth/domain/repositories/auth_repository.dart';
import 'package:zoovana_cms/features/auth/domain/usecases/login_usecase.dart';
import 'package:zoovana_cms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:zoovana_cms/features/auth/presentation/controllers/auth_controller.dart';

// ---------------------------------------------------------------------------
// In-memory fake SecureStorageService
// (flutter_secure_storage requires platform channels; this fake stores tokens
// in a plain Dart map — same pattern as token_storage_property_test.dart)
// ---------------------------------------------------------------------------

class InMemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _store = {};

  static const _legacyTokenKey = 'auth_token';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> writeToken(String token) async {
    _store[_legacyTokenKey] = token;
  }

  @override
  Future<String?> readToken() async => _store[_legacyTokenKey];

  @override
  Future<void> deleteToken() async {
    _store.remove(_legacyTokenKey);
  }

  @override
  Future<String?> readAccessToken() async => _store[_accessTokenKey];

  @override
  Future<void> writeAccessToken(String token) async {
    _store[_accessTokenKey] = token;
  }

  @override
  Future<String?> readRefreshToken() async => _store[_refreshTokenKey];

  @override
  Future<void> writeRefreshToken(String token) async {
    _store[_refreshTokenKey] = token;
  }

  @override
  Future<void> deleteAllTokens() async {
    _store.remove(_accessTokenKey);
    _store.remove(_refreshTokenKey);
  }
}

// ---------------------------------------------------------------------------
// Fake AuthRepository — delegates to in-memory storage; no network calls
// ---------------------------------------------------------------------------

class FakeAuthRepository implements AuthRepository {
  final InMemorySecureStorageService _storage;

  FakeAuthRepository(this._storage);

  @override
  Future<Result<AuthSessionEntity>> login(String email, String password) async {
    final session = AuthSessionEntity(
      accessToken: 'fake_access_token',
      refreshToken: 'fake_refresh_token',
      expiresIn: 3600,
      user: UserEntity(
        id: '1',
        email: email,
        fullName: 'Test User',
        isSuperuser: false,
        isEmailVerified: true,
        roles: const [],
        defaultTenantId: 'tenant_1',
      ),
      status: AuthSessionStatus.active,
    );
    await _storage.writeAccessToken('fake_access_token');
    await _storage.writeRefreshToken('fake_refresh_token');
    return Success(session);
  }

  @override
  Future<Result<void>> logout() async {
    await _storage.deleteAllTokens();
    return const Success(null);
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    required String fullName,
    List<String> roleIds = const [],
    String? phoneNumber,
  }) async => const Success(null);

  @override
  Future<Result<void>> verifyEmail({
    required String email,
    required String otp,
  }) async => const Success(null);

  @override
  Future<Result<void>> resendVerification(String email) async =>
      const Success(null);

  @override
  Future<Result<void>> forgotPassword(String email) async =>
      const Success(null);

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String otp,
  }) async => const Success(null);

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async => const Success(null);

  @override
  Future<Result<String>> refreshToken(String refreshToken) async =>
      const Success('new_access_token');

  @override
  Future<Result<List<RoleEntity>>> getRoles() async =>
      const Success(<RoleEntity>[]);
}

// ---------------------------------------------------------------------------
// Helper: build a fresh AuthController with the given storage state
// ---------------------------------------------------------------------------

AuthController _buildController({
  required InMemorySecureStorageService storage,
}) {
  final repo = FakeAuthRepository(storage);
  return AuthController(
    loginUseCase: LoginUseCase(repo),
    logoutUseCase: LogoutUseCase(repo),
    secureStorage: storage,
  );
}

// ---------------------------------------------------------------------------
// Property 5 tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    // Clean up any registered GetX controllers between tests.
    Get.reset();
  });

  group('Property 5 — Auth state restoration from token presence', () {
    // -----------------------------------------------------------------------
    // 5a: status never remains loading after onInit() completes
    // -----------------------------------------------------------------------
    Glados(any.bool).test(
      'onInit() never leaves status as loading after completion',
      (tokenPresent) async {
        final storage = InMemorySecureStorageService();

        if (tokenPresent) {
          await storage.writeAccessToken('some_valid_token');
        }

        final controller = _buildController(storage: storage);

        // Manually trigger onInit (simulates GetX lifecycle in tests).
        controller.onInit();

        // Wait for the async _restoreSession() to complete.
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.status.value,
          isNot(AuthStatus.loading),
          reason:
              'status must not remain loading after onInit() completes '
              '(tokenPresent: $tokenPresent)',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 5b: token present → authenticated
    // -----------------------------------------------------------------------
    Glados(any.bool).test(
      'onInit() sets status to authenticated when a token is present',
      (tokenPresent) async {
        // Only run the "token present" branch of this property.
        if (!tokenPresent) return;

        final storage = InMemorySecureStorageService();
        await storage.writeAccessToken('some_valid_token');

        final controller = _buildController(storage: storage);
        controller.onInit();
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.status.value,
          equals(AuthStatus.authenticated),
          reason:
              'status must be authenticated when an access token is present',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 5c: no token → unauthenticated
    // -----------------------------------------------------------------------
    Glados(any.bool).test(
      'onInit() sets status to unauthenticated when no token is present',
      (tokenPresent) async {
        // Only run the "token absent" branch.
        if (tokenPresent) return;

        final storage = InMemorySecureStorageService();
        // Deliberately do NOT write any token.

        final controller = _buildController(storage: storage);
        controller.onInit();
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.status.value,
          equals(AuthStatus.unauthenticated),
          reason:
              'status must be unauthenticated when no access token is present',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 5d: combined — both branches in a single property
    // -----------------------------------------------------------------------
    Glados(any.bool).test(
      'onInit() transitions to authenticated xor unauthenticated based on token presence',
      (tokenPresent) async {
        final storage = InMemorySecureStorageService();

        if (tokenPresent) {
          await storage.writeAccessToken('token_abc123');
        }

        final controller = _buildController(storage: storage);
        controller.onInit();
        await Future<void>.delayed(Duration.zero);

        final expectedStatus = tokenPresent
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;

        expect(
          controller.status.value,
          equals(expectedStatus),
          reason:
              'tokenPresent=$tokenPresent should yield $expectedStatus, '
              'got ${controller.status.value}',
        );
      },
    );
  });
}
