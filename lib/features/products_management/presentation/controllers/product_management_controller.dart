import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/get_products.dart';

enum ProductMgmtStatus { idle, loading, success, error }

enum ProductCreateStatus { idle, creating, success, error }

class ProductManagementController extends GetxController {
  final GetProducts _getProducts;
  final CreateProduct _createProduct;

  ProductManagementController({
    required GetProducts getProducts,
    required CreateProduct createProduct,
  })  : _getProducts = getProducts,
        _createProduct = createProduct;

  // List state
  final Rx<ProductMgmtStatus> status = ProductMgmtStatus.idle.obs;
  final RxList<ProductEntity> products = <ProductEntity>[].obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalProducts = 0.obs;
  final RxBool hasMore = true.obs;
  static const int _pageSize = 10;

  // Create state
  final Rx<ProductCreateStatus> createStatus = ProductCreateStatus.idle.obs;
  final RxString createErrorMessage = ''.obs;

  Future<void> loadProducts({
    required String branchId,
    int page = 1,
    bool append = false,
  }) async {
    if (!append) {
      status.value = ProductMgmtStatus.loading;
      products.clear();
    }
    errorMessage.value = '';
    debugPrint('[PRODUCT_CTRL] Loading page=$page branch=$branchId');

    final result = await _getProducts(
        branchId: branchId, page: page, pageSize: _pageSize);

    switch (result) {
      case Success(:final data):
        final entities = data.products.map((m) => m.toEntity()).toList();
        if (append) {
          products.addAll(entities);
        } else {
          products.assignAll(entities);
        }
        currentPage.value = page;
        totalProducts.value = data.total;
        hasMore.value = products.length < data.total;
        status.value = ProductMgmtStatus.success;

      case Failure(:final error):
        debugPrint('[PRODUCT_CTRL][ERROR] ${error.message}');
        errorMessage.value = error.message;
        status.value = ProductMgmtStatus.error;
    }
  }

  Future<void> loadMore(String branchId) async {
    if (!hasMore.value || status.value == ProductMgmtStatus.loading) return;
    await loadProducts(
        branchId: branchId, page: currentPage.value + 1, append: true);
  }

  Future<void> refreshData(String branchId) async {
    await loadProducts(branchId: branchId, page: 1, append: false);
  }

  Future<bool> createNewProduct({
    required String branchId,
    required CreateProductRequest request,
  }) async {
    createStatus.value = ProductCreateStatus.creating;
    createErrorMessage.value = '';
    debugPrint('[PRODUCT_CTRL] Creating: ${request.name}');

    final result =
        await _createProduct(branchId: branchId, request: request);

    switch (result) {
      case Success(:final data):
        debugPrint('[PRODUCT_CTRL] Created: ${data.id}');
        createStatus.value = ProductCreateStatus.success;
        products.insert(0, data);
        totalProducts.value++;
        return true;

      case Failure(:final error):
        debugPrint('[PRODUCT_CTRL][ERROR] ${error.message}');
        createErrorMessage.value = error.message;
        createStatus.value = ProductCreateStatus.error;
        return false;
    }
  }

  void resetCreateStatus() {
    createStatus.value = ProductCreateStatus.idle;
    createErrorMessage.value = '';
  }
}
