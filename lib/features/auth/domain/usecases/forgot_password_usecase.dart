import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the forgot-password business action.
///
/// Delegates to [AuthRepository.forgotPassword] and returns the result
/// unchanged.
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the forgot-password use case.
  ///
  /// [email] is the address for which a password-reset OTP will be sent.
  ///
  /// Returns [Result<void>] — success with null on success, or failure with
  /// a descriptive [AppError].
  Future<Result<void>> call(String email) {
    return _repository.forgotPassword(email);
  }
}
