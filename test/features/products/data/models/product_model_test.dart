import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/features/products/data/models/product_model.dart';
import 'package:zoovana_cms/features/products/domain/entities/product_entity.dart';

void main() {
  // ---------------------------------------------------------------------------
  // 19.3 Property 2: ProductModel round trip
  // Feature: zoovana-cms-architecture, Property 2: random JSON → fromJson →
  // toEntity → field equality
  // ---------------------------------------------------------------------------

  group('Property 2 — ProductModel round trip', () {
    test(
      'fromJson → toEntity produces ProductEntity with matching fields '
      '(100 iterations)',
      () {
        // Feature: zoovana-cms-architecture, Property 2: for any valid
        // ProductModel constructed from a JSON map, calling toEntity() and
        // then reading each field must produce values equal to those in the
        // original JSON map (after type coercion).
        final random = Random(42);
        const statuses = ['active', 'inactive', 'draft'];

        for (var i = 0; i < 100; i++) {
          final id = 'prod-${random.nextInt(100000)}';
          final name = 'Product ${random.nextInt(1000)}';
          final description = 'Description for product $i';
          // Use integer prices to avoid floating-point precision issues.
          final price = (random.nextInt(10000) + 1).toDouble();
          final statusStr = statuses[random.nextInt(statuses.length)];
          final categoryId = 'cat-${random.nextInt(100)}';
          final vendorId = 'ven-${random.nextInt(100)}';
          final hasImage = random.nextBool();
          final imageUrl =
              hasImage ? 'https://example.com/image-$i.png' : null;

          final json = <String, dynamic>{
            'id': id,
            'name': name,
            'description': description,
            'price': price,
            'status': statusStr,
            'category_id': categoryId,
            'vendor_id': vendorId,
            if (imageUrl != null) 'image_url': imageUrl,
          };

          final model = ProductModel.fromJson(json);
          final entity = model.toEntity();

          expect(
            entity.id,
            equals(id),
            reason: 'Iteration $i: id mismatch',
          );
          expect(
            entity.name,
            equals(name),
            reason: 'Iteration $i: name mismatch',
          );
          expect(
            entity.description,
            equals(description),
            reason: 'Iteration $i: description mismatch',
          );
          expect(
            entity.price,
            equals(price),
            reason: 'Iteration $i: price mismatch',
          );
          expect(
            entity.categoryId,
            equals(categoryId),
            reason: 'Iteration $i: categoryId mismatch',
          );
          expect(
            entity.vendorId,
            equals(vendorId),
            reason: 'Iteration $i: vendorId mismatch',
          );
          expect(
            entity.imageUrl,
            equals(imageUrl),
            reason: 'Iteration $i: imageUrl mismatch',
          );

          // Verify status mapping.
          final expectedStatus = _parseStatus(statusStr);
          expect(
            entity.status,
            equals(expectedStatus),
            reason: 'Iteration $i: status mismatch for "$statusStr"',
          );
        }
      },
    );

    test('fromJson handles nested data wrapper', () {
      final json = <String, dynamic>{
        'data': {
          'id': 'p1',
          'name': 'Widget',
          'description': 'A widget',
          'price': 9.99,
          'status': 'active',
          'category_id': 'c1',
          'vendor_id': 'v1',
        },
      };

      final model = ProductModel.fromJson(json);
      expect(model.id, equals('p1'));
      expect(model.name, equals('Widget'));
    });

    test('fromJson defaults missing price to 0.0', () {
      final json = <String, dynamic>{
        'id': 'p1',
        'name': 'Widget',
        'description': 'desc',
        'status': 'active',
        'category_id': 'c1',
        'vendor_id': 'v1',
      };
      final model = ProductModel.fromJson(json);
      expect(model.price, equals(0.0));
    });

    test('fromJson defaults missing status to draft', () {
      final json = <String, dynamic>{
        'id': 'p1',
        'name': 'Widget',
        'description': 'desc',
        'price': 5.0,
        'category_id': 'c1',
        'vendor_id': 'v1',
      };
      final model = ProductModel.fromJson(json);
      expect(model.toEntity().status, equals(ProductStatus.draft));
    });
  });
}

/// Mirrors the status parsing logic in ProductModel for test verification.
ProductStatus _parseStatus(String value) {
  switch (value) {
    case 'active':
      return ProductStatus.active;
    case 'inactive':
      return ProductStatus.inactive;
    default:
      return ProductStatus.draft;
  }
}
