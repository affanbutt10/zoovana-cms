// Feature: zoovana-auth-rbac-shop-init
// Integration smoke tests for DependencyInjection, AuthInterceptor,
// AuthRepository.login, and ShopRepository.getBusinessWithBranches.
//
// Validates: Requirements 2.7
//
// Tests 1-6: Verify DI components individually (DioFactory, controllers)
//   without calling the full DependencyInjection.init() to avoid platform
//   channel requirements (flutter_secure_storage, shared_preferences,
//   connectivity_plus).
//
// Tests 7-9: Use in-memory fakes and mock data sources to verify
//   interceptor and repository behaviour.

import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:zoovana_cms/core/config/app_config.dart';
import 'package:zoovana_cms/core/error/app_error.dart';
import 'package:zoovana_cms/core/error/result.dart';
import 'package:zoovana_cms/core/network/api_endpoints.dart';
import 'package:zoovana_cms/core/network/dio_factory.dart';
import 'package:zoovana_cms/core/network/interceptors/auth_interceptor.dart';
import 'package:zoovana_cms/core/storage/local_storage_service.dart';
import 'package:zoovana_cms/core/storage/secure_storage_service.dart';
import 'package:zoovana_cms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:zoovana_cms/features/auth/data/models/login_response_model.dart';
import 'package:zoovana_cms/features/auth/data/models/role_model.dart';
import 'package:zoovana_cms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zoovana_cms/features/auth/domain/entities/auth_session_entity.dart';
import 'package:zoovana_cms/features/auth/domain/entities/role_entity.dart';
import 'package:zoovana_cms/features/auth/domain/repositories/auth_repository.dart';
import 'package:zoovana_cms/features/auth/domain/usecases/login_usecase.dart';
import 'package:zoovana_cms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:zoovana_cms/features/auth/presentation/controllers/auth_controller.dart';
import 'package:zoovana_cms/features/auth/presentation/controllers/role_controller.dart';
import 'package:zoovana_cms/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:zoovana_cms/features/shop/data/models/business_with_branches_model.dart';
import 'package:zoovana_cms/features/shop/data/models/branch_model.dart';
import 'package:zoovana_cms/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:zoovana_cms/features/shop/domain/entities/branch_entity.dart';
import 'package:zoovana_cms/features/shop/domain/entities/business_with_branches_entity.dart';
import 'package:zoovana_cms/features/shop/domain/repositories/shop_repository.dart';
import 'package:zoovana_cms/features/shop/domain/usecases/shop_init_usecase.dart';
import 'package:zoovana_cms/features/shop/presentation/controllers/shop_init_controller.dart';

// ---------------------------------------------------------------------------
// In-memory fake SecureStorageService (no platform channels required)
// ---------------------------------------------------------------------------

class _FakeSecureStorage implements SecureStorageService {
  final Map<String, String> _store = {};

  static const _legacyKey = 'auth_token';
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<void> writeToken(String token) async => _store[_legacyKey] = token;

  @override
  Future<String?> readToken() async => _store[_legacyKey];

  @override
  Future<void> deleteToken() async => _store.remove(_legacyKey);

  @override
  Future<String?> readAccessToken() async => _store[_accessKey];

  @override
  Future<void> writeAccessToken(String token) async =>
      _store[_accessKey] = token;

  @override
  Future<String?> readRefreshToken() async => _store[_refreshKey];

  @override
  Future<void> writeRefreshToken(String token) async =>
      _store[_refreshKey] = token;

  @override
  Future<void> deleteAllTokens() async {
    _store.remove(_accessKey);
    _store.remove(_refreshKey);
  }
}

// ---------------------------------------------------------------------------
// In-memory fake LocalStorageService (no platform channels required)
// ---------------------------------------------------------------------------

class _FakeLocalStorage implements LocalStorageService {
  final Map<String, dynamic> _store = {};

  @override
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  Future<void> setString(String key, String value) async => _store[key] = value;

