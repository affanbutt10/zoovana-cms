import 'package:get/get.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../shop/presentation/controllers/shop_init_controller.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'role_controller.dart';

/// Represents the current authentication lifecycle state.
enum AuthStatus {
  /// Initial state while session restoration is in progress.
  loading,

  /// No active session — user must log in.
  unauthenticated,

  /// User is fully authenticated with an active session.
  authenticated,

  /// User is authenticated but their account is pending admin approval.
  pendingApproval,
}

/// GetX controller that owns the authentication state machine.
///
/// Registered globally via [Get.put] in [DependencyInjection.init] so it is
/// accessible anywhere via [Get.find<AuthController>()].
///
/// Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 17.6
class AuthController extends GetxController {
  AuthController({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required SecureStorageService secureStorage,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _secureStorage = secureStorage;

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final SecureStorageService _secureStorage;

  // ---------------------------------------------------------------------------
  // Reactive state
  // ---------------------------------------------------------------------------

  /// The current authentication status. Starts as [AuthStatus.loading] while
  /// the stored session is being restored.
  Rx<AuthStatus> status = AuthStatus.loading.obs;

  /// The active session entity, or `null` when unauthenticated.
  Rxn<AuthSessionEntity> session = Rxn<AuthSessionEntity>();

  /// The last login error, if any. Cleared on each new login attempt.
  Rxn<AppError> lastLoginError = Rxn<AppError>();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  // Session restoration is handled explicitly by DependencyInjection.init()
  // via restoreSessionOnInit() — do NOT override onInit to avoid a
  // double-call race condition.

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Reads the stored access token and sets [status] accordingly.
  ///
  /// Exposed as a public method so [DependencyInjection.init()] can await it,
  /// ensuring auth state is resolved before the router evaluates its first
  /// redirect.
  ///
  /// Requirement 17.2
  Future<void> restoreSessionOnInit() async {
    // Ensure the splash screen is visible for a minimum duration.
    await Future.delayed(const Duration(milliseconds: 2500));

    final token = await _secureStorage.readAccessToken();
    // A real JWT always starts with "eyJ" (base64-encoded {"alg":...}).
    // Reject anything else — this clears leftover mock/dev tokens that
    // iOS Keychain persists across app reinstalls.
    final isValidJwt = token != null &&
        token.isNotEmpty &&
        token.startsWith('eyJ');
    if (!isValidJwt) {
      await _secureStorage.deleteAllTokens();
      status.value = AuthStatus.unauthenticated;
      return;
    }

    // Restore user data from local storage so the redirect guard has
    // real values for isEmailVerified, roles, etc.
    try {
      final localStorage = Get.find<LocalStorageService>();
      final roleController = Get.find<RoleController>();

      final userId = await localStorage.getString(LocalStorageKeys.userId) ?? '';
      final email = await localStorage.getString(LocalStorageKeys.email) ?? '';
      final fullName = await localStorage.getString(LocalStorageKeys.fullName) ?? '';
      final isSuperuser = await localStorage.getBool(LocalStorageKeys.isSuperuser) ?? false;
      // Default true — if not stored yet, assume verified to avoid redirect loop
      final isEmailVerified = await localStorage.getBool(LocalStorageKeys.isEmailVerified) ?? true;
      final defaultTenantId = await localStorage.getString(LocalStorageKeys.defaultTenantId) ?? '';

      // Wait for RoleController.onInit to finish restoring selectedRole
      // (it runs async in onInit, give it a moment)
      await Future.delayed(const Duration(milliseconds: 50));

      // Build roles list from the restored selectedRole if available
      final restoredRole = roleController.selectedRole.value;
      final roles = restoredRole != null ? [restoredRole] : <RoleEntity>[];

      // Populate the roles list in RoleController so it's consistent
      if (roles.isNotEmpty && roleController.roles.isEmpty) {
        roleController.roles.assignAll(roles);
      }

      session.value = AuthSessionEntity(
        accessToken: token,
        refreshToken: '',
        expiresIn: 3600,
        user: UserEntity(
          id: userId,
          email: email,
          fullName: fullName,
          isSuperuser: isSuperuser,
          isEmailVerified: isEmailVerified,
          roles: roles,
          defaultTenantId: defaultTenantId,
        ),
        status: AuthSessionStatus.active,
      );

      // If the user previously completed shop init (activeBranchId is stored),
      // mark ShopInitController as ready so the redirect guard doesn't force
      // /shop-init on every restart.
      final activeBranchId = await localStorage.getString(LocalStorageKeys.activeBranchId);
      if (activeBranchId != null && activeBranchId.isNotEmpty) {
        try {
          final shopInitController = Get.find<ShopInitController>();
          if (shopInitController.status.value == ShopInitStatus.idle) {
            shopInitController.markReadyFromStorage(activeBranchId);
          }
        } catch (_) {
          // ShopInitController not yet registered — safe to ignore
        }
      }
    } catch (_) {
      // If restoration fails, still mark as authenticated — the redirect
      // guard will handle any missing data gracefully.
    }

    status.value = AuthStatus.authenticated;
  }

  // ---------------------------------------------------------------------------
  // Public actions
  // ---------------------------------------------------------------------------

  /// Authenticates the user with [email] and [password].
  ///
  /// Sets [status] to [AuthStatus.loading] while the request is in flight.
  /// On success, stores the [AuthSessionEntity] and transitions to
  /// [AuthStatus.authenticated] or [AuthStatus.pendingApproval] depending on
  /// the session's [AuthSessionStatus].
  /// On failure, transitions to [AuthStatus.unauthenticated].
  ///
  /// Requirement 17.3
  Future<void> login(String email, String password) async {
    status.value = AuthStatus.loading;
    lastLoginError.value = null;

    final result = await _loginUseCase(email, password);

    result.when(
      success: (authSession) {
        session.value = authSession;
        lastLoginError.value = null;
        try {
          final roleController = Get.find<RoleController>();
          roleController.setRoles(authSession.user.roles);
        } catch (_) {}
        if (authSession.status == AuthSessionStatus.pendingApproval) {
          status.value = AuthStatus.pendingApproval;
        } else {
          status.value = AuthStatus.authenticated;
        }
      },
      failure: (error) {
        lastLoginError.value = error;
        status.value = AuthStatus.unauthenticated;
      },
    );
  }

  /// Logs the user out by calling [LogoutUseCase], clearing the session, and
  /// transitioning to [AuthStatus.unauthenticated].
  ///
  /// Requirement 17.4
  Future<void> logout() async {
    await _logoutUseCase();
    session.value = null;
    status.value = AuthStatus.unauthenticated;
  }

  /// Forcibly signs the user out by deleting all stored tokens.
  ///
  /// Called by [AuthInterceptor] when a token refresh fails unrecoverably
  /// (e.g. the refresh token itself is expired or revoked).
  ///
  /// Requirement 17.5
  Future<void> forceSignOut() async {
    await _secureStorage.deleteAllTokens();
    session.value = null;
    status.value = AuthStatus.unauthenticated;
  }
}
