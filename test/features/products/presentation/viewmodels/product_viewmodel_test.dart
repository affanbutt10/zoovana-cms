import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zoovana_cms/core/error/app_error.dart';
import 'package:zoovana_cms/core/error/result.dart';
import 'package:zoovana_cms/features/products/domain/entities/product_entity.dart';
import 'package:zoovana_cms/features/products/domain/repositories/product_repository.dart';
import 'package:zoovana_cms/features/products/domain/usecases/create_product_usecase.dart';
import 'package:zoovana_cms/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:zoovana_cms/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:zoovana_cms/features/products/domain/usecases/get_products_usecase.dart';
import 'package:zoovana_cms/features/products/domain/usecases/update_product_status_usecase.dart';
import 'package:zoovana_cms/features/products/domain/usecases/update_product_usecase.dart';
import 'package:zoovana_cms/features/products/domain/usecases/upload_product_image_usecase.dart';
import 'package:zoovana_cms/features/products/presentation/viewmodels/product_viewmodel.dart';

// ---------------------------------------------------------------------------
// Manual mock repository
// ---------------------------------------------------------------------------

class _MockProductRepository implements ProductRepository {
  Result<List<ProductEntity>>? getProductsResult;
  Result<ProductEntity>? getProductByIdResult;
  Result<ProductEntity>? createProductResult;
  Result<ProductEntity>? updateProductResult;
  Result<void>? deleteProductResult;
  Result<String>? uploadImageResult;
  Result<ProductEntity>? updateStatusResult;

  @override
  Future<Result<List<ProductEntity>>> getProducts({int page = 1}) async =>
      getProductsResult ?? Success([]);

  @override
  Future<Result<ProductEntity>> getProductById(String id) async =>
      getProductByIdResult ??
      Failure<ProductEntity>(AppError.serverError('not set'));

  @override
  Future<Result<ProductEntity>> createProduct(ProductEntity product) async =>
      createProductResult ??
      Failure<ProductEntity>(AppError.serverError('not set'));

  @override
  Future<Result<ProductEntity>> updateProduct(ProductEntity product) async =>
      updateProductResult ??
      Failure<ProductEntity>(AppError.serverError('not set'));

  @override
  Future<Result<void>> deleteProduct(String id) async =>
      deleteProductResult ??
      Failure<void>(AppError.serverError('not set'));

  @override
  Future<Result<String>> uploadProductImage(
    String id,
    String filePath,
  ) async =>
      uploadImageResult ??
      Failure<String>(AppError.serverError('not set'));

  @override
  Future<Result<ProductEntity>> updateProductStatus(
    String id,
    ProductStatus status,
  ) async =>
      updateStatusResult ??
      Failure<ProductEntity>(AppError.serverError('not set'));
}

// ---------------------------------------------------------------------------
// Helper to build a ProductEntity
// ---------------------------------------------------------------------------

ProductEntity _buildEntity(String id) => ProductEntity(
      id: id,
      name: 'Product $id',
      description: 'Description $id',
      price: 10.0,
      status: ProductStatus.active,
      categoryId: 'cat-1',
      vendorId: 'ven-1',
    );

// ---------------------------------------------------------------------------
// Helper to build a ProductViewModel from a mock repository
// ---------------------------------------------------------------------------

ProductViewModel _buildViewModel(_MockProductRepository repo) {
  return ProductViewModel(
    getProductsUseCase: GetProductsUseCase(repo),
    getProductByIdUseCase: GetProductByIdUseCase(repo),
    createProductUseCase: CreateProductUseCase(repo),
    updateProductUseCase: UpdateProductUseCase(repo),
    deleteProductUseCase: DeleteProductUseCase(repo),
    uploadProductImageUseCase: UploadProductImageUseCase(repo),
    updateProductStatusUseCase: UpdateProductStatusUseCase(repo),
  );
}

