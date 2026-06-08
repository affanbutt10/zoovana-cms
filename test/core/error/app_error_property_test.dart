// Feature: zoovana-auth-rbac-shop-init, Property 2: AppError flag exclusivity
//
// Validates: Requirements 3.5–3.13
//
// Property 2: AppError flag exclusivity — for any AppError constructed via a
// named factory, exactly one boolean flag is true and all others are false.

import 'package:glados/glados.dart';
import 'package:zoovana_cms/core/error/app_error.dart';

// ---------------------------------------------------------------------------
// Helper: count the number of true boolean flags on an AppError
// ---------------------------------------------------------------------------

int _countTrueFlags(AppError error) {
  return [
    error.badRequest,
    error.unauthorized,
    error.forbidden,
    error.notFound,
    error.conflict,
    error.validationErrors,
    error.serverError,
    error.networkError,
    error.cancelled,
  ].where((flag) => flag).length;
}

// ---------------------------------------------------------------------------
// Custom generators for each named factory constructor.
//
// The message string is not part of the property under test (flag exclusivity),
// so we use a fixed placeholder message and vary only the factory used.
// ---------------------------------------------------------------------------

extension AppErrorFactoryAny on Any {
  /// Generates an AppError via AppError.badRequest.
  Generator<AppError> get badRequestError => simple(
        generate: (random, size) => AppError.badRequest('Bad request'),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.unauthorized.
  Generator<AppError> get unauthorizedError => simple(
        generate: (random, size) => AppError.unauthorized(),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.forbidden.
  Generator<AppError> get forbiddenError => simple(
        generate: (random, size) => AppError.forbidden(),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.notFound.
  Generator<AppError> get notFoundError => simple(
        generate: (random, size) => AppError.notFound(),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.conflict.
  Generator<AppError> get conflictError => simple(
        generate: (random, size) => AppError.conflict('Conflict'),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.validationError.
  Generator<AppError> get validationAppError => simple(
        generate: (random, size) =>
            AppError.validationError('Validation failed', {}),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.serverError.
  Generator<AppError> get serverAppError => simple(
        generate: (random, size) => AppError.serverError(),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.network.
  Generator<AppError> get networkAppError => simple(
        generate: (random, size) => AppError.network(),
        shrink: (_) => [],
      );

  /// Generates an AppError via AppError.cancelled.
  Generator<AppError> get cancelledError => simple(
        generate: (random, size) => AppError.cancelled(),
        shrink: (_) => [],
      );
}

void main() {
  // ---------------------------------------------------------------------------
  // Property 2: AppError flag exclusivity
  //
  // For each of the 9 named factory constructors, exactly one boolean flag is
  // true and all others are false.
  // ---------------------------------------------------------------------------

  group('Property 2 — AppError flag exclusivity', () {
    Glados(any.badRequestError).test(
      'AppError.badRequest: exactly one flag is true (badRequest)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.badRequest, isTrue,
            reason: 'badRequest flag must be true');
        expect(error.unauthorized, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.notFound, isFalse);
        expect(error.conflict, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.serverError, isFalse);
        expect(error.networkError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.unauthorizedError).test(
      'AppError.unauthorized: exactly one flag is true (unauthorized)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.unauthorized, isTrue,
            reason: 'unauthorized flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.notFound, isFalse);
        expect(error.conflict, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.serverError, isFalse);
        expect(error.networkError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.forbiddenError).test(
      'AppError.forbidden: exactly one flag is true (forbidden)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.forbidden, isTrue,
            reason: 'forbidden flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.unauthorized, isFalse);
        expect(error.notFound, isFalse);
        expect(error.conflict, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.serverError, isFalse);
        expect(error.networkError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.notFoundError).test(
      'AppError.notFound: exactly one flag is true (notFound)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.notFound, isTrue,
            reason: 'notFound flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.unauthorized, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.conflict, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.serverError, isFalse);
        expect(error.networkError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.conflictError).test(
      'AppError.conflict: exactly one flag is true (conflict)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.conflict, isTrue,
            reason: 'conflict flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.unauthorized, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.notFound, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.serverError, isFalse);
        expect(error.networkError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.validationAppError).test(
      'AppError.validationError: exactly one flag is true (validationErrors)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.validationErrors, isTrue,
            reason: 'validationErrors flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.unauthorized, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.notFound, isFalse);
        expect(error.conflict, isFalse);
        expect(error.serverError, isFalse);
        expect(error.networkError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.serverAppError).test(
      'AppError.serverError: exactly one flag is true (serverError)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.serverError, isTrue,
            reason: 'serverError flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.unauthorized, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.notFound, isFalse);
        expect(error.conflict, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.networkError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.networkAppError).test(
      'AppError.network: exactly one flag is true (networkError)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.networkError, isTrue,
            reason: 'networkError flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.unauthorized, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.notFound, isFalse);
        expect(error.conflict, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.serverError, isFalse);
        expect(error.cancelled, isFalse);
      },
    );

    Glados(any.cancelledError).test(
      'AppError.cancelled: exactly one flag is true (cancelled)',
      (error) {
        expect(_countTrueFlags(error), equals(1),
            reason: 'Exactly one flag must be true');
        expect(error.cancelled, isTrue,
            reason: 'cancelled flag must be true');
        expect(error.badRequest, isFalse);
        expect(error.unauthorized, isFalse);
        expect(error.forbidden, isFalse);
        expect(error.notFound, isFalse);
        expect(error.conflict, isFalse);
        expect(error.validationErrors, isFalse);
        expect(error.serverError, isFalse);
        expect(error.networkError, isFalse);
      },
    );
  });
}
