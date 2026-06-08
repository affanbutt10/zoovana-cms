import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/shared/models/pagination_model.dart';

void main() {
  // ---------------------------------------------------------------------------
  // 19.5 Property 4: PaginationModel round trip
  // Feature: zoovana-cms-architecture, Property 4: random pagination JSON →
  // fromJson → field equality
  // ---------------------------------------------------------------------------

  group('Property 4 — PaginationModel round trip', () {
    test(
      'fromJson parses all four fields correctly for random pagination JSON '
      '(100 iterations)',
      () {
        // Feature: zoovana-cms-architecture, Property 4: for any valid
        // pagination JSON object with currentPage, lastPage, total, and
        // perPage fields, PaginationModel.fromJson must parse all four fields
        // correctly.
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          final currentPage = random.nextInt(100) + 1; // 1..100
          final lastPage = currentPage + random.nextInt(50); // >= currentPage
          final perPage = (random.nextInt(10) + 1) * 10; // 10, 20, ..., 100
          final total = lastPage * perPage + random.nextInt(perPage);

          final json = <String, dynamic>{
            'current_page': currentPage,
            'last_page': lastPage,
            'total': total,
            'per_page': perPage,
          };

          final model = PaginationModel.fromJson(json);

          expect(
            model.currentPage,
            equals(currentPage),
            reason: 'Iteration $i: currentPage mismatch',
          );
          expect(
            model.lastPage,
            equals(lastPage),
            reason: 'Iteration $i: lastPage mismatch',
          );
          expect(
            model.total,
            equals(total),
            reason: 'Iteration $i: total mismatch',
          );
          expect(
            model.perPage,
            equals(perPage),
            reason: 'Iteration $i: perPage mismatch',
          );
        }
      },
    );

    test('hasNextPage is true when currentPage < lastPage', () {
      final model = PaginationModel.fromJson({
        'current_page': 1,
        'last_page': 5,
        'total': 50,
        'per_page': 10,
      });
      expect(model.hasNextPage, isTrue);
    });

    test('hasNextPage is false when currentPage == lastPage', () {
      final model = PaginationModel.fromJson({
        'current_page': 5,
        'last_page': 5,
        'total': 50,
        'per_page': 10,
      });
      expect(model.hasNextPage, isFalse);
    });
  });
}
