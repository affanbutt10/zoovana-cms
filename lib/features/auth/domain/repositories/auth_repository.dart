import '../../../../core/error/result.dart';
import '../entities/auth_session_entity.dart';
import '../entities/role_entity.dart';

/// Abstract contract for authentication operations.
///
/// The domain layer depends only on this interface. The concrete
/// implementation ([AuthRepositoryImpl]) lives in the data layer and is
/// registered via the service locator.
abstract class AuthRepository {
  /// Authenticates the user with [email] and [password].
  ///
  /// On success, stores tokens in [SecureStorageService] and user data in
  /// [LocalStorageService], then returns [Success] with an [AuthSessionEntity].
  /// On failure, returns [Failure] with an [AppError].
  Future<Result<AuthSessionEntity>> login(String email, String password);

  /// Registers a new user account.
  ///
  /// Returns [Success] with `null` on success, or [Failure] on error.
  Future<Result<void>> register({
    required String email,
    required String password,
    required String fullName,
    String? roleId,
    String? phoneNumber,
  });

  /// Verifies a user's email address using a one-time password.
  Future<Result<void>> verifyEmail({
    required String email,
    required String otp,
  });

  /// Resends the email verification OTP to the given address.
  Future<Result<void>> resendVerification(String email);

  /// Initiates the forgot-password flow for the given email address.
  Future<Result<void>> forgotPassword(String email);

  /// Verifies the OTP sent during the password-reset flow.
  Future<Result<void>> verifyOtp({required String email, required String otp});

  /// Sets a new password after OTP verification.
  Future<Result<void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  /// Invalidates the current session locally by clearing all stored tokens
  /// and session data.
  ///
  /// Returns [Success] with `null` on success.
  Future<Result<void>> logout();

  /// Exchanges a refresh token for a new access token.
  ///
  /// Returns [Success] with the new access token string, or [Failure] on error.
  Future<Result<String>> refreshToken(String refreshToken);

  /// Fetches the list of available roles from the backend.
  ///
  /// Returns [Success] with a [List<RoleEntity>], or [Failure] on error.
  Future<Result<List<RoleEntity>>> getRoles();
}
