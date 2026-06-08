# Implementation Plan: Zoovana Auth, RBAC, Tenant & Shop Init

## Overview

Implement four tightly coupled Flutter flows — Authentication, RBAC, Tenant/Approval, and Shop Owner Initialization — following Clean Architecture. Each task builds on the previous, starting from `pubspec.yaml` dependencies and ending with GoRouter wiring and property-based tests. All code is Dart/Flutter using GetX, GoRouter, Dio, and get_it.

## Tasks

- [x] 1. Add required dependencies to pubspec.yaml
  - Add `get: ^4.6.6`, `go_router: ^14.0.0`, `get_it: ^8.0.0`, `synchronized: ^3.1.0` to the `dependencies` section
  - Verify `dio: ^5.4.0`, `flutter_secure_storage: ^10.0.0`, `shared_preferences: ^2.2.2`, and `logger: ^2.0.2` are already present (they are); add any that are missing
  - Remove `flutter_riverpod` from `pubspec.yaml` if present (replaced by GetX)
  - Add `glados` to `dev_dependencies` for property-based testing
  - Run `flutter pub get` to resolve the dependency graph
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8_

- [x] 2. Implement core error types: AppError and Result
  - [x] 2.1 Create `lib/core/error/app_error.dart` with the `AppError` class
    - Implement all nine boolean flag fields (`badRequest`, `unauthorized`, `forbidden`, `notFound`, `conflict`, `validationErrors`, `serverError`, `networkError`, `cancelled`)
    - Implement all named factory constructors (`AppError.badRequest`, `.unauthorized`, `.forbidden`, `.notFound`, `.conflict`, `.validationError`, `.serverError`, `.network`, `.cancelled`)
    - _Requirements: 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13_
  - [x] 2.2 Create `lib/core/error/result.dart` with the `Result<T>` sealed class
    - Implement `Success<T>` and `Failure<T>` subclasses
    - Implement `ResultExtension` with `isSuccess`, `isFailure`, `data`, `error`, and `when` helpers
    - _Requirements: 5.3, 5.4_
  - [x] 2.3 Write property test for Result exhaustiveness (Property 1)
    - **Property 1: Result exhaustiveness** — for any `Result<T>`, `when(success:, failure:)` invokes exactly one callback and returns its value
    - **Validates: Requirements 5.3, 5.4**
  - [x] 2.4 Write property test for AppError flag exclusivity (Property 2)
    - **Property 2: AppError flag exclusivity** — for any `AppError` constructed via a named factory, exactly one boolean flag is `true` and all others are `false`
    - **Validates: Requirements 3.5–3.13**

- [x] 3. Implement storage services
  - [x] 3.1 Create `lib/core/storage/secure_storage_service.dart`
    - Define abstract `SecureStorageService` interface with `readAccessToken()`, `writeAccessToken(String)`, `readRefreshToken()`, `writeRefreshToken(String)`, `deleteAllTokens()`
    - Implement `SecureStorageServiceImpl` using `flutter_secure_storage` with keys `access_token` and `refresh_token`
    - _Requirements: 4.1, 4.2, 4.4, 4.5_
  - [x] 3.2 Create `lib/core/storage/local_storage_service.dart`
    - Define abstract `LocalStorageService` interface with `getString`, `setString`, `getBool`, `setBool`, `remove`, `clearSession`
    - Implement `LocalStorageServiceImpl` using `shared_preferences`; `clearSession` removes keys: `user_id`, `full_name`, `email`, `is_superuser`, `default_tenant_id`, `zoovana_role_storage`, `active_branch_id`
    - _Requirements: 4.3, 4.6, 10.4_
  - [x] 3.3 Write property test for token storage round-trip (Property 4)
    - **Property 4: Token storage round-trip** — for any non-empty token string, `writeAccessToken` then `readAccessToken` returns the original string (and same for refresh token)
    - **Validates: Requirements 4.1, 4.2, 9.2**