void main() {
  // GetX requires a binding context for navigation; we initialize it once.
  setUpAll(() {
    // Provide a minimal GetX environment so Get.back() / Get.toNamed() don't
    // throw during tests.
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  // ---------------------------------------------------------------------------
  // 19.12 Unit tests for ProductViewModel state management
  //
  // Note: ProductViewModel.onInit() calls fetchProducts() asynchronously.
  // To avoid relying on onInit timing, we build the VM and then explicitly
  // call fetchProducts() (or other methods) and await them directly.
  // ---------------------------------------------------------------------------

  group('ProductViewModel — state management', () {
    group('fetchProducts', () {
      test('sets isLoading to false after successful fetch', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult = Success([_buildEntity('1')]);

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.isLoading.value, isFalse);
      });

      test('populates products list on success', () async {
        final repo = _MockProductRepository();
        final entities = [_buildEntity('1'), _buildEntity('2')];
        repo.getProductsResult = Success(entities);

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.products, hasLength(2));
        expect(vm.products[0].id, equals('1'));
        expect(vm.products[1].id, equals('2'));
      });

      test('sets errorMessage on failure', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult =
            Failure<List<ProductEntity>>(AppError.serverError('API error'));

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.errorMessage.value, equals('API error'));
        expect(vm.isLoading.value, isFalse);
      });

      test('products list remains empty on failure', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult =
            Failure<List<ProductEntity>>(AppError.serverError('error'));

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.products, isEmpty);
      });

      test('clears errorMessage before fetching', () async {
        final repo = _MockProductRepository();
        // First call fails.
        repo.getProductsResult =
            Failure<List<ProductEntity>>(AppError.serverError('error'));
        final vm = _buildViewModel(repo);
        await vm.fetchProducts();
        expect(vm.errorMessage.value, isNotEmpty);

        // Second call succeeds.
        repo.getProductsResult = Success([_buildEntity('1')]);
        await vm.fetchProducts();

        expect(vm.errorMessage.value, isEmpty);
      });
    });

    group('fetchNextPage — pagination guard', () {
      test('does not fetch when currentPage >= lastPage', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult = Success([_buildEntity('1')]);

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        // currentPage == lastPage == 1 by default.
        expect(vm.currentPage.value, equals(1));
        expect(vm.lastPage.value, equals(1));

        // Change the result so we can detect if a new fetch happens.
        repo.getProductsResult = Success([_buildEntity('extra')]);

        final productsBefore = List<ProductEntity>.from(vm.products);
        await vm.fetchNextPage();

        // Since currentPage (1) >= lastPage (1), no new fetch should happen.
        expect(vm.products.length, equals(productsBefore.length));
      });

      test('fetches next page when currentPage < lastPage', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult = Success([_buildEntity('1')]);

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        // Manually set lastPage > currentPage to simulate multi-page response.
        vm.lastPage.value = 3;
        vm.currentPage.value = 1;

        // Next page returns additional products.
        repo.getProductsResult = Success([_buildEntity('2')]);
        await vm.fetchNextPage();

        expect(vm.products, hasLength(2));
        expect(vm.currentPage.value, equals(2));
      });
    });

    group('errorMessage', () {
      test('errorMessage is empty after successful fetch', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult = Success([]);

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.errorMessage.value, isEmpty);
      });

      test('errorMessage is set when fetch fails', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult = Failure<List<ProductEntity>>(
          AppError.network('Network error'),
        );

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.errorMessage.value, equals('Network error'));
      });
    });

    group('isLoading', () {
      test('isLoading is false after successful fetch completes', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult = Success([]);

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.isLoading.value, isFalse);
      });

      test('isLoading is false after failed fetch completes', () async {
        final repo = _MockProductRepository();
        repo.getProductsResult = Failure<List<ProductEntity>>(
          AppError.serverError('error'),
        );

        final vm = _buildViewModel(repo);
        await vm.fetchProducts();

        expect(vm.isLoading.value, isFalse);
      });
    });
  });
}
