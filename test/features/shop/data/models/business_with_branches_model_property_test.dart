// Feature: zoovana-auth-rbac-shop-init, Property 8: BusinessWithBranchesModel round-trip
//
// Validates: Requirements 15.3, 15.5
//
// Property 8: BusinessWithBranchesModel round-trip preserves branch count and
// IDs — for any valid JSON with M branch objects,
// `BusinessWithBranchesModel.fromJson(json).toEntity()` produces an entity
// where `branches.length == M` and every `branches[i].id` equals
// `json['branches'][i]['id']`.

import 'package:glados/glados.dart';
import 'package:zoovana_cms/features/shop/data/models/business_with_branches_model.dart';
import 'package:zoovana_cms/features/shop/domain/entities/business_with_branches_entity.dart';

// ---------------------------------------------------------------------------
// Custom generators
// ---------------------------------------------------------------------------

extension BusinessWithBranchesAny on Any {
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

  /// Generates a branch count between 0 and 5 (inclusive).
  Generator<int> get branchCount => simple(
        generate: (random, size) => random.nextInt(6), // 0..5
        shrink: (n) {
          if (n <= 0) return [];
          return [n - 1];
        },
      );

  /// Generates a valid business-with-branches JSON map with [branchCount]
  /// branch objects.
  Generator<Map<String, dynamic>> get businessWithBranchesJson =>
      combine2(nonEmptyString, branchCount, (String token, int m) {
        // Build M branch objects, each with a unique, deterministic id
        final branches = List<Map<String, dynamic>>.generate(
          m,
          (i) => <String, dynamic>{
            'id': 'branch-id-$i-$token',
            'business_id': 'biz-id-$token',
            'name': 'Branch $i',
            'address': null,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00.000Z',
          },
        );

        return <String, dynamic>{
          'id': 'biz-$token',
          'name': 'Business $token',
          'owner_id': 'owner-$token',
          'tenant_id': 'tenant-$token',
          'status': 'active',
          'created_at': '2024-01-01T00:00:00.000Z',
          'branches': branches,
        };
      });
}

void main() {
  // ---------------------------------------------------------------------------
  // Property 8: BusinessWithBranchesModel round-trip
  //
  // For any valid business-with-branches JSON with M branch objects:
  //   BusinessWithBranchesModel.fromJson(json).toEntity()
  // produces an entity where:
  //   - entity.branches.length == M
  //   - entity.branches[i].id == json['branches'][i]['id'] for all i
  // ---------------------------------------------------------------------------

  group('Property 8 — BusinessWithBranchesModel round-trip', () {
    Glados<Map<String, dynamic>>(any.businessWithBranchesJson).test(
      'fromJson then toEntity preserves branch count (branches.length == M)',
      (json) {
        final BusinessWithBranchesEntity entity =
            BusinessWithBranchesModel.fromJson(json).toEntity();

        final expectedCount =
            (json['branches'] as List<dynamic>).length;

        expect(
          entity.branches.length,
          equals(expectedCount),
          reason:
              'entity.branches.length must equal the number of branch objects in JSON',
        );
      },
    );

    Glados<Map<String, dynamic>>(any.businessWithBranchesJson).test(
      'fromJson then toEntity preserves every branch id',
      (json) {
        final BusinessWithBranchesEntity entity =
            BusinessWithBranchesModel.fromJson(json).toEntity();

        final jsonBranches = json['branches'] as List<dynamic>;

        for (var i = 0; i < jsonBranches.length; i++) {
          final expectedId =
              (jsonBranches[i] as Map<String, dynamic>)['id'] as String;
          expect(
            entity.branches[i].id,
            equals(expectedId),
            reason:
                'entity.branches[$i].id must equal json[\'branches\'][$i][\'id\']',
          );
        }
      },
    );

    // Combined test: both properties hold simultaneously
    Glados<Map<String, dynamic>>(any.businessWithBranchesJson).test(
      'fromJson then toEntity preserves branch count and all branch IDs simultaneously',
      (json) {
        final BusinessWithBranchesEntity entity =
            BusinessWithBranchesModel.fromJson(json).toEntity();

        final jsonBranches = json['branches'] as List<dynamic>;

        expect(
          entity.branches.length,
          equals(jsonBranches.length),
          reason: 'branches.length must equal M',
        );

        for (var i = 0; i < jsonBranches.length; i++) {
          final expectedId =
              (jsonBranches[i] as Map<String, dynamic>)['id'] as String;
          expect(
            entity.branches[i].id,
            equals(expectedId),
            reason:
                'branches[$i].id must equal json[\'branches\'][$i][\'id\']',
          );
        }
      },
    );

    Glados<Map<String, dynamic>>(any.businessWithBranchesJson).test(
      'fromJson then toEntity produces a BusinessWithBranchesEntity (correct runtime type)',
      (json) {
        final entity = BusinessWithBranchesModel.fromJson(json).toEntity();

        expect(entity, isA<BusinessWithBranchesEntity>());
      },
    );
  });
}
