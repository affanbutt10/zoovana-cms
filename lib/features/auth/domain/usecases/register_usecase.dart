import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the user registration business action.
///
/// Delegates to [AuthRepository.register] and returns the result unchanged.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the register use case.
  ///
  /// [email], [password], and [fullName] are required. [roleIds] contains one
  /// or more roles selected during onboarding.
  ///
  /// Returns [Result<void>] — success with null on success, or failure with
  /// a descriptive [AppError].
  Future<Result<void>> call({
    required String email,
    required String password,
    required String fullName,
    List<String> roleIds = const [],
    String? phoneNumber,
  }) {
    return _repository.register(
      email: email,
      password: password,
      fullName: fullName,
      roleIds: roleIds,
      phoneNumber: phoneNumber,
    );
  }
}