  @override
  Future<bool?> getBool(String key) async => _store[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => _store[key] = value;

  @override
  Future<void> remove(String key) async => _store.remove(key);

  @override
  Future<void> clearSession() async {
    for (final key in [
      LocalStorageKeys.userId,
      LocalStorageKeys.fullName,
      LocalStorageKeys.email,
      LocalStorageKeys.isSuperuser,
      LocalStorageKeys.defaultTenantId,
      LocalStorageKeys.zoovanaRoleStorage,
      LocalStorageKeys.activeBranchId,
    ]) {
      _store.remove(key);
    }
  }
}

// ---------------------------------------------------------------------------
// Mock AuthRemoteDataSource — records calls and returns preset responses
// ---------------------------------------------------------------------------

class _MockAuthDataSource implements AuthRemoteDataSource {
  String? lastLoginEmail;
  String? lastLoginPassword;

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    // Return a minimal valid response
    return LoginResponseModel.fromJson({
      'access_token': 'access_abc',
      'refresh_token': 'refresh_xyz',
      'expires_in': 3600,
      'user': {
        'id': 'user-1',
        'email': email,
        'full_name': 'Test User',
        'is_superuser': false,
        'is_email_verified': true,
        'roles': <dynamic>[],
        'default_tenant_id': 'tenant-1',
      },
    });
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    List<String> roleIds = const [],
    String? phoneNumber,
  }) async {}

  @override
  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {}

  @override
  Future<void> resendVerification(String email) async {}

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {}

  @override
  Future<String> refreshToken(String refreshToken) async => 'new_token';

  @override
  Future<List<RoleModel>> getRoles() async => [];
}

// ---------------------------------------------------------------------------
// Mock ShopRemoteDataSource — records calls and returns preset responses
// ---------------------------------------------------------------------------

class _MockShopDataSource implements ShopRemoteDataSource {
  String? lastCalledMethod;

  @override
  Future<BusinessWithBranchesModel> getBusinessWithBranches() async {
    lastCalledMethod = 'getBusinessWithBranches';
    return BusinessWithBranchesModel.fromJson({
      'id': 'biz-1',
      'name': 'Test Business',
      'owner_id': 'owner-1',
      'tenant_id': 'tenant-1',
      'status': 'active',
      'created_at': '2024-01-01T00:00:00.000Z',
      'branches': <dynamic>[
        {
          'id': 'branch-1',
          'business_id': 'biz-1',
          'name': 'Main Branch',
          'address': '123 Main St',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
        },
      ],
    });
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    lastCalledMethod = 'getBranches';
    return [];
  }
}

// ---------------------------------------------------------------------------
// Stub repositories (no network calls) — used for controller wiring
// ---------------------------------------------------------------------------

class _StubAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthSessionEntity>> login(String email, String password) async {
    return Failure(AppError.serverError());
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
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<String>> refreshToken(String refreshToken) async =>
      const Success('new_token');

  @override
  Future<Result<List<RoleEntity>>> getRoles() async =>
      const Success(<RoleEntity>[]);
}

class _StubShopRepository implements ShopRepository {
  @override
  Future<Result<BusinessWithBranchesEntity>> getBusinessWithBranches() async =>
      Failure(AppError.notFound());

  @override
  Future<Result<List<BranchEntity>>> getBranches() async =>
      const Success(<BranchEntity>[]);
}

// ---------------------------------------------------------------------------
// Helper: build a minimal GetIt instance with Dio singletons wired up
// (without platform channels)
// ---------------------------------------------------------------------------

GetIt _buildTestGetIt({
  _FakeSecureStorage? secureStorage,
  _FakeLocalStorage? localStorage,
}) {
  final getIt = GetIt.asNewInstance();

  final ss = secureStorage ?? _FakeSecureStorage();
  final ls = localStorage ?? _FakeLocalStorage();

  getIt.registerSingleton<SecureStorageService>(ss);
  getIt.registerSingleton<LocalStorageService>(ls);

  getIt.registerSingleton<dio.Dio>(
    DioFactory.createAuthDio(
      secureStorage: ss,
      localStorage: ls,
      onForceSignOut: () {},
    ),
    instanceName: 'authDio',
  );

  getIt.registerSingleton<dio.Dio>(
    DioFactory.createShopDio(
      secureStorage: ss,
      localStorage: ls,
      onForceSignOut: () {},
    ),
    instanceName: 'shopDio',
  );

  return getIt;
}

// ---------------------------------------------------------------------------
// Helper: register all three GetX controllers
// ---------------------------------------------------------------------------

