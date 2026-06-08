import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../data/models/supplier_model.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/usecases/create_supplier.dart';
import '../../domain/usecases/get_suppliers.dart';

enum SupplierStatus { idle, loading, success, error }

enum SupplierCreateStatus { idle, creating, success, error }

/// Controller for managing supplier list and operations.
///
/// Handles fetching suppliers, pagination, and creating new suppliers.
class SupplierController extends GetxController {
  final GetSuppliers _getSuppliers;
  final CreateSupplier _createSupplier;

  SupplierController({
    required GetSuppliers getSuppliers,
    required CreateSupplier createSupplier,
  }) : _getSuppliers = getSuppliers,
       _createSupplier = createSupplier;

  // State
  final Rx<SupplierStatus> status = SupplierStatus.idle.obs;
  final RxList<SupplierEntity> suppliers = <SupplierEntity>[].obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalSuppliers = 0.obs;
  final RxInt pageSize = 10.obs;
  final RxBool hasMore = true.obs;

  // Create supplier state
  final Rx<SupplierCreateStatus> createStatus = SupplierCreateStatus.idle.obs;
  final RxString createErrorMessage = ''.obs;

  /// Loads suppliers for a specific branch.
  ///
  /// [branchId] - The ID of the branch to load suppliers for
  /// [page] - Page number to load (default: 1)
  /// [append] - Whether to append to existing list or replace (default: false)
  Future<void> loadSuppliers({
    required String branchId,
    int page = 1,
    bool append = false,
  }) async {
    if (!append) {
      status.value = SupplierStatus.loading;
      suppliers.clear();
    }

    errorMessage.value = '';
    debugPrint(
      '[SUPPLIER_CTRL] Loading suppliers for branch: $branchId, page: $page',
    );

    final result = await _getSuppliers(
      branchId: branchId,
      page: page,
      pageSize: pageSize.value,
    );

    switch (result) {
      case Success(:final data):
        debugPrint(
          '[SUPPLIER_CTRL] Success: Loaded ${data.suppliers.length} suppliers',
        );

        final entities = data.suppliers.map((m) => m.toEntity()).toList();

        if (append) {
          suppliers.addAll(entities);
        } else {
          suppliers.assignAll(entities);
        }

        currentPage.value = page;
        totalSuppliers.value = data.total;
        hasMore.value = suppliers.length < data.total;
        status.value = SupplierStatus.success;

      case Failure(:final error):
        debugPrint('[SUPPLIER_CTRL][ERROR] ${error.message}');
        errorMessage.value = error.message;
        status.value = SupplierStatus.error;
    }
  }

  /// Loads the next page of suppliers.
  Future<void> loadMore(String branchId) async {
    if (!hasMore.value || status.value == SupplierStatus.loading) {
      return;
    }

    await loadSuppliers(
      branchId: branchId,
      page: currentPage.value + 1,
      append: true,
    );
  }

  /// Refreshes the supplier list (loads first page).
  Future<void> refreshData(String branchId) async {
    await loadSuppliers(branchId: branchId, page: 1, append: false);
  }

  /// Creates a new supplier.
  ///
  /// [branchId] - The ID of the branch to create the supplier for
  /// [request] - The supplier data to create
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> createNewSupplier({
    required String branchId,
    required CreateSupplierRequest request,
  }) async {
    createStatus.value = SupplierCreateStatus.creating;
    createErrorMessage.value = '';
    debugPrint('[SUPPLIER_CTRL] Creating supplier: ${request.name}');

    final result = await _createSupplier(branchId: branchId, request: request);

    switch (result) {
      case Success(:final data):
        debugPrint('[SUPPLIER_CTRL] Supplier created: ${data.id}');
        createStatus.value = SupplierCreateStatus.success;

        // Add the new supplier to the beginning of the list
        suppliers.insert(0, data);
        totalSuppliers.value++;

        return true;

      case Failure(:final error):
        debugPrint('[SUPPLIER_CTRL][ERROR] Create failed: ${error.message}');
        createErrorMessage.value = error.message;
        createStatus.value = SupplierCreateStatus.error;
        return false;
    }
  }

  /// Resets the create status.
  void resetCreateStatus() {
    createStatus.value = SupplierCreateStatus.idle;
    createErrorMessage.value = '';
  }
}