- [x] 4. Implement core utilities and app config
  - Create `lib/core/config/app_config.dart` with `authBaseUrl = 'http://161.35.222.194:8001'`, `shopBaseUrl = 'http://161.35.222.194:8012'`, and timeout constants
  - Create `lib/core/network/api_endpoints.dart` with all URL path constants: `/api/v1/auth/login`, `/api/v1/auth/register`, `/api/v1/auth/verify-email`, `/api/v1/auth/resend-verification`, `/api/v1/auth/forgot-password`, `/api/v1/auth/verify-otp`, `/api/v1/auth/reset-password`, `/api/v1/auth/change-password`, `/api/v1/auth/refresh`, `/api/v1/roles`, `/api/v1/users/me/profile`, `/api/v1/businesses/me`, `/api/v1/businesses/me/with-branches`, `/api/v1/branches`
  - Create `lib/core/utils/app_logger.dart` as a singleton wrapper around the `logger` package
  - Create `lib/core/utils/jwt_utils.dart` with `isTokenExpiringSoon(String token, {int thresholdSeconds = 600})` that decodes the JWT `exp` claim without verification and returns `true` if expiry is within the threshold
  - _Requirements: 2.1, 2.2, 9.1_

- [x] 5. Implement Dio interceptors
  - [x] 5.1 Create `lib/core/network/interceptors/locale_interceptor.dart`
    - Read `WidgetsBinding.instance.platformDispatcher.locale.languageCode`; inject `Accept-Language: ar` if `ar`, otherwise `Accept-Language: en`
    - _Requirements: 3.1_
  - [x] 5.2 Create `lib/core/network/interceptors/logger_interceptor.dart`
    - In `onRequest` (debug mode only): log HTTP method, URI, headers, and body; store `startTime` in `options.extra`
    - In `onResponse` (debug mode only): log status code, URI, and elapsed milliseconds
    - _Requirements: 3.2, 3.3_
  - [x] 5.3 Create `lib/core/network/interceptors/error_interceptor.dart`
    - Map `DioExceptionType.cancel` → `AppError.cancelled()`
    - Map null response → `AppError.network()`
    - Map status codes 400, 401, 403, 404, 409, 422, 500 to the corresponding `AppError` factory; extract message from `detail` or `message` field; for 422 build the `errors` map from `detail[].loc` and `detail[].msg`
    - Re-throw as `DioException` with `error: appError`
    - _Requirements: 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13_
  - [x] 5.4 Write property test for ErrorInterceptor status-to-flag mapping (Property 3)
    - **Property 3: ErrorInterceptor maps status codes to correct AppError flags** — for each status in {400, 401, 403, 404, 409, 422, 500}, the interceptor produces an `AppError` with the correct flag `true`, correct `status` field, and all other flags `false`
    - **Validates: Requirements 3.5–3.11**
  - [x] 5.5 Create `lib/core/network/interceptors/auth_interceptor.dart`
    - In `onRequest`: read `access_token` from `SecureStorageService`; if present, inject `Authorization: Bearer <token>` header
    - In `onError`: if `appError.unauthorized` is false, pass through; if the failing path contains `/auth/refresh`, call `_clearSessionAndSignOut()` and pass through
    - Otherwise: acquire `Lock`, call `_refreshToken()`, write new token to `SecureStorageService`, release lock, retry original request with new token
    - If refresh returns null, call `_clearSessionAndSignOut()` and pass through
    - `_clearSessionAndSignOut()` deletes all tokens and clears session from `LocalStorageService`; also calls a `onForceSignOut` callback (injected at construction) to notify `AuthNotifier`
    - _Requirements: 3.14, 3.15, 3.16, 9.3, 9.4, 9.5_

