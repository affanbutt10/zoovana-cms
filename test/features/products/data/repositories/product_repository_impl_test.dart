import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoovana_cms/core/error/exceptions.dart';
import 'package:zoovana_cms/core/error/result.dart';
import 'package:zoovana_cms/features/products/data/datasources/product_remote_datasource.dart';
import 'package:zoovana_cms/features/products/data/models/product_model.dart';
import 'package:zoovana_cms/features/products/data/repositories/product_repository_impl.dart';
import 'package:zoovana_cms/features/products/domain/entities/product_entity.dart';

// ---------------------------------------------------------------------------
// Manual mock for ProductRemoteDataSource
// ---------------------------------------------------------------------------

class _MockProductRemoteDataSource implements ProductRemoteDataSource {
  /// When set, getProducts returns this list.
  List<ProductModel>? productsToReturn;

  /// When set, getProducts throws this exception.
  Exception? exceptionToThrow;

  @override
  Future<List<ProductModel>> getProducts({int page = 1}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return productsToReturn ?? [];
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return productsToReturn!.first;
  }

  @override
  Future<ProductModel> createProduct(ProductEntity product) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return productsToReturn!.first;
  }

  @override
  Future<ProductModel> updateProduct(ProductEntity product) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return productsToReturn!.first;
  }

  @override
  Future<void> deleteProduct(String id) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }

  @override
  Future<String> uploadProductImage(String id, String filePath) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return 'https://example.com/image.png';
  }

  @override
  Future<ProductModel> updateProductStatus(
    String id,
    ProductStatus status,
  ) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return productsToReturn!.first;
  }
}

// ---------------------------------------------------------------------------
// Helper to build a ProductModel with given index
// ---------------------------------------------------------------------------

ProductModel _buildModel(int index) => ProductModel(
      id: 'prod-$index',
      name: 'Product $index',
      description: 'Description $index',
      price: (index + 1) * 10.0,
      status: 'active',
      categoryId: 'cat-1',
      vendorId: 'ven-1',
    );

void main() {
  late _MockProductRemoteDataSource mockDataSource;
  late ProductRepositoryImpl repository;

  setUp(() {
    mockDataSource = _MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(mockDataSource);
  });

  // ---------------------------------------------------------------------------
  // 19.11 Unit tests for ProductRepositoryImpl
  // ---------------------------------------------------------------------------

  group('ProductRepositoryImpl — unit tests', () {
    group('getProducts — success path', () {
      test('returns Success with mapped entities', () async {
        mockDataSource.productsToReturn = [_buildModel(0), _buildModel(1)];

        final result = await repository.getProducts();

        expect(result.isSuccess, isTrue);
        expect(result.data, hasLength(2));
        expect(result.data![0].id, equals('prod-0'));
        expect(result.data![1].id, equals('prod-1'));
      });

      test('returns Success with empty list when no products', () async {
        mockDataSource.productsToReturn = [];

        final result = await repository.getProducts();

        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });
    });

    group('getProducts — failure path', () {
      test('wraps NetworkException in Failure', () async {
        mockDataSource.exceptionToThrow =
            const NetworkException('No internet');

        final result = await repository.getProducts();

        expect(result.isSuccess, isFalse);
        expect(result.error!.message, equals('No internet'));
      });

      test('wraps ServerException in Failure', () async {
        mockDataSource.exceptionToThrow =
            const ServerException(message: 'Not found', statusCode: 404);

        final result = await repository.getProducts();

        expect(result.isSuccess, isFalse);
        expect(result.error!.message, equals('Not found'));
      });

      test('wraps generic exception in Failure', () async {
        mockDataSource.exceptionToThrow = Exception('Unexpected error');

        final result = await repository.getProducts();

        expect(result.isSuccess, isFalse);
        expect(result.error!.message, isNotEmpty);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // 19.8 Property 7: Repository success wraps entity
  // Feature: zoovana-cms-architecture, Property 7: mocked data source returns
  // models → Success with correct length
  // ---------------------------------------------------------------------------

  group('Property 7 — Repository success wraps entity', () {
    test(
      'getProducts returns Success whose data length equals the '
      'number of models returned by the data source (100 iterations)',
      () async {
        // Feature: zoovana-cms-architecture, Property 7: for any successful
        // ProductRepositoryImpl.getProducts call (with a mocked data source
        // returning valid models), the returned Result must be a success
        // result whose data list length equals the number of models returned
        // by the data source.
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          final count = random.nextInt(21); // 0..20 models
          mockDataSource.exceptionToThrow = null;
          mockDataSource.productsToReturn =
              List.generate(count, (j) => _buildModel(j));

          final result = await repository.getProducts(page: 1);

          expect(
            result.isSuccess,
            isTrue,
            reason: 'Iteration $i: expected success result',
          );
          expect(
            result.data,
            hasLength(count),
            reason:
                'Iteration $i: expected $count entities, '
                'got ${result.data?.length}',
          );
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // 19.9 Property 8: Repository failure wraps failure
  // Feature: zoovana-cms-architecture, Property 8: mocked data source throws
  // → Failure with non-empty message
  // ---------------------------------------------------------------------------

  group('Property 8 — Repository failure wraps failure', () {
    test(
      'getProducts returns Failure with non-empty message when data '
      'source throws (100 iterations)',
      () async {
        // Feature: zoovana-cms-architecture, Property 8: for any
        // ProductRepositoryImpl operation where the data source throws an
        // exception, the returned Result must be a failure result with a
        // non-empty message and the data field must be null.
        final random = Random(42);

        // Pool of exceptions that the data source might throw.
        final exceptions = <Exception Function(int)>[
          (i) => NetworkException('Network error $i'),
          (i) => ServerException(message: 'Server error $i', statusCode: 500),
          (i) => CacheException('Cache error $i'),
          (i) => Exception('Generic error $i'),
        ];

        for (var i = 0; i < 100; i++) {
          final exceptionFactory =
              exceptions[random.nextInt(exceptions.length)];
          mockDataSource.exceptionToThrow = exceptionFactory(i);
          mockDataSource.productsToReturn = null;

          final result = await repository.getProducts(page: 1);

          expect(
            result.isSuccess,
            isFalse,
            reason: 'Iteration $i: expected failure result',
          );
          expect(
            result.error,
            isNotNull,
            reason: 'Iteration $i: error should not be null',
          );
          expect(
            result.error!.message,
            isNotEmpty,
            reason: 'Iteration $i: error message should not be empty',
          );
          expect(
            result.data,
            isNull,
            reason: 'Iteration $i: data should be null on failure',
          );
        }
      },
    );
  });
}
