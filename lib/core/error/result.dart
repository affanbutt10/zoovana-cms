import 'app_error.dart';

/// A sealed result type that holds either a [Success] value of type [T]
/// or a [Failure] carrying an [AppError].
///
/// Every repository method returns a [Result<T>] so callers are forced to
/// handle both outcomes at compile time — no unhandled exceptions propagate
/// to the UI.
///
/// Usage:
/// ```dart
/// final result = await repository.login(email, password);
/// result.when(
///   success: (session) => print(session.accessToken),
///   failure: (error) => print(error.message),
/// );
/// ```
sealed class Result<T> {
  const Result();
}

/// Represents a successful result carrying [data] of type [T].
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Represents a failed result carrying an [AppError].
final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

/// Convenience helpers for working with [Result] values.
extension ResultExtension<T> on Result<T> {
  /// Returns `true` if this result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if this result is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the success data, or `null` if this is a [Failure].
  T? get data => switch (this) {
    Success<T> s => s.data,
    Failure<T> _ => null,
  };

  /// Returns the [AppError], or `null` if this is a [Success].
  AppError? get error => switch (this) {
    Success<T> _ => null,
    Failure<T> f => f.error,
  };

  /// Exhaustively handles both outcomes.
  ///
  /// Exactly one of [success] or [failure] is called — never both, never
  /// neither. The return value of the invoked callback is returned.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) => switch (this) {
    Success<T> s => success(s.data),
    Failure<T> f => failure(f.error),
  };
}