- [x] 6. Implement DioFactory and wire the service locator
  - [x] 6.1 Create `lib/core/network/dio_factory.dart`
    - `createAuthDio`: `BaseOptions(baseUrl: AppConfig.authBaseUrl, connectTimeout: 30s, receiveTimeout: 30s, headers: {Content-Type, Accept})`, add interceptors in order: `LocaleInterceptor`, `LoggerInterceptor`, `ErrorInterceptor`, `AuthInterceptor`
    - `createShopDio`: same structure with `AppConfig.shopBaseUrl`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  - [x] 6.2 Update `lib/core/di/dependency_injection.dart`
    - Register `SecureStorageServiceImpl` and `LocalStorageServiceImpl` as singletons first
    - Register `authDio` and `shopDio` as named singletons using `DioFactory`
    - Register `AuthRemoteDataSource`, `ShopRemoteDataSource`, `AuthRepository`, `ShopRepository` as lazy singletons in `get_it`
    - Register all use cases in `get_it`: `LoginUseCase`, `RegisterUseCase`, `VerifyEmailUseCase`, `ForgotPasswordUseCase`, `ResetPasswordUseCase`, `LogoutUseCase`, `RefreshTokenUseCase`, `ShopInitUseCase`
    - Register GetX controllers via `Get.put()`: `AuthController`, `RoleController`, `ShopInitController` — in that order, after all use cases are registered
    - Wire `AuthInterceptor.onForceSignOut` callback to `() => Get.find<AuthController>().forceSignOut()`
    - _Requirements: 2.6, 2.7_

- [x] 7. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement auth data layer
  - [x] 8.1 Create auth data models in `lib/features/auth/data/models/`
    - `login_request_model.dart`: `LoginRequestModel` with `toJson()` producing `{email, password}`
    - `role_model.dart`: `RoleModel.fromJson()` parsing `id`, `name`, `scope`; `toEntity()` returning `RoleEntity`
    - `user_model.dart`: `UserModel.fromJson()` parsing all fields including nested `roles` list; `toEntity()` returning `UserEntity`
    - `login_response_model.dart`: `LoginResponseModel.fromJson()` parsing `access_token`, `refresh_token`, `expires_in`, nested `user`; `toEntity()` returning `AuthSessionEntity(status: AuthSessionStatus.active)`
    - _Requirements: 16.1, 16.2, 16.3, 16.4_
  - [x] 8.2 Write property test for RoleModel round-trip (Property 6)
    - **Property 6: RoleModel parsing round-trip** — for any valid role JSON with string `id`, `name`, `scope`, `RoleModel.fromJson(json).toEntity()` produces a `RoleEntity` with equal field values
    - **Validates: Requirements 10.2, 16.4**
  - [x] 8.3 Write property test for LoginResponseModel full round-trip (Property 7)
    - **Property 7: LoginResponseModel full round-trip** — for any valid login response JSON with N role objects, `LoginResponseModel.fromJson(json).toEntity()` preserves `accessToken`, `refreshToken`, `user.isSuperuser`, and `user.roles.length == N`
    - **Validates: Requirements 16.2, 16.3, 16.8, 16.9**
  - [x] 8.4 Create `lib/features/auth/data/datasources/auth_remote_datasource.dart`
    - Define abstract `AuthRemoteDataSource` interface
    - Implement `AuthRemoteDataSourceImpl` with methods: `login(email, password)` → `POST /api/v1/auth/login`, `register(...)` → `POST /api/v1/auth/register`, `verifyEmail(email, otp)` → `POST /api/v1/auth/verify-email`, `resendVerification(email)` → `POST /api/v1/auth/resend-verification`, `forgotPassword(email)` → `POST /api/v1/auth/forgot-password`, `verifyOtp(email, otp)` → `POST /api/v1/auth/verify-otp`, `resetPassword(...)` → `POST /api/v1/auth/reset-password`, `refreshToken(refreshToken)` → `POST /api/v1/auth/refresh`, `getRoles()` → `GET /api/v1/roles`
    - Each method catches `DioException`, extracts `AppError` from `err.error`, and rethrows or returns the error
    - _Requirements: 5.1, 6.1, 7.1, 7.3, 8.1, 8.2, 8.3, 9.1_
  - [x] 8.5 Create `lib/features/auth/data/repositories/auth_repository_impl.dart`
    - Implement `AuthRepository` interface
    - `login`: call datasource, on success store `access_token` and `refresh_token` via `SecureStorageService`, store `user_id`, `full_name`, `email`, `is_superuser`, `default_tenant_id` via `LocalStorageService`, return `Result.success(session.toEntity())`; on failure return `Result.failure(appError)`
    - `register`: call datasource, return `Result.success(void)` or `Result.failure`
    - `verifyEmail`, `resendVerification`, `forgotPassword`, `verifyOtp`, `resetPassword`: delegate to datasource, wrap in `Result`
    - `logout`: delete all tokens via `SecureStorageService`, clear session via `LocalStorageService`, return `Result.success(void)`
    - `refreshToken`: call datasource, return `Result.success(newToken)` or `Result.failure`
    - `getRoles`: call datasource, map response to `List<RoleEntity>`, return `Result.success(roles)`
    - _Requirements: 5.3, 5.4, 5.5, 6.2, 6.3, 7.2, 7.4, 8.4, 9.2, 13.1_

