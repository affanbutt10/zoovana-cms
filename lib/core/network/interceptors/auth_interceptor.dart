import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import '../../config/app_config.dart';
import '../../error/app_error.dart';
import '../../network/api_endpoints.dart';
import '../../storage/local_storage_service.dart';
import '../../storage/secure_storage_service.dart';

/// Injects the Bearer token into every outgoing request and handles reactive
/// token refresh on 401 responses.
///
/// Behaviour:
/// - [onRequest]: reads `access_token` from [SecureStorageService]; if present,
///   injects `Authorization: Bearer <token>` header.
/// - [onError]: if the error is not a 401, passes through unchanged.
///   If the failing path contains `/auth/refresh`, clears the session and
///   calls [onForceSignOut] to prevent an infinite refresh loop.
///   Otherwise, acquires a [Lock], calls [_refreshToken], writes the new token,
///   releases the lock, and retries the original request.
///   If the refresh returns null, clears the session and passes through.
///
/// Requirements: 3.14, 3.15, 3.16, 9.3, 9.4, 9.5
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required void Function() onForceSignOut,
  }) : _dio = dio,
       _secureStorage = secureStorage,
       _localStorage = localStorage,
       _onForceSignOut = onForceSignOut;

  final Dio _dio;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final void Function() _onForceSignOut;

  /// Mutex that ensures only one token refresh runs at a time across all
  /// concurrent 401 requests (Requirement 3.16, 9.5).
  final Lock _lock = Lock();

  // ---------------------------------------------------------------------------
  // onRequest — inject Bearer token
  // ---------------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        debugPrint('│ [Auth] Authorization header injected '
            '(token present: true, length: ${token.length})');
      }
    } else {
      if (kDebugMode) {
        debugPrint('│ [Auth] No access token found — request sent without Authorization');
      }
    }
    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // onError — reactive token refresh on 401
  // ---------------------------------------------------------------------------

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final appError = err.error;

    if (kDebugMode) {
      debugPrint('│ [Auth] onError: status=${err.response?.statusCode} '
          'path=${err.requestOptions.path}');
    }

    // Only handle 401 Unauthorized errors produced by ErrorInterceptor.
    if (appError is! AppError || !appError.unauthorized) {
      handler.next(err);
      return;
    }

    // If the refresh endpoint itself returned 401, clear session to avoid an
    // infinite refresh loop (Requirement 3.15, 9.4).
    if (err.requestOptions.path.contains(ApiEndpoints.refresh)) {
      if (kDebugMode) {
        debugPrint('│ [Auth] Refresh endpoint returned 401 — forcing sign-out');
      }
      await _clearSessionAndSignOut();
      handler.next(err);
      return;
    }

    if (kDebugMode) {
      debugPrint('│ [Auth] 401 received — attempting token refresh');
    }

    // Acquire the mutex so that concurrent 401s queue up and only one refresh
    // call is made (Requirement 3.16, 9.5).
    try {
      String? newToken;

      await _lock.synchronized(() async {
        // Re-read the token inside the lock — a previous waiter may have
        // already refreshed it.
        final existingToken = await _secureStorage.readAccessToken();

        // If the token changed while we were waiting, use it directly.
        final failedToken = err.requestOptions.headers['Authorization']
            ?.toString()
            .replaceFirst('Bearer ', '');

        if (existingToken != null && existingToken != failedToken) {
          if (kDebugMode) {
            debugPrint('│ [Auth] Token already refreshed by another request — reusing');
          }
          newToken = existingToken;
          return;
        }

        // Perform the actual refresh.
        newToken = await _refreshToken();

        if (newToken == null) {
          if (kDebugMode) {
            debugPrint('│ [Auth] Refresh failed — forcing sign-out');
          }
          await _clearSessionAndSignOut();
          return;
        }

        if (kDebugMode) {
          debugPrint('│ [Auth] Refresh succeeded — new token stored');
        }
        await _secureStorage.writeAccessToken(newToken!);
      });

      // If we still have no token after the lock, pass the error through.
      if (newToken == null) {
        handler.next(err);
        return;
      }

      // Retry the original request with the new token.
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      if (kDebugMode) {
        debugPrint('│ [Auth] Retrying original request: ${retryOptions.path}');
      }
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _clearSessionAndSignOut();
      handler.next(err);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Reads the stored refresh token and calls `POST /api/v1/auth/refresh`
  /// on the **Auth Service** (not the shop Dio).
  /// Returns the new access token string, or `null` on any failure.
  ///
  /// Requirements: 9.3
  Future<String?> _refreshToken() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null) {
      if (kDebugMode) {
        debugPrint('│ [Auth] No refresh token in storage');
      }
      return null;
    }

    try {
      // Use a fresh Dio pointed at the Auth Service to avoid interceptor loops.
      final authDio = Dio(BaseOptions(
        baseUrl: AppConfig.authBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      final response = await authDio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      final body = response.data as Map<String, dynamic>?;
      final data = (body?['data'] as Map<String, dynamic>?) ?? body ?? {};
      return data['access_token'] as String?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('│ [Auth] Refresh request failed: $e');
      }
      return null;
    }
  }

  /// Deletes all tokens from [SecureStorageService], clears the session from
  /// [LocalStorageService], and invokes [_onForceSignOut] to notify the auth
  /// state layer.
  ///
  /// Requirements: 3.15, 9.4
  Future<void> _clearSessionAndSignOut() async {
    await _secureStorage.deleteAllTokens();
    await _localStorage.clearSession();
    _onForceSignOut();
  }
}
