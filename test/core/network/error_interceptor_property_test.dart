// Feature: zoovana-auth-rbac-shop-init, Property 3: ErrorInterceptor status-to-flag mapping
//
// Validates: Requirements 3.5–3.11
//
// Property 3: ErrorInterceptor maps status codes to correct AppError flags —
// for each status in {400, 401, 403, 404, 409, 422, 500}, the interceptor
// produces an AppError with the correct flag true, correct status field, and
// all other flags false.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:glados/glados.dart';
import 'package:zoovana_cms/core/error/app_error.dart';
import 'package:zoovana_cms/core/network/interceptors/error_interceptor.dart';

// ---------------------------------------------------------------------------
// Helper: invoke ErrorInterceptor.onError and capture the rejected AppError
// ---------------------------------------------------------------------------

/// Creates a [DioException] with a mock response for the given [statusCode].
DioException _makeDioException(int statusCode, {dynamic body}) {
  final requestOptions = RequestOptions(path: '/test');
  final response = Response(
    requestOptions: requestOptions,
    statusCode: statusCode,
    data: body ?? {'detail': 'Test error for status $statusCode'},
  );
  return DioException(
    requestOptions: requestOptions,
    response: response,
    type: DioExceptionType.badResponse,
  );
}

/// Runs [ErrorInterceptor.onError] and returns the [AppError] captured from
/// the rejected [DioException.error].
///
/// The interceptor calls [handler.reject], which throws a [DioException].
/// We capture that exception and extract the [AppError] from its [error] field.
Future<AppError> _captureAppError(int statusCode, {dynamic body}) async {
  final interceptor = ErrorInterceptor();
  final dioException = _makeDioException(statusCode, body: body);

  final completer = Completer<AppError>();

  final handler = _CapturingErrorHandler(
    onReject: (rejected) {
      final appError = rejected.error;
      if (appError is AppError) {
        completer.complete(appError);
      } else {
        completer.completeError(
          StateError('Expected AppError but got: ${appError.runtimeType}'),
        );
      }
    },
    onNext: (err) {
      completer.completeError(
        StateError('Expected reject but got next: $err'),
      );
    },
    onResolve: (response) {
      completer.completeError(
        StateError('Expected reject but got resolve: $response'),
      );
    },
  );

  interceptor.onError(dioException, handler);
  return completer.future;
}

/// A minimal [ErrorInterceptorHandler] that captures the reject/next/resolve
/// call without requiring a real Dio interceptor chain.
class _CapturingErrorHandler extends ErrorInterceptorHandler {
  final void Function(DioException rejected) onReject;
  final void Function(DioException err) onNext;
  final void Function(Response response) onResolve;

  _CapturingErrorHandler({
    required this.onReject,
    required this.onNext,
    required this.onResolve,
  });

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    onReject(err);
  }

  @override
  void next(DioException err) {
    onNext(err);
  }

  @override
  void resolve(Response response,
      [bool callFollowingResponseInterceptor = false]) {
    onResolve(response);
  }
}

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
// Tests
// ---------------------------------------------------------------------------

