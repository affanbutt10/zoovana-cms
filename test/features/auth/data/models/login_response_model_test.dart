import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/features/auth/data/models/login_response_model.dart';
import 'package:zoovana_cms/features/auth/domain/entities/auth_session_entity.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Feature: zoovana-auth-rbac-shop-init, Property 7:
  // LoginResponseModel full round-trip — for any valid login response JSON
  // with N role objects, LoginResponseModel.fromJson(json).toEntity()
  // preserves accessToken, refreshToken, user.isSuperuser, and
  // user.roles.length == N.
  // Validates: Requirements 16.2, 16.3, 16.8, 16.9
  // ---------------------------------------------------------------------------

  group('LoginResponseModel — fromJson / toEntity round-trip', () {
    Map<String, dynamic> buildRoleJson(int index) => {
          'id': 'role-$index',
          'name': 'role_name_$index',
          'scope': 'tenant',
        };

    Map<String, dynamic> buildUserJson({
      required bool isSuperuser,
      required int roleCount,
    }) =>
        {
          'id': 'user-uuid',
          'email': 'user@example.com',
          'full_name': 'Jane Doe',
          'is_superuser': isSuperuser,
          'is_email_verified': true,
          'roles': List.generate(roleCount, buildRoleJson),
          'default_tenant_id': 'tenant-uuid',
        };

    Map<String, dynamic> buildLoginResponseJson({
      required String accessToken,
      required String refreshToken,
      required int expiresIn,
      required bool isSuperuser,
      required int roleCount,
    }) =>
        {
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'expires_in': expiresIn,
          'user': buildUserJson(
            isSuperuser: isSuperuser,
            roleCount: roleCount,
          ),
        };

    test(
      'fromJson → toEntity preserves accessToken and refreshToken '
      '(100 iterations)',
      () {
        // Feature: zoovana-auth-rbac-shop-init, Property 7
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          final accessToken = 'access-${random.nextInt(999999)}';
          final refreshToken = 'refresh-${random.nextInt(999999)}';
          final expiresIn = 3600 + random.nextInt(3600);
          final roleCount = random.nextInt(4); // 0–3 roles

          final json = buildLoginResponseJson(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            isSuperuser: random.nextBool(),
            roleCount: roleCount,
          );

          final entity = LoginResponseModel.fromJson(json).toEntity();

          expect(
            entity.accessToken,
            equals(accessToken),
            reason: 'Iteration $i: accessToken mismatch',
          );
          expect(
            entity.refreshToken,
            equals(refreshToken),
            reason: 'Iteration $i: refreshToken mismatch',
          );
          expect(
            entity.expiresIn,
            equals(expiresIn),
            reason: 'Iteration $i: expiresIn mismatch',
          );
          expect(
            entity.user.roles.length,
            equals(roleCount),
            reason: 'Iteration $i: roles.length mismatch',
          );
        }
      },
    );

    test(
      'fromJson → toEntity preserves user.isSuperuser flag '
      '(100 iterations)',
      () {
        // Feature: zoovana-auth-rbac-shop-init, Property 7
        final random = Random(99);

        for (var i = 0; i < 100; i++) {
          final isSuperuser = random.nextBool();

          final json = buildLoginResponseJson(
            accessToken: 'access-$i',
            refreshToken: 'refresh-$i',
            expiresIn: 3600,
            isSuperuser: isSuperuser,
            roleCount: 1,
          );

          final entity = LoginResponseModel.fromJson(json).toEntity();

          expect(
            entity.user.isSuperuser,
            equals(isSuperuser),
            reason: 'Iteration $i: isSuperuser mismatch',
          );
        }
      },
    );

    test('toEntity always sets status to AuthSessionStatus.active', () {
      final json = buildLoginResponseJson(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresIn: 3600,
        isSuperuser: false,
        roleCount: 1,
      );

      final entity = LoginResponseModel.fromJson(json).toEntity();

      expect(entity.status, equals(AuthSessionStatus.active));
    });

    test('fromJson parses nested roles with correct field values', () {
      final json = {
        'access_token': 'access-abc',
        'refresh_token': 'refresh-xyz',
        'expires_in': 7200,
        'user': {
          'id': 'user-1',
          'email': 'admin@example.com',
          'full_name': 'Admin User',
          'is_superuser': true,
          'is_email_verified': true,
          'roles': [
            {'id': 'role-1', 'name': 'shop_owner', 'scope': 'tenant'},
            {'id': 'role-2', 'name': 'admin', 'scope': 'global'},
          ],
          'default_tenant_id': 'tenant-1',
        },
      };

      final entity = LoginResponseModel.fromJson(json).toEntity();

      expect(entity.user.roles.length, equals(2));
      expect(entity.user.roles[0].id, equals('role-1'));
      expect(entity.user.roles[0].name, equals('shop_owner'));
      expect(entity.user.roles[0].scope, equals('tenant'));
      expect(entity.user.roles[1].id, equals('role-2'));
      expect(entity.user.roles[1].name, equals('admin'));
      expect(entity.user.roles[1].scope, equals('global'));
    });
  });
}
