import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

/// Factory that creates pre-configured [Dio] instances for each backend
/// service.
///
/// Two instances are provided:
/// - [createAuthDio] — targets the Auth Service (`AppConfig.authBaseUrl`).
/// - [createShopDio] — targets the Shop Service (`AppConfig.shopBaseUrl`).
///
/// Both instances share the same interceptor chain (in order):
/// 1. [LocaleInterceptor]  — injects `Accept-Language` header.
/// 2. [LoggerInterceptor]  — logs requests/responses in debug mode.
/// 3. [ErrorInterceptor]   — maps [DioException] → [AppError].
/// 4. [AuthInterceptor]    — injects Bearer token + handles 401 refresh.
///
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5
class DioFactory {
  DioFactory._();

  /// Creates a [Dio] instance configured for the Auth Service.
  ///
  /// [secureStorage] and [localStorage] are forwarded to [AuthInterceptor]
  /// for token injection and session management.
  ///
  /// [onForceSignOut] is called by [AuthInterceptor] when a token refresh
  /// fails unrecoverably, allowing the presentation layer to react (e.g.
  /// navigate to the login screen).
  static Dio createAuthDio({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required void Function() onForceSignOut,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.authBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LocaleInterceptor(),
      LoggerInterceptor(),
      ErrorInterceptor(),
      AuthInterceptor(
        dio: dio,
        secureStorage: secureStorage,
        localStorage: localStorage,
        onForceSignOut: onForceSignOut,
      ),
    ]);

    return dio;
  }

  /// Creates a [Dio] instance configured for the Shop Service.
  ///
  /// Identical to [createAuthDio] except the base URL is
  /// [AppConfig.shopBaseUrl].
  static Dio createShopDio({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required void Function() onForceSignOut,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.shopBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LocaleInterceptor(),
      LoggerInterceptor(),
      ErrorInterceptor(),
      AuthInterceptor(
        dio: dio,
        secureStorage: secureStorage,
        localStorage: localStorage,
        onForceSignOut: onForceSignOut,
      ),
    ]);

    return dio;
  }

  /// Creates a [Dio] instance configured for the CMS Service.
  ///
  /// Targets [AppConfig.cmsBaseUrl] (`https://s.zoovana.net`).
  /// Used by dashboard, suppliers, categories, and products datasources.
  static Dio createCmsDio({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required void Function() onForceSignOut,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.cmsBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LocaleInterceptor(),
      LoggerInterceptor(),
      ErrorInterceptor(),
      AuthInterceptor(
        dio: dio,
        secureStorage: secureStorage,
        localStorage: localStorage,
        onForceSignOut: onForceSignOut,
      ),
    ]);

    return dio;
  }
}
