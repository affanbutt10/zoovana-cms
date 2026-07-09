import 'package:dio/dio.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_response_model.dart';
import '../models/role_model.dart';

/// Abstract contract for the auth remote data source.
///
/// All methods throw an [AppError] (wrapped in a [DioException]) on failure.
/// The repository layer catches these and wraps them in [Result].
abstract class AuthRemoteDataSource {
  /// Authenticates a user and returns a [LoginResponseModel] containing
  /// JWT tokens and user data.
  Future<LoginResponseModel> login(String email, String password);

  /// Registers a new user account.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    List<String> roleIds = const [],
    String? phoneNumber,
  });

  /// Verifies a user's email address using a one-time password.
  Future<void> verifyEmail({required String email, required String otp});

  /// Resends the email verification OTP to the given address.
  Future<void> resendVerification(String email);

  /// Initiates the forgot-password flow for the given email address.
  Future<void> forgotPassword(String email);

  /// Verifies the OTP sent during the password-reset flow.
  Future<void> verifyOtp({required String email, required String otp});

  /// Sets a new password after OTP verification.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  /// Exchanges a refresh token for a new access token.
  ///
  /// Returns the new access token string.
  Future<String> refreshToken(String refreshToken);

  /// Fetches the list of available roles from the backend.
  Future<List<RoleModel>> getRoles();
}

/// Concrete implementation that communicates with the Zoovana Auth Service
/// via a [Dio] instance.
///
/// Each method catches [DioException], extracts the [AppError] that was
/// attached by [ErrorInterceptor], and rethrows it so the repository layer
/// can wrap it in a typed [Result].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts the [AppError] from a [DioException] and rethrows it.
  ///
  /// [ErrorInterceptor] stores the mapped [AppError] in [DioException.error].
  /// If the error field is not an [AppError] (e.g. an unexpected exception),
  /// a generic server error is rethrown instead.
  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  // ---------------------------------------------------------------------------
  // Interface implementation
  // ---------------------------------------------------------------------------

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    List<String> roleIds = const [],
    String? phoneNumber,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'full_name': fullName,
      };
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = phoneNumber;
      }
      if (roleIds.isNotEmpty) {
        body['role_ids'] = roleIds;
      }
      await _dio.post(ApiEndpoints.register, data: body);
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<void> verifyEmail({required String email, required String otp}) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyEmail,
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<void> resendVerification(String email) async {
    try {
      await _dio.post(ApiEndpoints.resendVerification, data: {'email': email});
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'otp': otp, 'new_password': newPassword},
      );
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      // Support both flat and data-wrapped response shapes
      final body = response.data as Map<String, dynamic>;
      final d = (body['data'] as Map<String, dynamic>?) ?? body;
      return (d['access_token'] as String?) ?? '';
    } on DioException catch (err) {
      _rethrow(err);
    }
  }

  @override
  Future<List<RoleModel>> getRoles() async {
    try {
      // Roles are served from a different host — use a dedicated Dio instance
      final rolesDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.mainBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final response = await rolesDio.get(ApiEndpoints.roles);
      final body = response.data as Map<String, dynamic>;
      // Unwrap the data envelope: {"success": true, "data": [...]}
      final List<dynamic> list = (body['data'] as List<dynamic>?) ?? [];
      return list
          .map((item) => RoleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (err) {
      _rethrow(err);
    }
  }
}
