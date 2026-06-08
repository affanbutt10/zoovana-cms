import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the logout business action.
///
/// Delegates to [AuthRepository.logout] which invalidates the session
/// locally by clearing all stored tokens and session data.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the logout use case.
  ///
  /// Returns [Result<void>] — success when the session has been cleared,
  /// or failure with a descriptive [AppError].
  Future<Result<void>> call() {
    return _repository.logout();
  }
}
