import 'package:get/get.dart';

import '../viewmodels/dashboard_viewmodel.dart';

/// Registers all dashboard feature dependencies via lazy injection.
///
/// Invoked automatically by GetX when the dashboard route is navigated to.
/// Uses [Get.lazyPut] so the [DashboardViewModel] is only instantiated on
/// first access.
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardViewModel>(() => DashboardViewModel());
  }
}
