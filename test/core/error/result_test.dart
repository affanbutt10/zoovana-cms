import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/core/error/app_error.dart';
import 'package:zoovana_cms/core/error/result.dart';

void main() {
  // ---------------------------------------------------------------------------
  // 19.1 Unit tests for Result<T>
  // ---------------------------------------------------------------------------

  group('Result — unit tests', () {
    group('Success', () {
      test('stores data and isSuccess is true', () {
        final result = Success(42);
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(42));
        expect(result.error, isNull);
      });

      test('works with string data', () {
        final result = Success('hello');
        expect(result.isSuccess, isTrue);
        expect(result.data, equals('hello'));
      });

      test('works with list data', () {
        final result = Success([1, 2, 3]);
        expect(result.isSuccess, isTrue);
        expect(result.data, equals([1, 2, 3]));
      });

      test('works with null-typed success (Result<void>)', () {
        final result = const Success<void>(null);
        expect(result.isSuccess, isTrue);
        expect(result.error, isNull);
      });
    });

    group('Failure', () {
      test('stores error and isSuccess is false', () {
        final appError = AppError.serverError('Something went wrong');
        final result = Failure<int>(appError);
        expect(result.isSuccess, isFalse);
        expect(result.error, equals(appError));
        expect(result.data, isNull);
      });

      test('stores error with status code', () {
        final appError = AppError.notFound('Not found');
        final result = Failure<String>(appError);
        expect(result.isSuccess, isFalse);
        expect(result.error!.status, equals(404));
        expect(result.error!.message, equals('Not found'));
      });
    });

    group('Result.when dispatch', () {
      test('calls success callback for success result', () {
        final result = Success(10);
        var successCalled = false;
        var failureCalled = false;

        result.when(
          success: (data) {
            successCalled = true;
            expect(data, equals(10));
          },
          failure: (_) {
            failureCalled = true;
          },
        );

        expect(successCalled, isTrue);
        expect(failureCalled, isFalse);
      });

      test('calls failure callback for failure result', () {
        final appError = AppError.serverError('error');
        final result = Failure<int>(appError);
        var successCalled = false;
        var failureCalled = false;

        result.when(
          success: (_) {
            successCalled = true;
          },
          failure: (e) {
            failureCalled = true;
            expect(e.message, equals('error'));
          },
        );

        expect(successCalled, isFalse);
        expect(failureCalled, isTrue);
      });

      test('when returns the value from the success callback', () {
        final result = Success(5);
        final value = result.when(
          success: (data) => data * 2,
          failure: (_) => -1,
        );
        expect(value, equals(10));
      });

      test('when returns the value from the failure callback', () {
        final result = Failure<int>(AppError.serverError('err'));
        final value = result.when(
          success: (data) => data * 2,
          failure: (_) => -1,
        );
        expect(value, equals(-1));
      });
    });

    group('Result.isSuccess', () {
      test('isSuccess is true for success result', () {
        expect(Success('x').isSuccess, isTrue);
      });

      test('isSuccess is false for failure result', () {
        expect(
          Failure<String>(AppError.serverError('fail')).isSuccess,
          isFalse,
        );
      });
    });
  });

  // ---------------------------------------------------------------------------
  // 19.2 Property 1: Result exhaustiveness
  // Feature: zoovana-cms-architecture, Property 1: for any Result, `when`
  // calls exactly one callback — never both, never neither.
  // ---------------------------------------------------------------------------

  group('Property 1 — Result exhaustiveness', () {
    test(
      'when() calls exactly one callback for any Result (100 iterations)',
      () {
        // Feature: zoovana-cms-architecture, Property 1: for any Result,
        // `when` calls exactly one callback — never both, never neither.
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          final isSuccess = random.nextBool();
          final Result<int> result = isSuccess
              ? Success(random.nextInt(10000))
              : Failure<int>(AppError.serverError('failure-$i'));

          var successCount = 0;
          var failureCount = 0;

          result.when(
            success: (_) => successCount++,
            failure: (_) => failureCount++,
          );

          // Exactly one callback must have been called.
          expect(
            successCount + failureCount,
            equals(1),
            reason:
                'Iteration $i: expected exactly 1 callback call, '
                'got success=$successCount failure=$failureCount',
          );

          // The correct callback must have been called.
          if (isSuccess) {
            expect(
              successCount,
              equals(1),
              reason: 'Iteration $i: expected success callback',
            );
          } else {
            expect(
              failureCount,
              equals(1),
              reason: 'Iteration $i: expected failure callback',
            );
          }
        }
      },
    );
  });
}
