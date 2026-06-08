import 'package:dio/dio.dart';

import '../../error/app_error.dart';

/// Converts [DioException] instances into typed [AppError] objects before they
/// propagate to the repository layer.
///
/// Mapping rules:
/// - [DioExceptionType.cancel] → [AppError.cancelled]
/// - null response (no connectivity / DNS failure) → [AppError.network]
/// - HTTP 400 → [AppError.badRequest]
/// - HTTP 401 → [AppError.unauthorized]
/// - HTTP 403 → [AppError.forbidden]
/// - HTTP 404 → [AppError.notFound]
/// - HTTP 409 → [AppError.conflict]
/// - HTTP 422 → [AppError.validationError] (with field-level errors map)
/// - HTTP 500 → [AppError.serverError]
/// - Any other status → [AppError.serverError] (default)
///
/// The interceptor re-throws as a [DioException] with `error: appError` so
/// that callers can extract the typed error via `err.error as AppError`.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = _mapToAppError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appError,
        type: err.type,
        response: err.response,
      ),
    );
  }

  AppError _mapToAppError(DioException err) {
    if (err.type == DioExceptionType.cancel) return AppError.cancelled();

    if (err.response == null) return AppError.network();

    final status = err.response!.statusCode ?? 0;
    final body = err.response!.data;

    return switch (status) {
      400 => AppError.badRequest(_extractMessage(body)),
      401 => AppError.unauthorized(),
      403 => AppError.forbidden(_extractMessage(body)),
      404 => AppError.notFound(_extractMessage(body)),
      409 => AppError.conflict(_extractMessage(body)),
      422 => AppError.validationError(
        _extractMessage(body),
        _extractValidationErrors(body),
      ),
      500 => AppError.serverError(_extractMessage(body)),
      _ => AppError.serverError(),
    };
  }

  /// Extracts a human-readable message from the response body.
  ///
  /// Checks `detail` first (FastAPI convention), then `message`.
  /// If `detail` is a [List], joins the items with `, `.
  String _extractMessage(dynamic body) {
    if (body is Map) {
      final detail = body['detail'];
      if (detail is String) return detail;
      if (detail is List) return detail.map((e) => e.toString()).join(', ');
      final message = body['message'];
      if (message is String) return message;
    }
    return 'An unexpected error occurred';
  }

  /// Builds a field → messages map from a FastAPI 422 validation error body.
  ///
  /// FastAPI returns `detail` as a list of objects with `loc` (location path)
  /// and `msg` (error message). This method uses the last element of `loc` as
  /// the field name key.
  Map<String, List<String>> _extractValidationErrors(dynamic body) {
    final result = <String, List<String>>{};
    if (body is Map) {
      final detail = body['detail'];
      if (detail is List) {
        for (final item in detail) {
          if (item is Map) {
            final loc =
                (item['loc'] as List?)?.lastOrNull?.toString() ?? 'field';
            final msg = item['msg']?.toString() ?? 'Invalid value';
            result.putIfAbsent(loc, () => []).add(msg);
          }
        }
      }
    }
    return result;
  }
}
