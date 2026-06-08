import 'package:logger/logger.dart';

/// A static wrapper around the `logger` package's [Logger] class.
///
/// Provides convenient static methods for structured logging throughout the app.
/// All log output is routed through a single [Logger] instance configured with
/// a [PrettyPrinter] for readable, color-coded console output.
///
/// Usage:
/// ```dart
/// AppLogger.debug('Fetching products', tag: 'ProductRepository');
/// AppLogger.info('User logged in');
/// AppLogger.warning('Token is about to expire');
/// AppLogger.error('Login failed', error: e, stackTrace: st);
/// ```
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Returns the shared [Logger] instance.
  ///
  /// Use this when you need direct access to the underlying [Logger] object,
  /// e.g. inside Dio interceptors:
  /// ```dart
  /// AppLogger.instance.d('request sent');
  /// ```
  static Logger get instance => _logger;

  /// Logs a verbose/debug message.
  ///
  /// Use for detailed diagnostic information during development.
  static void debug(
    dynamic message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formattedMessage = tag != null ? '[$tag] $message' : message;
    _logger.d(formattedMessage, error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message.
  ///
  /// Use for general operational events (e.g., user actions, navigation).
  static void info(
    dynamic message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formattedMessage = tag != null ? '[$tag] $message' : message;
    _logger.i(formattedMessage, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Use for potentially harmful situations that are not yet errors.
  static void warning(
    dynamic message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formattedMessage = tag != null ? '[$tag] $message' : message;
    _logger.w(formattedMessage, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  ///
  /// Use for error events that might still allow the application to continue.
  static void error(
    dynamic message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formattedMessage = tag != null ? '[$tag] $message' : message;
    _logger.e(formattedMessage, error: error, stackTrace: stackTrace);
  }
}