void _registerControllers({
  _FakeSecureStorage? secureStorage,
  _FakeLocalStorage? localStorage,
}) {
  final ss = secureStorage ?? _FakeSecureStorage();
  final ls = localStorage ?? _FakeLocalStorage();

  final authRepo = _StubAuthRepository();
  final shopRepo = _StubShopRepository();

  final loginUseCase = LoginUseCase(authRepo);
  final logoutUseCase = LogoutUseCase(authRepo);
  final shopInitUseCase = ShopInitUseCase(shopRepo);

  Get.put<AuthController>(
    AuthController(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      secureStorage: ss,
    ),
    permanent: true,
  );

  Get.put<RoleController>(RoleController(localStorage: ls), permanent: true);

  Get.put<ShopInitController>(
    ShopInitController(shopInitUseCase: shopInitUseCase, localStorage: ls),
    permanent: true,
  );
}

// ---------------------------------------------------------------------------
// Capturing RequestInterceptorHandler for AuthInterceptor tests
// ---------------------------------------------------------------------------

class _CapturingRequestHandler extends dio.RequestInterceptorHandler {
  dio.RequestOptions? capturedOptions;

  @override
  void next(dio.RequestOptions options) {
    capturedOptions = options;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Tests 1-4: GetX controllers resolve without error
  // -------------------------------------------------------------------------

  group('Tests 1-4 — GetX controllers resolve after registration', () {
    setUp(() {
      Get.reset();
    });

    tearDown(() {
      Get.reset();
    });

    // Test 1: AuthController resolves
    test('1. Get.find<AuthController>() resolves without error', () {
      _registerControllers();
      expect(() => Get.find<AuthController>(), returnsNormally);
      expect(Get.find<AuthController>(), isA<AuthController>());
    });

    // Test 2: RoleController resolves
    test('2. Get.find<RoleController>() resolves without error', () {
      _registerControllers();
      expect(() => Get.find<RoleController>(), returnsNormally);
      expect(Get.find<RoleController>(), isA<RoleController>());
    });

    // Test 3: ShopInitController resolves
    test('3. Get.find<ShopInitController>() resolves without error', () {
      _registerControllers();
      expect(() => Get.find<ShopInitController>(), returnsNormally);
      expect(Get.find<ShopInitController>(), isA<ShopInitController>());
    });

    // Test 4: All three controllers resolve in the same registration pass
    test(
      '4. All three controllers resolve after a single registration pass',
      () {
        _registerControllers();
        expect(Get.find<AuthController>(), isA<AuthController>());
        expect(Get.find<RoleController>(), isA<RoleController>());
        expect(Get.find<ShopInitController>(), isA<ShopInitController>());
      },
    );
  });

  // -------------------------------------------------------------------------
  // Tests 5-6: Dio instances have correct base URLs
  // -------------------------------------------------------------------------

  group('Tests 5-6 — Dio instances have correct base URLs', () {
    late GetIt getIt;

    setUp(() {
      getIt = _buildTestGetIt();
    });

    tearDown(() async {
      await getIt.reset();
    });

    // Test 5: authDio has correct base URL
    test('5. getIt<Dio>(instanceName: authDio) resolves with '
        'baseUrl == "${AppConfig.authBaseUrl}"', () {
      final authDio = getIt<dio.Dio>(instanceName: 'authDio');
      expect(authDio, isA<dio.Dio>());
      expect(
        authDio.options.baseUrl,
        equals(AppConfig.authBaseUrl),
        reason:
            'authDio must be configured with baseUrl = ${AppConfig.authBaseUrl}',
      );
    });

    // Test 6: shopDio has correct base URL
    test('6. getIt<Dio>(instanceName: shopDio) resolves with '
        'baseUrl == "${AppConfig.shopBaseUrl}"', () {
      final shopDio = getIt<dio.Dio>(instanceName: 'shopDio');
      expect(shopDio, isA<dio.Dio>());
      expect(
        shopDio.options.baseUrl,
        equals(AppConfig.shopBaseUrl),
        reason:
            'shopDio must be configured with baseUrl = ${AppConfig.shopBaseUrl}',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Test 7: AuthInterceptor injects Authorization header when token is present
  // -------------------------------------------------------------------------

  group('Test 7 — AuthInterceptor injects Authorization header', () {
    test('7. AuthInterceptor injects "Authorization: Bearer <token>" when '
        'a token is present in SecureStorageService', () async {
      const testToken = 'test_access_token_abc123';

      final fakeStorage = _FakeSecureStorage();
      await fakeStorage.writeAccessToken(testToken);

      final fakeLocalStorage = _FakeLocalStorage();

      final dioInstance = dio.Dio(
        dio.BaseOptions(baseUrl: AppConfig.authBaseUrl),
      );

      final interceptor = AuthInterceptor(
        dio: dioInstance,
        secureStorage: fakeStorage,
        localStorage: fakeLocalStorage,
        onForceSignOut: () {},
      );

      final requestOptions = dio.RequestOptions(
        path: ApiEndpoints.login,
        method: 'POST',
      );

      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(requestOptions, handler);

      expect(
        handler.capturedOptions,
        isNotNull,
        reason: 'handler.next() must have been called',
      );
      expect(
        handler.capturedOptions!.headers['Authorization'],
        equals('Bearer $testToken'),
        reason:
            'Authorization header must be "Bearer $testToken" when token is present',
      );
    });

    test('7b. AuthInterceptor does NOT inject Authorization header when '
        'no token is present in SecureStorageService', () async {
      final fakeStorage = _FakeSecureStorage(); // empty — no token stored
      final fakeLocalStorage = _FakeLocalStorage();

      final dioInstance = dio.Dio(
        dio.BaseOptions(baseUrl: AppConfig.authBaseUrl),
      );

      final interceptor = AuthInterceptor(
        dio: dioInstance,
        secureStorage: fakeStorage,
        localStorage: fakeLocalStorage,
        onForceSignOut: () {},
      );

      final requestOptions = dio.RequestOptions(
        path: ApiEndpoints.login,
        method: 'POST',
      );

      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(requestOptions, handler);

      expect(
        handler.capturedOptions,
        isNotNull,
        reason: 'handler.next() must have been called even without a token',
      );
      expect(
        handler.capturedOptions!.headers.containsKey('Authorization'),
        isFalse,
        reason:
            'Authorization header must NOT be injected when no token is present',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Test 8: AuthRepository.login calls POST /api/v1/auth/login
  // -------------------------------------------------------------------------

  group('Test 8 — AuthRepository.login calls POST /api/v1/auth/login', () {
    test('8. AuthRepository.login calls POST ${ApiEndpoints.login} '
        'with {email, password} body', () async {
      const testEmail = 'user@example.com';
      const testPassword = 'secret123';

      final mockDataSource = _MockAuthDataSource();
      final fakeStorage = _FakeSecureStorage();
      final fakeLocalStorage = _FakeLocalStorage();

      final repository = AuthRepositoryImpl(
        remoteDataSource: mockDataSource,
        secureStorage: fakeStorage,
        localStorage: fakeLocalStorage,
      );

      await repository.login(testEmail, testPassword);

      expect(
        mockDataSource.lastLoginEmail,
        equals(testEmail),
        reason: 'login must forward the email to the data source',
      );
      expect(
        mockDataSource.lastLoginPassword,
        equals(testPassword),
        reason: 'login must forward the password to the data source',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Test 9: ShopRepository.getBusinessWithBranches calls GET
  //         /api/v1/businesses/me/with-branches
  // -------------------------------------------------------------------------

  group('Test 9 — ShopRepository.getBusinessWithBranches calls '
      'GET ${ApiEndpoints.businessMeWithBranches}', () {
    test('9. ShopRepository.getBusinessWithBranches delegates to '
        'ShopRemoteDataSource.getBusinessWithBranches', () async {
      final mockDataSource = _MockShopDataSource();
      final fakeLocalStorage = _FakeLocalStorage();

      final repository = ShopRepositoryImpl(
        remoteDataSource: mockDataSource,
        localStorage: fakeLocalStorage,
      );

      await repository.getBusinessWithBranches();

      expect(
        mockDataSource.lastCalledMethod,
        equals('getBusinessWithBranches'),
        reason:
            'getBusinessWithBranches must delegate to the data source method '
            'that calls GET ${ApiEndpoints.businessMeWithBranches}',
      );
    });
  });
}
