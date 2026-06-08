// Feature: zoovana-auth-rbac-shop-init, Property 1: Result exhaustiveness
//
// Validates: Requirements 5.3, 5.4
//
// Property 1: Result exhaustiveness — for any Result<T>, when(success:, failure:)
// invokes exactly one callback and returns its value.

import 'package:glados/glados.dart';
import 'package:zoovana_cms/core/error/app_error.dart';
import 'package:zoovana_cms/core/error/result.dart';

// ---------------------------------------------------------------------------
// Custom generator for AppError instances
// ---------------------------------------------------------------------------

extension AppErrorAny on Any {
  Generator<AppError> get appError => simple(
        generate: (random, size) {
          // Pick one of the named factory constructors to produce a valid AppError
          final index = random.nextInt(9);
          return switch (index) {
            0 => AppError.badRequest('Bad request'),
            1 => AppError.unauthorized(),
            2 => AppError.forbidden(),
            3 => AppError.notFound(),
            4 => AppError.conflict('Conflict'),
            5 => AppError.validationError('Validation failed', {}),
            6 => AppError.serverError(),
            7 => AppError.network(),
            _ => AppError.cancelled(),
          };
        },
        shrink: (_) => [],
      );
}

void main() {
  // ---------------------------------------------------------------------------
  // Property 1: Result exhaustiveness
  //
  // For any Success<int>, when(success: (d) => d, failure: (e) => -1) returns
  // the success data.
  // ---------------------------------------------------------------------------

  group('Property 1 — Result exhaustiveness', () {
    Glados<int>(any.int).test(
      'Success<int>: when returns the success data',
      (data) {
        final result = Success<int>(data);

        var successCallCount = 0;
        var failureCallCount = 0;

        final value = result.when(
          success: (d) {
            successCallCount++;
            return d;
          },
          failure: (e) {
            failureCallCount++;
            return -1;
          },
        );

        // Returns the success data
        expect(value, equals(data));

        // Exactly one callback was called
        expect(successCallCount + failureCallCount, equals(1),
            reason: 'when() must invoke exactly one callback');

        // The success callback was called, not the failure callback
        expect(successCallCount, equals(1),
            reason: 'success callback must be called for Success');
        expect(failureCallCount, equals(0),
            reason: 'failure callback must NOT be called for Success');
      },
    );

    Glados(any.appError).test(
      'Failure<int>: when returns -1 (the failure callback result)',
      (error) {
        final result = Failure<int>(error);

        var successCallCount = 0;
        var failureCallCount = 0;

        final value = result.when(
          success: (d) {
            successCallCount++;
            return d;
          },
          failure: (e) {
            failureCallCount++;
            return -1;
          },
        );

        // Returns the failure callback result
        expect(value, equals(-1));

        // Exactly one callback was called
        expect(successCallCount + failureCallCount, equals(1),
            reason: 'when() must invoke exactly one callback');

        // The failure callback was called, not the success callback
        expect(failureCallCount, equals(1),
            reason: 'failure callback must be called for Failure');
        expect(successCallCount, equals(0),
            reason: 'success callback must NOT be called for Failure');
      },
    );

    Glados2<int, bool>(any.int, any.bool).test(
      'when() calls exactly one callback — never both, never neither',
      (data, isSuccess) {
        final Result<int> result = isSuccess
            ? Success<int>(data)
            : Failure<int>(AppError.serverError());

        var successCallCount = 0;
        var failureCallCount = 0;

        result.when(
          success: (d) {
            successCallCount++;
            return d;
          },
          failure: (e) {
            failureCallCount++;
            return -1;
          },
        );

        // Exactly one callback must have been called
        expect(successCallCount + failureCallCount, equals(1),
            reason: 'when() must invoke exactly one callback');

        if (isSuccess) {
          expect(successCallCount, equals(1),
              reason: 'success callback must be called for Success');
          expect(failureCallCount, equals(0),
              reason: 'failure callback must NOT be called for Success');
        } else {
          expect(failureCallCount, equals(1),
              reason: 'failure callback must be called for Failure');
          expect(successCallCount, equals(0),
              reason: 'success callback must NOT be called for Failure');
        }
      },
    );
  });
}
