import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the reset-password business action.
///
/// Delegates to [AuthRepository.resetPassword] and returns the result
/// unchanged.
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the reset-password use case.
  ///
  /// [email] identifies the account, [otp] is the verification code, and
  /// [newPassword] is the replacement password.
  ///
  /// Returns [Result<void>] — success with null on success, or failure with
  /// a descriptive [AppError].
  Future<Result<void>> call({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _repository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
