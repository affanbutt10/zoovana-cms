import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/dio_factory.dart';
import '../services/connectivity_service.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

// Auth data layer
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Auth domain use cases
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';

// Shop data layer
import '../../features/shop/data/datasources/shop_remote_datasource.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_init_usecase.dart';

// Dashboard data layer
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_overview.dart';

// Supplier data layer
import '../../features/suppliers/data/datasources/supplier_remote_datasource.dart';
import '../../features/suppliers/data/repositories/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repositories/supplier_repository.dart';
import '../../features/suppliers/domain/usecases/get_suppliers.dart';
import '../../features/suppliers/domain/usecases/create_supplier.dart';

// Category data layer
import '../../features/categories/data/datasources/category_remote_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/get_categories.dart';
import '../../features/categories/domain/usecases/create_category.dart';

// Product management data layer
import '../../features/products_management/data/datasources/product_remote_datasource.dart';
import '../../features/products_management/data/repositories/product_repository_impl.dart';
import '../../features/products_management/domain/repositories/product_repository.dart';
import '../../features/products_management/domain/usecases/get_products.dart';
import '../../features/products_management/domain/usecases/create_product.dart';

// Auth presentation controllers
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/role_controller.dart';

// Shop presentation controller
import '../../features/shop/presentation/controllers/shop_init_controller.dart';

// Dashboard presentation controller
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';

// Supplier presentation controller
import '../../features/suppliers/presentation/controllers/supplier_controller.dart';

// Category presentation controller
import '../../features/categories/presentation/controllers/category_controller.dart';

// Product management presentation controller
import '../../features/products_management/presentation/controllers/product_management_controller.dart';

/// Global [GetIt] service locator instance.
final getIt = GetIt.instance;

/// Demo mode — set to [true] only for client presentations where you want
/// to skip authentication and navigate freely. Always [false] in production.
const bool demoMode = false;

