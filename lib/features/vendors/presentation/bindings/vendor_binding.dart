import 'package:get/get.dart';

import '../viewmodels/vendor_viewmodel.dart';

/// Registers all vendor feature dependencies via lazy injection.
///
/// Invoked automatically by GetX when the vendors route is navigated to.
/// Uses [Get.lazyPut] so the [VendorViewModel] is only instantiated on
/// first access (Requirement 20.3, Requirement 18 pattern).
class VendorBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VendorViewModel>()) {
      Get.lazyPut<VendorViewModel>(() => VendorViewModel());
    }
  }
}
