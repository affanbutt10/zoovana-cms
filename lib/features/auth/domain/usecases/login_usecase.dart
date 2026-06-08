import '../../../../core/error/result.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the login business action.
///
/// Called by [LoginViewModel] with the user-supplied credentials.
/// Delegates to [AuthRepository.login] and returns the result unchanged.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the login use case.
  ///
  /// [email] and [password] are the credentials entered by the user.
  /// Returns [Result<AuthSessionEntity>] — success with the authenticated
  /// session or failure with a descriptive message.
  Future<Result<AuthSessionEntity>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
