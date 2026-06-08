import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_status_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/upload_product_image_usecase.dart';

/// ViewModel for the products feature.
///
/// Extends [GetxController] and exposes reactive observables consumed by
/// product views via [GetView]. Delegates all business actions to the
/// corresponding UseCases.
class ProductViewModel extends GetxController {
  ProductViewModel({
    required GetProductsUseCase getProductsUseCase,
    required GetProductByIdUseCase getProductByIdUseCase,
    required CreateProductUseCase createProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
    required UploadProductImageUseCase uploadProductImageUseCase,
    required UpdateProductStatusUseCase updateProductStatusUseCase,
  }) : _getProductsUseCase = getProductsUseCase,
       _getProductByIdUseCase = getProductByIdUseCase,
       _createProductUseCase = createProductUseCase,
       _updateProductUseCase = updateProductUseCase,
       _deleteProductUseCase = deleteProductUseCase,
       _uploadProductImageUseCase = uploadProductImageUseCase,
       _updateProductStatusUseCase = updateProductStatusUseCase;

  final GetProductsUseCase _getProductsUseCase;
  final GetProductByIdUseCase _getProductByIdUseCase;
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final UploadProductImageUseCase _uploadProductImageUseCase;
  final UpdateProductStatusUseCase _updateProductStatusUseCase;

  // ---------------------------------------------------------------------------
  // Observables
  // ---------------------------------------------------------------------------

  /// The current page of products loaded.
  final products = <ProductEntity>[].obs;

  /// Whether a network request is currently in progress.
  final isLoading = false.obs;

  /// Non-empty when the last operation failed.
  final errorMessage = ''.obs;

  /// The current page number (1-based).
  final currentPage = 1.obs;

  /// The last available page number.
  final lastPage = 1.obs;

  /// The product currently being viewed in the detail screen.
  final selectedProduct = Rxn<ProductEntity>();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Fetches the first page of products, resetting pagination state.
  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    currentPage.value = 1;

    final result = await _getProductsUseCase(page: 1);

    result.when(
      success: (list) {
        products.assignAll(list);
        isLoading.value = false;
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Fetches the next page of products and appends them to [products].
  ///
  /// Only executes when [currentPage] < [lastPage].
  Future<void> fetchNextPage() async {
    if (currentPage.value >= lastPage.value) return;
    if (isLoading.value) return;

    isLoading.value = true;
    final nextPage = currentPage.value + 1;

    final result = await _getProductsUseCase(page: nextPage);

    result.when(
      success: (list) {
        products.addAll(list);
        currentPage.value = nextPage;
        isLoading.value = false;
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Fetches a single product by [id] and stores it in [selectedProduct].
  Future<void> fetchProductById(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _getProductByIdUseCase(id);

    result.when(
      success: (product) {
        selectedProduct.value = product;
        isLoading.value = false;
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Creates a new product from [entity].
  ///
  /// On success, adds the new entity to [products] and navigates back.
  Future<void> createProduct(ProductEntity entity) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _createProductUseCase(entity);

    result.when(
      success: (created) {
        products.add(created);
        isLoading.value = false;
        Get.back();
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Updates an existing product with the data in [entity].
  ///
  /// On success, replaces the matching entity in [products] and navigates back.
  Future<void> updateProduct(ProductEntity entity) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _updateProductUseCase(entity);

    result.when(
      success: (updated) {
        final index = products.indexWhere((p) => p.id == updated.id);
        if (index != -1) {
          products[index] = updated;
        }
        selectedProduct.value = updated;
        isLoading.value = false;
        Get.back();
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Deletes the product with the given [id].
  ///
  /// On success, removes the entity from [products].
  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _deleteProductUseCase(id);

    result.when(
      success: (_) {
        products.removeWhere((p) => p.id == id);
        isLoading.value = false;
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Uploads an image at [filePath] for the product with [id].
  ///
  /// On success, updates the [imageUrl] of the matching entity in [products].
  Future<void> uploadImage(String id, String filePath) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _uploadProductImageUseCase(id, filePath);

    result.when(
      success: (imageUrl) {
        final index = products.indexWhere((p) => p.id == id);
        if (index != -1) {
          products[index] = products[index].copyWith(imageUrl: imageUrl);
        }
        if (selectedProduct.value?.id == id) {
          selectedProduct.value = selectedProduct.value?.copyWith(
            imageUrl: imageUrl,
          );
        }
        isLoading.value = false;
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Updates the [status] of the product with [id].
  ///
  /// On success, replaces the matching entity in [products] with the updated one.
  Future<void> updateStatus(String id, ProductStatus status) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _updateProductStatusUseCase(id, status);

    result.when(
      success: (updated) {
        final index = products.indexWhere((p) => p.id == updated.id);
        if (index != -1) {
          products[index] = updated;
        }
        if (selectedProduct.value?.id == id) {
          selectedProduct.value = updated;
        }
        isLoading.value = false;
      },
      failure: (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
    );
  }

  /// Navigates to the product form for creating a new product.
  void goToCreateForm() {
    Get.toNamed(AppRoutes.productForm);
  }

  /// Navigates to the product form pre-populated with [product] for editing.
  void goToEditForm(ProductEntity product) {
    Get.toNamed(AppRoutes.productForm, arguments: product);
  }

  /// Navigates to the product detail screen for the given [product].
  void goToDetail(ProductEntity product) {
    selectedProduct.value = product;
    Get.toNamed(AppRoutes.productDetail, arguments: product.id);
  }
}
