import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Monitors network connectivity state reactively.
///
/// Extends [GetxService] so it is kept alive for the lifetime of the app.
/// Register via [Get.put] in [DependencyInjection.init].
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Observable connectivity flag.
  /// `true` when at least one non-[ConnectivityResult.none] result is present.
  final RxBool isConnected = true.obs;

  /// Initialises the service, reads the current state, and subscribes to
  /// future changes.
  Future<ConnectivityService> init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);

    return this;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    isConnected.value =
        results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
