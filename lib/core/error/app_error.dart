/// A typed error object used throughout the app instead of raw HTTP status
/// codes or [DioException].
///
/// Exactly one boolean flag is `true` per error instance, making it easy to
/// pattern-match on the error type without inspecting status codes directly.
///
/// Usage:
/// ```dart
/// if (error.unauthorized) {
///   // redirect to login
/// } else if (error.validationErrors) {
///   // show field-level errors from error.errors
/// }
/// ```
class AppError {
  final int status;
  final String message;

  /// Field-level validation errors keyed by field name.
  /// Only populated for [validationErrors] (HTTP 422) errors.
  final Map<String, List<String>>? errors;

  // Status flags — exactly one is true per error instance
  final bool badRequest; // 400
  final bool unauthorized; // 401
  final bool forbidden; // 403
  final bool notFound; // 404
  final bool conflict; // 409
  final bool validationErrors; // 422
  final bool serverError; // 500
  final bool networkError; // no response / DNS failure
  final bool cancelled; // request cancelled

  const AppError({
    required this.status,
    required this.message,
    this.errors,
    this.badRequest = false,
    this.unauthorized = false,
    this.forbidden = false,
    this.notFound = false,
    this.conflict = false,
    this.validationErrors = false,
    this.serverError = false,
    this.networkError = false,
    this.cancelled = false,
  });

  /// Creates a 400 Bad Request error with an optional field-errors map.
  factory AppError.badRequest(
    String message, {
    Map<String, List<String>>? errors,
  }) =>
      AppError(status: 400, message: message, errors: errors, badRequest: true);

  /// Creates a 401 Unauthorized error (default: session expired).
  factory AppError.unauthorized([String message = 'Session expired']) =>
      AppError(status: 401, message: message, unauthorized: true);

  /// Creates a 403 Forbidden error (default: no permission).
  factory AppError.forbidden([String message = "You don't have permission"]) =>
      AppError(status: 403, message: message, forbidden: true);

  /// Creates a 404 Not Found error (default: resource not found).
  factory AppError.notFound([String message = 'Resource not found']) =>
      AppError(status: 404, message: message, notFound: true);

  /// Creates a 409 Conflict error.
  factory AppError.conflict(String message) =>
      AppError(status: 409, message: message, conflict: true);

  /// Creates a 422 Validation Error with field-level errors map.
  factory AppError.validationError(
    String message,
    Map<String, List<String>> errors,
  ) => AppError(
    status: 422,
    message: message,
    errors: errors,
    validationErrors: true,
  );

  /// Creates a 500 Server Error (default: unexpected server error).
  factory AppError.serverError([
    String message = 'An unexpected server error occurred',
  ]) => AppError(status: 500, message: message, serverError: true);

  /// Creates a network error (no internet / DNS failure).
  factory AppError.network([
    String message = 'No internet connection. Please check your network.',
  ]) => AppError(status: 0, message: message, networkError: true);

  /// Creates a cancelled-request error.
  factory AppError.cancelled() =>
      AppError(status: 0, message: 'Request cancelled', cancelled: true);

  @override
  String toString() => 'AppError(status: $status, message: $message)';
}
