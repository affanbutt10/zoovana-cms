import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/entities/business_with_branches_entity.dart';
import '../../domain/usecases/shop_init_usecase.dart';

/// Represents the lifecycle state of the shop initialisation flow.
enum ShopInitStatus {
  /// No initialisation has been attempted yet.
  idle,

  /// Initialisation is in progress (network calls are pending).
  loading,

  /// Initialisation completed successfully; [ShopInitController.business]
  /// and [ShopInitController.branches] are populated.
  ready,

  /// Initialisation failed; [ShopInitController.error] contains the reason.
  error,
}

/// GetX controller that drives the shop initialisation flow.
///
/// Calls [ShopInitUseCase] to fetch the authenticated owner's business and
/// branches, then persists the first branch's ID to [LocalStorageService]
/// under the key `active_branch_id`.
///
/// Usage:
/// ```dart
/// final controller = Get.find<ShopInitController>();
/// await controller.initialize();
/// if (controller.status.value == ShopInitStatus.ready) {
///   // use controller.business.value and controller.branches
/// }
/// ```
class ShopInitController extends GetxController {
  ShopInitController({
    required ShopInitUseCase shopInitUseCase,
    required LocalStorageService localStorage,
  }) : _shopInitUseCase = shopInitUseCase,
       _localStorage = localStorage;

  final ShopInitUseCase _shopInitUseCase;
  final LocalStorageService _localStorage;

  // ---------------------------------------------------------------------------
  // Reactive state
  // ---------------------------------------------------------------------------

  /// Current lifecycle status of the shop initialisation.
  final Rx<ShopInitStatus> status = ShopInitStatus.idle.obs;

  /// The authenticated owner's business with embedded branches.
  /// `null` until [initialize] completes successfully.
  final Rxn<BusinessWithBranchesEntity> business = Rxn();

  /// Flat list of branches returned by the use case.
  /// Empty until [initialize] completes successfully.
  final RxList<BranchEntity> branches = <BranchEntity>[].obs;

  /// The ID of the currently active branch.
  /// Set to the first branch's ID on successful initialisation.
  final RxString activeBranchId = ''.obs;

  /// The error that caused the last failed initialisation attempt.
  /// `null` unless [status] is [ShopInitStatus.error].
  final Rxn<AppError> error = Rxn();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches the business and branches, then persists the active branch ID.
  ///
  /// Sets [status] to [ShopInitStatus.loading] immediately, then transitions
  /// to [ShopInitStatus.ready] on success or [ShopInitStatus.error] on
  /// failure.
  Future<void> initialize() async {
    status.value = ShopInitStatus.loading;
    error.value = null;
    debugPrint('[INIT] ShopInitController.initialize → start');

    final result = await _shopInitUseCase();

    switch (result) {
      case Success(:final data):
        final (businessEntity, branchList) = data;
        debugPrint('[INIT] ShopInitController → success '
            'business=${businessEntity.id} branches=${branchList.length}');

        // Persist the first branch ID as the active branch (if any).
        if (branchList.isNotEmpty) {
          await _localStorage.setString(
            LocalStorageKeys.activeBranchId,
            branchList.first.id,
          );
          activeBranchId.value = branchList.first.id;
        } else {
          debugPrint('[INIT] ShopInitController → no branches found (empty state)');
        }

        business.value = businessEntity;
        branches.assignAll(branchList);
        status.value = ShopInitStatus.ready;

      case Failure(:final error):
        debugPrint('[INIT][ERROR] ShopInitController → failure: ${error.message}');
        this.error.value = error;
        status.value = ShopInitStatus.error;
    }
  }

  /// Marks the controller as ready using a previously stored branch ID.
  ///
  /// Called during session restoration on app restart to avoid re-running
  /// the full shop init flow when the user already completed it.
  void markReadyFromStorage(String storedBranchId) {
    debugPrint('[INIT] ShopInitController.markReadyFromStorage → '
        'branchId=$storedBranchId');
    activeBranchId.value = storedBranchId;
    status.value = ShopInitStatus.ready;
  }

  /// Resets all reactive fields back to their initial values.
  ///
  /// Useful when the user navigates away and the controller should be
  /// re-initialised on the next visit.
  void reset() {
    status.value = ShopInitStatus.idle;
    business.value = null;
    branches.clear();
    activeBranchId.value = '';
    error.value = null;
  }
}
