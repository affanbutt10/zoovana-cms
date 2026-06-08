import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the token-refresh business action.
///
/// Delegates to [AuthRepository.refreshToken] and returns the result
/// unchanged.
class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the refresh-token use case.
  ///
  /// [refreshToken] is the token used to obtain a new access token.
  ///
  /// Returns [Result<String>] — success with the new access token string,
  /// or failure with a descriptive [AppError].
  Future<Result<String>> call(String refreshToken) {
    return _repository.refreshToken(refreshToken);
  }
}