- [x] 9. Implement auth domain layer
  - Create all domain entities in `lib/features/auth/domain/entities/`:
    - `role_entity.dart`: `RoleEntity` with `id`, `name`, `scope`
    - `user_entity.dart`: `UserEntity` with `id`, `email`, `fullName`, `isSuperuser`, `isEmailVerified`, `roles`, `defaultTenantId`
    - `auth_session_entity.dart`: `AuthSessionStatus` enum (`active`, `pendingApproval`); `AuthSessionEntity` with `accessToken`, `refreshToken`, `expiresIn`, `user`, `status`
  - Create `lib/features/auth/domain/repositories/auth_repository.dart` abstract interface matching the full method signature from the design
  - Create all use cases in `lib/features/auth/domain/usecases/`: `LoginUseCase`, `RegisterUseCase`, `VerifyEmailUseCase`, `ForgotPasswordUseCase`, `ResetPasswordUseCase`, `LogoutUseCase`, `RefreshTokenUseCase` — each is a single-method class delegating to `AuthRepository`
  - _Requirements: 16.5, 16.6, 16.7_

- [x] 10. Implement auth presentation layer
  - [x] 10.1 Create `lib/features/auth/presentation/controllers/auth_controller.dart`
    - Define `AuthStatus` enum with values: `loading`, `unauthenticated`, `authenticated`, `pendingApproval`
    - Implement `AuthController extends GetxController` with:
      - `Rx<AuthStatus> status = AuthStatus.loading.obs`
      - `Rxn<AuthSessionEntity> session = Rxn()`
      - `_restoreSession()` called in `onInit()`: reads `access_token` from `SecureStorageService`; sets `status` to `authenticated` or `unauthenticated`
      - `login(email, password)`: sets `status = loading`, calls `LoginUseCase`, on success sets `session` and `status = authenticated` (or `pendingApproval`), on failure sets `status = unauthenticated`
      - `logout()`: calls `LogoutUseCase`, clears `session`, sets `status = unauthenticated`
      - `forceSignOut()`: clears tokens via `SecureStorageService`, sets `status = unauthenticated` — called by `AuthInterceptor` on unrecoverable 401
    - Register `AuthController` via `Get.put()` in `DependencyInjection.init()` so it is globally accessible via `Get.find<AuthController>()`
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 17.6_
  - [x] 10.2 Write property test for auth state restoration (Property 5)
    - **Property 5: Auth state restoration from token presence** — for any combination of token present/absent in `SecureStorageService`, `AuthController.onInit()` transitions `status` from `loading` to `authenticated` (token present) or `unauthenticated` (token absent), never remaining `loading` after init completes
    - **Validates: Requirements 4.7, 17.2**
  - [x] 10.3 Create `lib/features/auth/presentation/controllers/role_controller.dart`
    - Implement `RoleController extends GetxController` with:
      - `RxList<RoleEntity> roles = <RoleEntity>[].obs`
      - `Rxn<RoleEntity> selectedRole = Rxn()`
      - `setRoles(List<RoleEntity>)`: updates `roles`; auto-calls `setSelectedRole(roles.first)` if length == 1
      - `setSelectedRole(RoleEntity)`: updates `selectedRole`, persists `role.id` to `LocalStorageService` under key `zoovana_role_storage`
      - `clearSelectedRole()`: sets `selectedRole` to null, removes `zoovana_role_storage` from `LocalStorageService`
      - `getSelectedRoleId()` and `getSelectedRoleName()` getters
      - `onInit()`: restores `selectedRole` from `LocalStorageService` if key exists and `roles` is non-empty
    - Register `RoleController` via `Get.put()` in `DependencyInjection.init()`
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_
  - [x] 10.4 Write property test for role persistence round-trip (Property 11)
    - **Property 11: Role persistence round-trip** — for any `RoleEntity`, calling `setSelectedRole` persists the role's `id` to `LocalStorageService` under `zoovana_role_storage`, and reading that key returns the same `id`
    - **Validates: Requirements 10.4**
  - [x] 10.5 Create auth screens in `lib/features/auth/presentation/screens/`
    - `login_screen.dart`: email + password form with inline validation (empty field, invalid email format); disable submit button while `AuthController.status == loading` using `Obx`; display `AppError` messages per the error display rules; on submit call `Get.find<AuthController>().login(email, password)`
    - `register_screen.dart`: registration form with role selector that calls `GET /api/v1/roles` via `getRoles` use case; show loading indicator in role field while fetching; on success navigate to `/verify-email` via `Get.toNamed` or GoRouter
    - `verify_email_screen.dart`: OTP input field; resend button calls `resendVerification`; on success navigate to `/login`; display `badRequest` error inline
    - `forgot_password_screen.dart`: email field; on submit call `ForgotPasswordUseCase`; navigate to reset password screen
    - `reset_password_screen.dart`: OTP + new password fields; call `VerifyOtpUseCase` then `ResetPasswordUseCase`; on success navigate to `/login`
    - `pending_approval_screen.dart`: status message; logout button calls `Get.find<AuthController>().logout()`; refresh button calls `GET /api/v1/users/me/profile` and updates `AuthController.status` if approved
    - _Requirements: 5.6, 5.7, 5.8, 6.4, 6.5, 7.2, 7.4, 8.4, 13.4, 13.5, 13.6, 20.1, 20.2, 20.3, 20.4, 20.5, 20.6, 20.7_