void main() {
  // The 7 status codes under test and their expected flag names.
  const statusToFlag = <int, String>{
    400: 'badRequest',
    401: 'unauthorized',
    403: 'forbidden',
    404: 'notFound',
    409: 'conflict',
    422: 'validationErrors',
    500: 'serverError',
  };

  // ---------------------------------------------------------------------------
  // Property 3: ErrorInterceptor status-to-flag mapping
  //
  // For each status code in {400, 401, 403, 404, 409, 422, 500}:
  //   1. The interceptor produces an AppError (not null, not a raw exception).
  //   2. The AppError.status field equals the HTTP status code.
  //   3. Exactly one boolean flag is true.
  //   4. The correct flag for that status code is true.
  //   5. All other flags are false.
  // ---------------------------------------------------------------------------

  group('Property 3 — ErrorInterceptor status-to-flag mapping', () {
    // -------------------------------------------------------------------------
    // HTTP 400 → AppError.badRequest
    // -------------------------------------------------------------------------
    Glados(any.int).test(
      'HTTP 400: produces AppError with badRequest=true, status=400, all others false',
      (_) async {
        final appError = await _captureAppError(400);

        expect(appError.status, equals(400),
            reason: 'status field must equal 400');
        expect(appError.badRequest, isTrue,
            reason: 'badRequest flag must be true for HTTP 400');
        expect(_countTrueFlags(appError), equals(1),
            reason: 'Exactly one flag must be true');
        expect(appError.unauthorized, isFalse);
        expect(appError.forbidden, isFalse);
        expect(appError.notFound, isFalse);
        expect(appError.conflict, isFalse);
        expect(appError.validationErrors, isFalse);
        expect(appError.serverError, isFalse);
        expect(appError.networkError, isFalse);
        expect(appError.cancelled, isFalse);
      },
    );

    // -------------------------------------------------------------------------
    // HTTP 401 → AppError.unauthorized
    // -------------------------------------------------------------------------
    Glados(any.int).test(
      'HTTP 401: produces AppError with unauthorized=true, status=401, all others false',
      (_) async {
        final appError = await _captureAppError(401);

        expect(appError.status, equals(401),
            reason: 'status field must equal 401');
        expect(appError.unauthorized, isTrue,
            reason: 'unauthorized flag must be true for HTTP 401');
        expect(_countTrueFlags(appError), equals(1),
            reason: 'Exactly one flag must be true');
        expect(appError.badRequest, isFalse);
        expect(appError.forbidden, isFalse);
        expect(appError.notFound, isFalse);
        expect(appError.conflict, isFalse);
        expect(appError.validationErrors, isFalse);
        expect(appError.serverError, isFalse);
        expect(appError.networkError, isFalse);
        expect(appError.cancelled, isFalse);
      },
    );

    // -------------------------------------------------------------------------
    // HTTP 403 → AppError.forbidden
    // -------------------------------------------------------------------------
    Glados(any.int).test(
      'HTTP 403: produces AppError with forbidden=true, status=403, all others false',
      (_) async {
        final appError = await _captureAppError(403);

        expect(appError.status, equals(403),
            reason: 'status field must equal 403');
        expect(appError.forbidden, isTrue,
            reason: 'forbidden flag must be true for HTTP 403');
        expect(_countTrueFlags(appError), equals(1),
            reason: 'Exactly one flag must be true');
        expect(appError.badRequest, isFalse);
        expect(appError.unauthorized, isFalse);
        expect(appError.notFound, isFalse);
        expect(appError.conflict, isFalse);
        expect(appError.validationErrors, isFalse);
        expect(appError.serverError, isFalse);
        expect(appError.networkError, isFalse);
        expect(appError.cancelled, isFalse);
      },
    );

    // -------------------------------------------------------------------------
    // HTTP 404 → AppError.notFound
    // -------------------------------------------------------------------------
    Glados(any.int).test(
      'HTTP 404: produces AppError with notFound=true, status=404, all others false',
      (_) async {
        final appError = await _captureAppError(404);

        expect(appError.status, equals(404),
            reason: 'status field must equal 404');
        expect(appError.notFound, isTrue,
            reason: 'notFound flag must be true for HTTP 404');
        expect(_countTrueFlags(appError), equals(1),
            reason: 'Exactly one flag must be true');
        expect(appError.badRequest, isFalse);
        expect(appError.unauthorized, isFalse);
        expect(appError.forbidden, isFalse);
        expect(appError.conflict, isFalse);
        expect(appError.validationErrors, isFalse);
        expect(appError.serverError, isFalse);
        expect(appError.networkError, isFalse);
        expect(appError.cancelled, isFalse);
      },
    );

    // -------------------------------------------------------------------------
    // HTTP 409 → AppError.conflict
    // -------------------------------------------------------------------------
    Glados(any.int).test(
      'HTTP 409: produces AppError with conflict=true, status=409, all others false',
      (_) async {
        final appError = await _captureAppError(409);

        expect(appError.status, equals(409),
            reason: 'status field must equal 409');
        expect(appError.conflict, isTrue,
            reason: 'conflict flag must be true for HTTP 409');
        expect(_countTrueFlags(appError), equals(1),
            reason: 'Exactly one flag must be true');
        expect(appError.badRequest, isFalse);
        expect(appError.unauthorized, isFalse);
        expect(appError.forbidden, isFalse);
        expect(appError.notFound, isFalse);
        expect(appError.validationErrors, isFalse);
        expect(appError.serverError, isFalse);
        expect(appError.networkError, isFalse);
        expect(appError.cancelled, isFalse);
      },
    );

    // -------------------------------------------------------------------------
    // HTTP 422 → AppError.validationError
    // -------------------------------------------------------------------------
    Glados(any.int).test(
      'HTTP 422: produces AppError with validationErrors=true, status=422, all others false',
      (_) async {
        final appError = await _captureAppError(
          422,
          body: {
            'detail': [
              {
                'loc': ['body', 'email'],
                'msg': 'field required',
              }
            ]
          },
        );

        expect(appError.status, equals(422),
            reason: 'status field must equal 422');
        expect(appError.validationErrors, isTrue,
            reason: 'validationErrors flag must be true for HTTP 422');
        expect(_countTrueFlags(appError), equals(1),
            reason: 'Exactly one flag must be true');
        expect(appError.badRequest, isFalse);
        expect(appError.unauthorized, isFalse);
        expect(appError.forbidden, isFalse);
        expect(appError.notFound, isFalse);
        expect(appError.conflict, isFalse);
        expect(appError.serverError, isFalse);
        expect(appError.networkError, isFalse);
        expect(appError.cancelled, isFalse);
      },
    );

    // -------------------------------------------------------------------------
    // HTTP 500 → AppError.serverError
    // -------------------------------------------------------------------------
    Glados(any.int).test(
      'HTTP 500: produces AppError with serverError=true, status=500, all others false',
      (_) async {
        final appError = await _captureAppError(500);

        expect(appError.status, equals(500),
            reason: 'status field must equal 500');
        expect(appError.serverError, isTrue,
            reason: 'serverError flag must be true for HTTP 500');
        expect(_countTrueFlags(appError), equals(1),
            reason: 'Exactly one flag must be true');
        expect(appError.badRequest, isFalse);
        expect(appError.unauthorized, isFalse);
        expect(appError.forbidden, isFalse);
        expect(appError.notFound, isFalse);
        expect(appError.conflict, isFalse);
        expect(appError.validationErrors, isFalse);
        expect(appError.networkError, isFalse);
        expect(appError.cancelled, isFalse);
      },
    );

    // -------------------------------------------------------------------------
    // Exhaustive check: all 7 status codes in a single parameterised test
    // -------------------------------------------------------------------------
    test(
      'All 7 status codes produce AppError with correct flag and status field',
      () async {
        for (final entry in statusToFlag.entries) {
          final statusCode = entry.key;
          final expectedFlagName = entry.value;

          final body = statusCode == 422
              ? {
                  'detail': [
                    {
                      'loc': ['body', 'field'],
                      'msg': 'required',
                    }
                  ]
                }
              : {'detail': 'error for $statusCode'};

          final appError = await _captureAppError(statusCode, body: body);

          expect(appError.status, equals(statusCode),
              reason:
                  'status field must equal $statusCode for flag $expectedFlagName');
          expect(_countTrueFlags(appError), equals(1),
              reason:
                  'Exactly one flag must be true for status $statusCode');

          // Verify the correct flag is true
          switch (statusCode) {
            case 400:
              expect(appError.badRequest, isTrue,
                  reason: 'badRequest must be true for 400');
            case 401:
              expect(appError.unauthorized, isTrue,
                  reason: 'unauthorized must be true for 401');
            case 403:
              expect(appError.forbidden, isTrue,
                  reason: 'forbidden must be true for 403');
            case 404:
              expect(appError.notFound, isTrue,
                  reason: 'notFound must be true for 404');
            case 409:
              expect(appError.conflict, isTrue,
                  reason: 'conflict must be true for 409');
            case 422:
              expect(appError.validationErrors, isTrue,
                  reason: 'validationErrors must be true for 422');
            case 500:
              expect(appError.serverError, isTrue,
                  reason: 'serverError must be true for 500');
          }
        }
      },
    );
  });
}
