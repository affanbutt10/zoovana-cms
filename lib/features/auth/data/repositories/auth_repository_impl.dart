import 'dart:convert';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
///
/// Delegates all network calls to [AuthRemoteDataSource]. On success, persists
/// tokens and user data to the appropriate storage services. Catches [AppError]
/// exceptions thrown by the data source and wraps them in [Failure].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorage,
       _localStorage = localStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  // ---------------------------------------------------------------------------
  // Auth operations
  // ---------------------------------------------------------------------------

  @override
  Future<Result<AuthSessionEntity>> login(String email, String password) async {
    try {
      final session = await _remoteDataSource.login(email, password);

      // Persist tokens to secure storage (Requirements 4.1, 4.2)
      await Future.wait([
        _secureStorage.writeAccessToken(session.accessToken),
        _secureStorage.writeRefreshToken(session.refreshToken),
      ]);

      // Persist user data to local storage (Requirements 5.5, 13.1)
      final user = session.user;
      await Future.wait([
        _localStorage.setString(LocalStorageKeys.userId, user.id),
        _localStorage.setString(LocalStorageKeys.fullName, user.fullName),
        _localStorage.setString(LocalStorageKeys.email, user.email),
        _localStorage.setBool(LocalStorageKeys.isSuperuser, user.isSuperuser),
        _localStorage.setBool(
          LocalStorageKeys.isEmailVerified,
          user.isEmailVerified,
        ),
        _localStorage.setString(
          LocalStorageKeys.defaultTenantId,
          user.defaultTenantId,
        ),
        _localStorage.setString(
          LocalStorageKeys.assignedRoles,
          jsonEncode(
            user.roles
                .map(
                  (role) => {
                    'id': role.id,
                    'name': role.name,
                    'scope': role.scope,
                    'description': role.description,
                  },
                )
                .toList(),
          ),
        ),
      ]);

      return Success(session.toEntity());
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    required String fullName,
    List<String> roleIds = const [],
    String? phoneNumber,
  }) async {
    try {
      await _remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
        roleIds: roleIds,
        phoneNumber: phoneNumber,
      );
      return const Success(null);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      await _remoteDataSource.verifyEmail(email: email, otp: otp);
      return const Success(null);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> resendVerification(String email) async {
    try {
      await _remoteDataSource.resendVerification(email);
      return const Success(null);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Success(null);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _remoteDataSource.verifyOtp(email: email, otp: otp);
      return const Success(null);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return const Success(null);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<void>> logout() async {
    // Delete all tokens from secure storage (Requirement 9.2)
    await _secureStorage.deleteAllTokens();
    // Clear all session data from local storage
    await _localStorage.clearSession();
    return const Success(null);
  }

  @override
  Future<Result<String>> refreshToken(String refreshToken) async {
    try {
      final newToken = await _remoteDataSource.refreshToken(refreshToken);
      return Success(newToken);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<RoleEntity>>> getRoles() async {
    try {
      final models = await _remoteDataSource.getRoles();
      final roles = models.map((m) => m.toEntity()).toList();
      return Success(roles);
    } on AppError catch (appError) {
      return Failure(appError);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }
}
