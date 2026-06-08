import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../data/models/category_model.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/get_categories.dart';

enum CategoryStatus {
  idle,
  loading,
  success,
  error,
}

enum CategoryCreateStatus {
  idle,
  creating,
  success,
  error,
}

/// Controller for managing category list and operations.
///
/// Handles fetching categories, pagination, and creating new categories
/// with optional image upload.
class CategoryController extends GetxController {
  final GetCategories _getCategories;
  final CreateCategory _createCategory;

  CategoryController({
    required GetCategories getCategories,
    required CreateCategory createCategory,
  })  : _getCategories = getCategories,
        _createCategory = createCategory;

  // State
  final Rx<CategoryStatus> status = CategoryStatus.idle.obs;
  final RxList<CategoryEntity> categories = <CategoryEntity>[].obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalCategories = 0.obs;
  final RxInt pageSize = 10.obs;
  final RxBool hasMore = true.obs;

  // Create category state
  final Rx<CategoryCreateStatus> createStatus = CategoryCreateStatus.idle.obs;
  final RxString createErrorMessage = ''.obs;

  /// Loads categories for a specific branch.
  ///
  /// [branchId] - The ID of the branch to load categories for
  /// [page] - Page number to load (default: 1)
  /// [append] - Whether to append to existing list or replace (default: false)
  Future<void> loadCategories({
    required String branchId,
    int page = 1,
    bool append = false,
  }) async {
    if (!append) {
      status.value = CategoryStatus.loading;
      categories.clear();
    }

    errorMessage.value = '';
    debugPrint('[CATEGORY_CTRL] Loading categories for branch: $branchId, page: $page');

    final result = await _getCategories(
      branchId: branchId,
      page: page,
      pageSize: pageSize.value,
    );

    switch (result) {
      case Success(:final data):
        debugPrint('[CATEGORY_CTRL] Success: Loaded ${data.categories.length} categories');
        
        final entities = data.categories.map((m) => m.toEntity()).toList();
        
        if (append) {
          categories.addAll(entities);
        } else {
          categories.assignAll(entities);
        }

        currentPage.value = page;
        totalCategories.value = data.total;
        hasMore.value = categories.length < data.total;
        status.value = CategoryStatus.success;

      case Failure(:final error):
        debugPrint('[CATEGORY_CTRL][ERROR] ${error.message}');
        errorMessage.value = error.message;
        status.value = CategoryStatus.error;
    }
  }

  /// Loads the next page of categories.
  Future<void> loadMore(String branchId) async {
    if (!hasMore.value || status.value == CategoryStatus.loading) {
      return;
    }

    await loadCategories(
      branchId: branchId,
      page: currentPage.value + 1,
      append: true,
    );
  }

  /// Refreshes the category list (loads first page).
  Future<void> refreshData(String branchId) async {
    await loadCategories(branchId: branchId, page: 1, append: false);
  }

  /// Creates a new category.
  ///
  /// [branchId] - The ID of the branch to create the category for
  /// [request] - The category data to create (includes optional image)
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> createNewCategory({
    required String branchId,
    required CreateCategoryRequest request,
  }) async {
    createStatus.value = CategoryCreateStatus.creating;
    createErrorMessage.value = '';
    debugPrint('[CATEGORY_CTRL] Creating category: ${request.name}');

    final result = await _createCategory(
      branchId: branchId,
      request: request,
    );

    switch (result) {
      case Success(:final data):
        debugPrint('[CATEGORY_CTRL] Category created: ${data.id}');
        createStatus.value = CategoryCreateStatus.success;
        
        // Add the new category to the beginning of the list
        categories.insert(0, data);
        totalCategories.value++;
        
        return true;

      case Failure(:final error):
        debugPrint('[CATEGORY_CTRL][ERROR] Create failed: ${error.message}');
        createErrorMessage.value = error.message;
        createStatus.value = CategoryCreateStatus.error;
        return false;
    }
  }

  /// Resets the create status.
  void resetCreateStatus() {
    createStatus.value = CategoryCreateStatus.idle;
    createErrorMessage.value = '';
  }
}
