import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs HTTP request and response details in debug mode only.
///
/// In release / profile builds ([kDebugMode] is `false`) this interceptor
/// is a no-op — no log output is produced and no performance overhead is
/// incurred.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌── REQUEST ─────────────────────────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        // Redact Authorization header — never log actual token values
        final safeHeaders = Map<String, dynamic>.from(options.headers);
        if (safeHeaders.containsKey('Authorization')) {
          safeHeaders['Authorization'] = 'Bearer [REDACTED]';
        }
        debugPrint('│ Headers: $safeHeaders');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('│ Query: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└────────────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('┌── RESPONSE ────────────────────────────────────────────');
      debugPrint('│ ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('│ Data: ${response.data}');
      debugPrint('└────────────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌── ERROR ───────────────────────────────────────────────');
      debugPrint('│ ${err.type.name} ${err.requestOptions.uri}');
      debugPrint('│ Message: ${err.message}');
      if (err.response != null) {
        debugPrint('│ Status: ${err.response?.statusCode}');
        debugPrint('│ Data: ${err.response?.data}');
      }
      debugPrint('└────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}
