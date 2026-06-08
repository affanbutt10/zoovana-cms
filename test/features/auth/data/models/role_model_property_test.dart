// Feature: zoovana-auth-rbac-shop-init, Property 6: RoleModel parsing round-trip
//
// Validates: Requirements 10.2, 16.4
//
// Property 6: RoleModel parsing round-trip — for any valid role JSON with
// string `id`, `name`, `scope`, `RoleModel.fromJson(json).toEntity()` produces
// a `RoleEntity` with equal field values.

import 'package:glados/glados.dart';
import 'package:zoovana_cms/features/auth/data/models/role_model.dart';
import 'package:zoovana_cms/features/auth/domain/entities/role_entity.dart';

// ---------------------------------------------------------------------------
// Custom generator: non-empty strings
// ---------------------------------------------------------------------------

extension NonEmptyStringAny on Any {
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
}

void main() {
  // ---------------------------------------------------------------------------
  // Property 6: RoleModel parsing round-trip
  //
  // For any non-empty strings id, name, scope:
  //   RoleModel.fromJson({'id': id, 'name': name, 'scope': scope}).toEntity()
  // produces a RoleEntity where entity.id == id, entity.name == name,
  // entity.scope == scope.
  // ---------------------------------------------------------------------------

  group('Property 6 — RoleModel parsing round-trip', () {
    Glados3<String, String, String>(
      any.nonEmptyString,
      any.nonEmptyString,
      any.nonEmptyString,
    ).test(
      'fromJson then toEntity preserves id, name, and scope',
      (id, name, scope) {
        final json = <String, dynamic>{
          'id': id,
          'name': name,
          'scope': scope,
        };

        final RoleEntity entity = RoleModel.fromJson(json).toEntity();

        expect(entity.id, equals(id),
            reason: 'entity.id must equal the original id');
        expect(entity.name, equals(name),
            reason: 'entity.name must equal the original name');
        expect(entity.scope, equals(scope),
            reason: 'entity.scope must equal the original scope');
      },
    );

    Glados3<String, String, String>(
      any.nonEmptyString,
      any.nonEmptyString,
      any.nonEmptyString,
    ).test(
      'fromJson then toEntity produces a RoleEntity (correct runtime type)',
      (id, name, scope) {
        final json = <String, dynamic>{
          'id': id,
          'name': name,
          'scope': scope,
        };

        final entity = RoleModel.fromJson(json).toEntity();

        expect(entity, isA<RoleEntity>());
      },
    );

    Glados3<String, String, String>(
      any.nonEmptyString,
      any.nonEmptyString,
      any.nonEmptyString,
    ).test(
      'fromJson then toEntity equals a directly constructed RoleEntity',
      (id, name, scope) {
        final json = <String, dynamic>{
          'id': id,
          'name': name,
          'scope': scope,
        };

        final entity = RoleModel.fromJson(json).toEntity();
        final expected = RoleEntity(id: id, name: name, scope: scope);

        expect(entity, equals(expected),
            reason:
                'round-trip entity must equal a directly constructed RoleEntity');
      },
    );
  });
}
