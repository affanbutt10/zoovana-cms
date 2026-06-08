import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the email verification business action.
///
/// Delegates to [AuthRepository.verifyEmail] and returns the result unchanged.
class VerifyEmailUseCase {
  const VerifyEmailUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the verify-email use case.
  ///
  /// [email] is the address to verify and [otp] is the one-time password
  /// sent to that address.
  ///
  /// Returns [Result<void>] — success with null on success, or failure with
  /// a descriptive [AppError].
  Future<Result<void>> call({required String email, required String otp}) {
    return _repository.verifyEmail(email: email, otp: otp);
  }
}