- [x] 11. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 12. Implement shop data layer
  - [x] 12.1 Create shop data models in `lib/features/shop/data/models/`
    - `business_model.dart`: `BusinessModel.fromJson()` parsing `id`, `name`, `owner_id`, `tenant_id`, `status`, `created_at` (as `DateTime.parse`); `toEntity()` returning `BusinessEntity`
    - `branch_model.dart`: `BranchModel.fromJson()` parsing `id`, `business_id`, `name`, `address` (nullable), `is_active`, `created_at`; `toEntity()` returning `BranchEntity`
    - `business_with_branches_model.dart`: `BusinessWithBranchesModel.fromJson()` parsing business fields plus `branches` list of `BranchModel`; `toEntity()` returning `BusinessWithBranchesEntity`
    - _Requirements: 15.1, 15.2, 15.3, 15.4_
  - [x] 12.2 Write property test for BusinessWithBranchesModel round-trip (Property 8)
    - **Property 8: BusinessWithBranchesModel round-trip preserves branch count and IDs** — for any valid JSON with M branch objects, `BusinessWithBranchesModel.fromJson(json).toEntity()` produces an entity where `branches.length == M` and every `branches[i].id` equals `json['branches'][i]['id']`
    - **Validates: Requirements 15.3, 15.5**
  - [x] 12.3 Create `lib/features/shop/data/datasources/shop_remote_datasource.dart`
    - Define abstract `ShopRemoteDataSource` interface
    - Implement `ShopRemoteDataSourceImpl` with: `getBusinessWithBranches()` → `GET /api/v1/businesses/me/with-branches`, `getBranches()` → `GET /api/v1/branches`
    - Catch `DioException`, extract `AppError`, rethrow
    - _Requirements: 14.2, 14.3, 14.8_
  - [x] 12.4 Create `lib/features/shop/data/repositories/shop_repository_impl.dart`
    - Implement `ShopRepository` interface
    - `getBusinessWithBranches()`: call datasource, on success store `branches[0].id` as `active_branch_id` in `LocalStorageService`, return `Result.success(entity)`; on 404 return `Result.failure(AppError.notFound(...))`
    - `getBranches()`: call datasource, return `Result.success(List<BranchEntity>)` or `Result.failure`
    - _Requirements: 14.2, 14.3, 14.4, 14.6, 14.8_

