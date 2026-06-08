import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/dashboard_overview_entity.dart';
import '../../domain/usecases/get_dashboard_overview.dart';

enum DashboardStatus {
  idle,
  loading,
  success,
  error,
}

class DashboardController extends GetxController {
  final GetDashboardOverview _getDashboardOverview;

  DashboardController({
    required GetDashboardOverview getDashboardOverview,
  }) : _getDashboardOverview = getDashboardOverview;

  // State
  final Rx<DashboardStatus> status = DashboardStatus.idle.obs;
  final Rxn<DashboardOverviewEntity> overview = Rxn<DashboardOverviewEntity>();
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    status.value = DashboardStatus.loading;
    errorMessage.value = '';
    debugPrint('[DASHBOARD] Loading dashboard overview...');

    final result = await _getDashboardOverview();

    switch (result) {
      case Success(:final data):
        debugPrint('[DASHBOARD] Success: Revenue=${data.totalRevenue}, Orders=${data.totalOrders}');
        overview.value = data;
        status.value = DashboardStatus.success;

      case Failure(:final error):
        debugPrint('[DASHBOARD][ERROR] ${error.message}');
        errorMessage.value = error.message;
        status.value = DashboardStatus.error;
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
