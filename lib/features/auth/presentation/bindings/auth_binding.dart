import 'package:get/get.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../viewmodels/login_viewmodel.dart';

/// Registers all auth feature dependencies via lazy injection.
///
/// Invoked automatically by GetX when the login route is first accessed.
/// All registrations use [Get.lazyPut] so instances are only created on
/// first use (Requirement 11.9).
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Data source
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(Get.find()),
    );

    // Repository — registered against the abstract interface so the domain
    // layer never depends on the concrete implementation.
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        secureStorage: Get.find<SecureStorageService>(),
        localStorage: Get.find(),
      ),
    );

    // Use cases
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<LogoutUseCase>(() => LogoutUseCase(Get.find<AuthRepository>()));

    // ViewModel
    Get.lazyPut<LoginViewModel>(
      () => LoginViewModel(
        loginUseCase: Get.find<LoginUseCase>(),
        secureStorage: Get.find<SecureStorageService>(),
      ),
    );
  }
}