- [x] 13. Implement shop domain layer
  - Create domain entities in `lib/features/shop/domain/entities/`: `business_entity.dart`, `branch_entity.dart`, `business_with_branches_entity.dart` — matching the field definitions from the design
  - Create `lib/features/shop/domain/repositories/shop_repository.dart` abstract interface with `getBusinessWithBranches()` and `getBranches()`
  - Create `lib/features/shop/domain/usecases/shop_init_usecase.dart`: call `getBusinessWithBranches()` then `getBranches()` sequentially; return `Result.success((business, branches))` or `Result.failure` on first error
  - _Requirements: 14.2, 14.3, 15.4_

- [x] 14. Implement shop presentation layer
  - [x] 14.1 Create `lib/features/shop/presentation/controllers/shop_init_controller.dart`
    - Define `ShopInitStatus` enum with values: `idle`, `loading`, `ready`, `error`
    - Implement `ShopInitController extends GetxController` with:
      - `Rx<ShopInitStatus> status = ShopInitStatus.idle.obs`
      - `Rxn<BusinessWithBranchesEntity> business = Rxn()`
      - `RxList<BranchEntity> branches = <BranchEntity>[].obs`
      - `RxString activeBranchId = ''.obs`
      - `Rxn<AppError> error = Rxn()`
      - `initialize()`: sets `status = loading`, calls `ShopInitUseCase`, on success stores `activeBranchId` in `LocalStorageService`, sets `business`, `branches`, `activeBranchId`, and `status = ready`; on failure sets `error` and `status = error`
      - `reset()`: sets `status = idle`, clears all reactive fields
    - Register `ShopInitController` via `Get.put()` in `DependencyInjection.init()`
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_
  - [x] 14.2 Create shop screens in `lib/features/shop/presentation/screens/`
    - `role_select_screen.dart`: `GetBuilder<RoleController>` listing `RoleController.roles` showing `name` and `scope`; on tap call `Get.find<RoleController>().setSelectedRole(role)`; back button calls `Get.find<AuthController>().logout()` and navigates to `/login`
    - `shop_init_loading_screen.dart`: `StatefulWidget` that calls `Get.find<ShopInitController>().initialize()` in `initState`; uses `Obx` to show circular progress indicator when `status == loading`; shows retry button and error message when `status == error`
    - _Requirements: 10.6, 10.7, 14.5, 14.6, 14.7, 19.4, 20.7, 20.8_