/// Registers all app-wide services before the first screen renders.
class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    // ── 1. Storage services ──────────────────────────────────────────────────
    getIt.registerSingleton<SecureStorageService>(SecureStorageServiceImpl());
    getIt.registerSingleton<LocalStorageService>(LocalStorageServiceImpl());
    Get.put<SecureStorageService>(getIt<SecureStorageService>(), permanent: true);
    Get.put<LocalStorageService>(getIt<LocalStorageService>(), permanent: true);
    debugPrint('DI STEP 1: Storage registered');

    // ── 2. ApiClient — must be ready before any datasource is created ────────
    final apiClient = await ApiClient().init();
    getIt.registerSingleton<ApiClient>(apiClient);
    Get.put<ApiClient>(apiClient, permanent: true);
    debugPrint('DI STEP 2: ApiClient initialized');

    // ── 3. ConnectivityService ───────────────────────────────────────────────
    final connectivityService = await ConnectivityService().init();
    getIt.registerSingleton<ConnectivityService>(connectivityService);
    Get.put<ConnectivityService>(connectivityService, permanent: true);
    debugPrint('DI STEP 3: ConnectivityService initialized');

    // ── 4. Dio instances (auth + shop) ───────────────────────────────────────
    // The onForceSignOut callback is a closure — Get.find<AuthController>() is
    // only called when a 401 is actually received, not during construction, so
    // it is safe to reference AuthController here before it is registered.
    getIt.registerSingleton<Dio>(
      DioFactory.createAuthDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'authDio',
    );

    getIt.registerSingleton<Dio>(
      DioFactory.createShopDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'shopDio',
    );

    getIt.registerSingleton<Dio>(
      DioFactory.createCmsDio(
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
        onForceSignOut: () => Get.find<AuthController>().forceSignOut(),
      ),
      instanceName: 'cmsDio',
    );
    debugPrint('DI STEP 4: Dio registered');

    // ── 5. Remote data sources ───────────────────────────────────────────────
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<Dio>(instanceName: 'authDio')),
    );

    getIt.registerLazySingleton<ShopRemoteDataSource>(
      () => ShopRemoteDataSourceImpl(getIt<Dio>(instanceName: 'shopDio')),
    );

    getIt.registerLazySingleton<DashboardRemoteDatasource>(
      () => DashboardRemoteDatasourceImpl(
        shopDio: getIt<Dio>(instanceName: 'cmsDio'),
      ),
    );

    getIt.registerLazySingleton<SupplierRemoteDataSource>(
      () => SupplierRemoteDataSourceImpl(
        shopDio: getIt<Dio>(instanceName: 'cmsDio'),
      ),
    );

    getIt.registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(
        shopDio: getIt<Dio>(instanceName: 'cmsDio'),
      ),
    );

    getIt.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(
        shopDio: getIt<Dio>(instanceName: 'cmsDio'),
      ),
    );
    debugPrint('DI STEP 5: Data sources registered');

    // ── 6. Repositories ──────────────────────────────────────────────────────
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorageService>(),
      ),
    );

    getIt.registerLazySingleton<ShopRepository>(
      () => ShopRepositoryImpl(
        remoteDataSource: getIt<ShopRemoteDataSource>(),
        localStorage: getIt<LocalStorageService>(),
      ),
    );

    getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDatasource: getIt<DashboardRemoteDatasource>(),
      ),
    );

    getIt.registerLazySingleton<SupplierRepository>(
      () => SupplierRepositoryImpl(
        remoteDataSource: getIt<SupplierRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        remoteDataSource: getIt<CategoryRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        remoteDataSource: getIt<ProductRemoteDataSource>(),
      ),
    );
    debugPrint('DI STEP 6: Repositories registered');

    // ── 7. Use cases ─────────────────────────────────────────────────────────
    getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => VerifyEmailUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => ForgotPasswordUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => RefreshTokenUseCase(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => ShopInitUseCase(getIt<ShopRepository>()));
    getIt.registerLazySingleton(() => GetDashboardOverview(repository: getIt<DashboardRepository>()));
    getIt.registerLazySingleton(() => GetSuppliers(repository: getIt<SupplierRepository>()));
    getIt.registerLazySingleton(() => CreateSupplier(repository: getIt<SupplierRepository>()));
    getIt.registerLazySingleton(() => GetCategories(repository: getIt<CategoryRepository>()));
    getIt.registerLazySingleton(() => CreateCategory(repository: getIt<CategoryRepository>()));
    getIt.registerLazySingleton(() => GetProducts(repository: getIt<ProductRepository>()));
    getIt.registerLazySingleton(() => CreateProduct(repository: getIt<ProductRepository>()));
    debugPrint('DI STEP 7: Use cases registered');

    // ── 8. GetX controllers ──────────────────────────────────────────────────
    // AuthController must be registered first — Dio callbacks reference it.
    final authController = AuthController(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      secureStorage: getIt<SecureStorageService>(),
    );
    Get.put<AuthController>(authController, permanent: true);

    Get.put<RoleController>(
      RoleController(localStorage: getIt<LocalStorageService>()),
      permanent: true,
    );

    Get.put<ShopInitController>(
      ShopInitController(
        shopInitUseCase: getIt<ShopInitUseCase>(),
        localStorage: getIt<LocalStorageService>(),
      ),
      permanent: true,
    );

    Get.put<DashboardController>(
      DashboardController(
        getDashboardOverview: getIt<GetDashboardOverview>(),
      ),
      permanent: true,
    );

    Get.put<SupplierController>(
      SupplierController(
        getSuppliers: getIt<GetSuppliers>(),
        createSupplier: getIt<CreateSupplier>(),
      ),
      permanent: true,
    );

    Get.put<CategoryController>(
      CategoryController(
        getCategories: getIt<GetCategories>(),
        createCategory: getIt<CreateCategory>(),
      ),
      permanent: true,
    );

    Get.put<ProductManagementController>(
      ProductManagementController(
        getProducts: getIt<GetProducts>(),
        createProduct: getIt<CreateProduct>(),
      ),
      permanent: true,
    );
    debugPrint('DI STEP 8: Controllers registered');

    // ── 9. Background startup tasks ──────────────────────────────────────────
    // These run in the background while the splash screen is shown.
    // Errors are caught so they cannot silently kill startup.
    authController.restoreSessionOnInit().catchError((e, st) {
      debugPrint('restoreSessionOnInit failed: $e');
      debugPrint('$st');
    });

    Get.find<RoleController>().fetchAllRoles().catchError((e, st) {
      debugPrint('fetchAllRoles failed: $e');
      debugPrint('$st');
    });
    debugPrint('DI STEP 9: Background startup tasks started');
  }
}
