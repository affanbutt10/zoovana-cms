import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zoovana_cms/core/utils/app_logger.dart';

/// Logs HTTP request and response details in debug mode only.
///
/// Uses [AppLogger.instance] for structured, color-coded output via the
/// `logger` package. In release / profile builds ([kDebugMode] is `false`)
/// this interceptor is a no-op.
///
/// Timing: [onRequest] stores the current epoch milliseconds in
/// `options.extra['startTime']`; [onResponse] reads that value to compute
/// and log the elapsed time.
class LoggerInterceptor extends Interceptor {
  final _logger = AppLogger.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.d('[REQ] ${options.method} ${options.uri}');
      // Redact Authorization header — never log actual token values
      final safeHeaders = Map<String, dynamic>.from(options.headers);
      if (safeHeaders.containsKey('Authorization')) {
        safeHeaders['Authorization'] = 'Bearer [REDACTED]';
      }
      _logger.d('Headers: $safeHeaders');
      if (options.data != null) _logger.d('Body: ${options.data}');
    }
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final elapsed =
          DateTime.now().millisecondsSinceEpoch -
          (response.requestOptions.extra['startTime'] as int? ?? 0);
      _logger.d(
        '[RES] ${response.statusCode} ${response.requestOptions.uri} (${elapsed}ms)',
      );
    }
    handler.next(response);
  }
}
