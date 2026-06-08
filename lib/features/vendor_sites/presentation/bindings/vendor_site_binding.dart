import 'package:get/get.dart';

import '../viewmodels/vendor_site_viewmodel.dart';

/// Registers all vendor sites feature dependencies via lazy injection.
///
/// Invoked automatically by GetX when the vendor sites route is navigated to.
/// Uses [Get.lazyPut] so the [VendorSiteViewModel] is only instantiated on
/// first access (Requirement 21.3).
class VendorSiteBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VendorSiteViewModel>()) {
      Get.lazyPut<VendorSiteViewModel>(() => VendorSiteViewModel());
    }
  }
}
