import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Central HTTP client for all network communication.
///
/// Extends [GetxService] so it is registered as a long-lived singleton via
/// `Get.putAsync<ApiClient>(() => ApiClient().init())` in
/// [DependencyInjection].
///
/// All feature data-sources obtain this service via `Get.find<ApiClient>()`
/// and call the typed [get], [post], [put], [patch], or [delete] methods.
/// No feature class should ever instantiate [Dio] directly.
class ApiClient extends GetxService {
  late final Dio _dio;

  /// Initialises the [Dio] instance with base options and attaches all
  /// interceptors. Returns `this` so it can be used with `Get.putAsync`.
  Future<ApiClient> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        dio: _dio,
        secureStorage: Get.find<SecureStorageService>(),
        localStorage: Get.find<LocalStorageService>(),
        onForceSignOut: () {},
      ),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);

    return this;
  }

  // ---------------------------------------------------------------------------
  // HTTP methods
  // ---------------------------------------------------------------------------

  /// Performs an HTTP GET request.
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<dynamic>(path, queryParameters: queryParameters);
  }

  /// Performs an HTTP POST request.
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Performs an HTTP PUT request.
  Future<Response<dynamic>> put(String path, {dynamic data}) {
    return _dio.put<dynamic>(path, data: data);
  }

  /// Performs an HTTP PATCH request.
  Future<Response<dynamic>> patch(String path, {dynamic data}) {
    return _dio.patch<dynamic>(path, data: data);
  }

  /// Performs an HTTP DELETE request.
  Future<Response<dynamic>> delete(String path) {
    return _dio.delete<dynamic>(path);
  }
}