- [x] 15. Implement GoRouter configuration
  - [x] 15.1 Create `lib/routes/app_routes.dart`
    - Define `AppRoutes` class with all route constants: `splash`, `login`, `register`, `verifyEmail`, `forgotPassword`, `resetPassword`, `pendingApproval`, `roleSelect`, `shopInit`, `dashboard`, `shopDashboard`, `admin`
    - _Requirements: 12.6_
  - [x] 15.2 Create `lib/routes/app_router.dart`
    - Implement `_redirect(location, authStatus, session, roleController, shopInitStatus)` pure function with the full 7-step logic:
      - Step 0: `authStatus == loading` → `/splash` (unless already there)
      - Step 1: `authStatus == unauthenticated` + non-public route → `/login`; public route → `null`
      - Step 2: `authStatus == pendingApproval` → `/pending-approval`
      - Step 3: Authenticated + public route → `/dashboard`
      - Step 4: `!session.user.isEmailVerified` → `/verify-email`
      - Step 5: `roleController.selectedRole == null` + multiple roles → `/role-select`; single role → `null` (auto-select in progress)
      - Step 6: `session.user.isSuperuser == false` + `/admin` → `/dashboard`
      - Step 7: `shop_owner` + `shopInitStatus != ready` → `/shop-init`; `shopInitStatus == ready` → `/shop-dashboard`
    - Create a `GoRouter` instance that reads `Get.find<AuthController>()`, `Get.find<RoleController>()`, and `Get.find<ShopInitController>()` inside the `redirect` callback
    - Use a `ValueNotifier` or `ChangeNotifier` as `refreshListenable` — update it whenever `AuthController.status`, `RoleController.selectedRole`, or `ShopInitController.status` changes (use `ever()` workers in each controller's `onInit`)
    - Register all routes with their screen builders
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 11.2, 11.3, 19.1, 19.2, 19.3, 19.4_
  - [x] 15.3 Write property test for GoRouter redirect correctness (Property 9)
    - **Property 9: GoRouter redirect produces correct route for all auth state combinations** — for all combinations of `AuthStatus` × `RoleController.selectedRole` × `ShopInitStatus`, `_redirect` returns the expected route constant per the 7-step logic table
    - **Validates: Requirements 12.1–12.5, 19.1, 19.2**
  - [x] 15.4 Update `lib/app.dart` to use `MaterialApp.router(routerConfig: appRouter)` — no `ProviderScope` needed; GetX controllers are already registered via `Get.put()` in `DependencyInjection.init()`
    - _Requirements: 17.6_

- [x] 16. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 17. Implement remaining property-based tests
  - [x] 17.1 Write property test for proactive token refresh threshold (Property 10)
    - **Property 10: Proactive token refresh threshold** — for any JWT whose decoded `exp` is within 600 seconds of now, `JwtUtils.isTokenExpiringSoon` returns `true`; for any token with `exp` more than 600 seconds away, it returns `false`
    - **Validates: Requirements 9.1**
  - [x] 17.2 Write integration smoke tests
    - `DependencyInjection.init()` completes without throwing and all controllers are registered
    - `Get.find<AuthController>()` resolves without error after `DependencyInjection.init()`
    - `Get.find<RoleController>()` resolves without error after `DependencyInjection.init()`
    - `Get.find<ShopInitController>()` resolves without error after `DependencyInjection.init()`
    - `getIt<Dio>(instanceName: 'authDio')` resolves with `baseUrl == 'http://161.35.222.194:8001'`
    - `getIt<Dio>(instanceName: 'shopDio')` resolves with `baseUrl == 'http://161.35.222.194:8012'`
    - `AuthInterceptor` injects `Authorization: Bearer <token>` header when a token is present in `SecureStorageService` (use a mock HTTP client)
    - `AuthRepository.login` calls `POST /api/v1/auth/login` with `{email, password}` body (use a mock Dio)
    - `ShopRepository.getBusinessWithBranches` calls `GET /api/v1/businesses/me/with-branches` (use a mock Dio)
    - _Requirements: 2.7_

- [x] 18. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints at tasks 7, 11, 16, and 18 ensure incremental validation
- Property tests use the `glados` package with a minimum of 100 iterations per property
- Each property test file must include the comment tag: `// Feature: zoovana-auth-rbac-shop-init, Property N: <property_text>`
- The `AuthInterceptor` `onForceSignOut` callback must be wired to `Get.find<AuthController>().forceSignOut()` during DI setup (task 6.2)
- GetX controllers (`AuthController`, `RoleController`, `ShopInitController`) are registered via `Get.put()` in `DependencyInjection.init()` and accessed anywhere via `Get.find<T>()`
- Dio instances and repositories are still registered in `get_it` (not GetX) to keep the network/data layers framework-agnostic
- GoRouter's `refreshListenable` is driven by `ever()` workers in each GetX controller's `onInit`, which update a shared `ChangeNotifier` whenever reactive state changes
- The `_redirect` function (task 15.2) is a pure function with no side effects, making it directly testable with Property 9
