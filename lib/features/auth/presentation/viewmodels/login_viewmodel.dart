import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/usecases/login_usecase.dart';

/// ViewModel for the login screen.
///
/// Extends [GetxController] and exposes reactive observables consumed by
/// [LoginView] via [GetView]. Delegates the login business action to
/// [LoginUseCase] and stores the auth token via [SecureStorageService] on
/// success.
class LoginViewModel extends GetxController {
  LoginViewModel({
    required LoginUseCase loginUseCase,
    required SecureStorageService secureStorage,
  }) : _loginUseCase = loginUseCase,
       _secureStorage = secureStorage;

  final LoginUseCase _loginUseCase;
  final SecureStorageService _secureStorage;

  // ---------------------------------------------------------------------------
  // Observables
  // ---------------------------------------------------------------------------

  /// Whether a login request is currently in progress.
  final isLoading = false.obs;

  /// Non-empty when the last login attempt failed.
  final errorMessage = ''.obs;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Attempts to authenticate the user with [email] and [password].
  ///
  /// Sets [isLoading] to `true` for the duration of the request.
  /// On success, stores the token and navigates to [AppRoutes.dashboard].
  /// On failure, populates [errorMessage] with the failure description.
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _loginUseCase(email, password);

    result.when(
      success: (session) async {
        await _secureStorage.writeAccessToken(session.accessToken);
        isLoading.value = false;
        Get.offAllNamed(AppRoutes.dashboard);
      },
      failure: (error) {
        errorMessage.value = error.message;
        isLoading.value = false;
      },
    );
  }
}
