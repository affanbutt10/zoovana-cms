// Feature: zoovana-auth-rbac-shop-init, Property 7: LoginResponseModel full round-trip
//
// Validates: Requirements 16.2, 16.3, 16.8, 16.9
//
// Property 7: LoginResponseModel full round-trip — for any valid login response
// JSON with N role objects, `LoginResponseModel.fromJson(json).toEntity()`
// preserves `accessToken`, `refreshToken`, `user.isSuperuser`, and
// `user.roles.length == N`.

import 'package:glados/glados.dart';
import 'package:zoovana_cms/features/auth/data/models/login_response_model.dart';
import 'package:zoovana_cms/features/auth/domain/entities/auth_session_entity.dart';

// ---------------------------------------------------------------------------
// Custom generators
// ---------------------------------------------------------------------------

extension LoginResponseAny on Any {
  /// Generates a non-empty string from a safe character set.
  Generator<String> get nonEmptyString => simple(
        generate: (random, size) {
          final length = 1 + random.nextInt(size < 1 ? 1 : size);
          const chars =
              'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
              '._-+/=';
          return List.generate(
            length,
            (_) => chars[random.nextInt(chars.length)],
          ).join();
        },
        shrink: (s) {
          if (s.length <= 1) return [];
          return [s.substring(0, s.length - 1)];
        },
      );

  /// Generates a role count between 0 and 5 (inclusive).
  Generator<int> get roleCount => simple(
        generate: (random, size) => random.nextInt(6), // 0..5
        shrink: (n) {
          if (n <= 0) return [];
          return [n - 1];
        },
      );

  /// Generates a valid login response JSON map with [roleCount] roles.
  Generator<Map<String, dynamic>> get loginResponseJson =>
      combine2(nonEmptyString, roleCount, (String token, int n) {
        // Build N role objects
        final roles = List<Map<String, dynamic>>.generate(
          n,
          (i) => <String, dynamic>{
            'id': 'role-id-$i',
            'name': 'role_name_$i',
            'scope': 'tenant',
          },
        );

        return <String, dynamic>{
          'access_token': 'access_$token',
          'refresh_token': 'refresh_$token',
          'expires_in': 3600,
          'user': <String, dynamic>{
            'id': 'user-id',
            'email': 'user@example.com',
            'full_name': 'Test User',
            'is_superuser': false,
            'is_email_verified': true,
            'roles': roles,
            'default_tenant_id': 'tenant-id',
          },
        };
      });

  /// Generates a login response JSON with a superuser flag that varies.
  Generator<Map<String, dynamic>> get loginResponseJsonWithSuperuser =>
      combine3(nonEmptyString, roleCount, any.bool, (
        String token,
        int n,
        bool isSuperuser,
      ) {
        final roles = List<Map<String, dynamic>>.generate(
          n,
          (i) => <String, dynamic>{
            'id': 'role-id-$i',
            'name': 'role_name_$i',
            'scope': 'tenant',
          },
        );

        return <String, dynamic>{
          'access_token': 'access_$token',
          'refresh_token': 'refresh_$token',
          'expires_in': 3600,
          'user': <String, dynamic>{
            'id': 'user-id',
            'email': 'user@example.com',
            'full_name': 'Test User',
            'is_superuser': isSuperuser,
            'is_email_verified': true,
            'roles': roles,
            'default_tenant_id': 'tenant-id',
          },
        };
      });
}

void main() {
  // ---------------------------------------------------------------------------
  // Property 7: LoginResponseModel full round-trip
  //
  // For any valid login response JSON with N role objects:
  //   LoginResponseModel.fromJson(json).toEntity()
  // preserves accessToken, refreshToken, user.isSuperuser, and
  // user.roles.length == N.
  // ---------------------------------------------------------------------------

  group('Property 7 — LoginResponseModel full round-trip', () {
    Glados<Map<String, dynamic>>(any.loginResponseJson).test(
      'fromJson then toEntity preserves accessToken',
      (json) {
        final AuthSessionEntity entity =
            LoginResponseModel.fromJson(json).toEntity();

        expect(
          entity.accessToken,
          equals(json['access_token'] as String),
          reason: 'entity.accessToken must equal the original access_token',
        );
      },
    );

    Glados<Map<String, dynamic>>(any.loginResponseJson).test(
      'fromJson then toEntity preserves refreshToken',
      (json) {
        final AuthSessionEntity entity =
            LoginResponseModel.fromJson(json).toEntity();

        expect(
          entity.refreshToken,
          equals(json['refresh_token'] as String),
          reason: 'entity.refreshToken must equal the original refresh_token',
        );
      },
    );

    Glados<Map<String, dynamic>>(any.loginResponseJsonWithSuperuser).test(
      'fromJson then toEntity preserves user.isSuperuser',
      (json) {
        final AuthSessionEntity entity =
            LoginResponseModel.fromJson(json).toEntity();

        final expectedIsSuperuser =
            (json['user'] as Map<String, dynamic>)['is_superuser'] as bool;

        expect(
          entity.user.isSuperuser,
          equals(expectedIsSuperuser),
          reason: 'entity.user.isSuperuser must equal the original is_superuser',
        );
      },
    );

    Glados<Map<String, dynamic>>(any.loginResponseJson).test(
      'fromJson then toEntity preserves user.roles.length == N',
      (json) {
        final AuthSessionEntity entity =
            LoginResponseModel.fromJson(json).toEntity();

        final expectedRoleCount =
            ((json['user'] as Map<String, dynamic>)['roles'] as List<dynamic>)
                .length;

        expect(
          entity.user.roles.length,
          equals(expectedRoleCount),
          reason:
              'entity.user.roles.length must equal the number of role objects in JSON',
        );
      },
    );

    // Combined test: all four properties hold simultaneously
    Glados<Map<String, dynamic>>(any.loginResponseJsonWithSuperuser).test(
      'fromJson then toEntity preserves all four properties simultaneously',
      (json) {
        final AuthSessionEntity entity =
            LoginResponseModel.fromJson(json).toEntity();

        final userJson = json['user'] as Map<String, dynamic>;
        final expectedRoleCount =
            (userJson['roles'] as List<dynamic>).length;

        expect(
          entity.accessToken,
          equals(json['access_token'] as String),
          reason: 'accessToken must be preserved',
        );
        expect(
          entity.refreshToken,
          equals(json['refresh_token'] as String),
          reason: 'refreshToken must be preserved',
        );
        expect(
          entity.user.isSuperuser,
          equals(userJson['is_superuser'] as bool),
          reason: 'user.isSuperuser must be preserved',
        );
        expect(
          entity.user.roles.length,
          equals(expectedRoleCount),
          reason: 'user.roles.length must equal N',
        );
      },
    );
  });
}
