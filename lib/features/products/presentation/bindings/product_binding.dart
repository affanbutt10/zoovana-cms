import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_status_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/upload_product_image_usecase.dart';
import '../viewmodels/product_viewmodel.dart';

/// Registers all product feature dependencies via lazy injection.
///
/// Invoked automatically by GetX when any product route is navigated to.
/// All registrations use [Get.lazyPut] so instances are only created on
/// first access (Requirement 18).
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    // Data source
    if (!Get.isRegistered<ProductRemoteDataSource>()) {
      Get.lazyPut<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(Get.find<ApiClient>()),
      );
    }

    // Repository
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepositoryImpl(Get.find<ProductRemoteDataSource>()),
      );
    }

    // Use cases
    if (!Get.isRegistered<GetProductsUseCase>()) {
      Get.lazyPut(() => GetProductsUseCase(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<GetProductByIdUseCase>()) {
      Get.lazyPut(() => GetProductByIdUseCase(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<CreateProductUseCase>()) {
      Get.lazyPut(() => CreateProductUseCase(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<UpdateProductUseCase>()) {
      Get.lazyPut(() => UpdateProductUseCase(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<DeleteProductUseCase>()) {
      Get.lazyPut(() => DeleteProductUseCase(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<UploadProductImageUseCase>()) {
      Get.lazyPut(
        () => UploadProductImageUseCase(Get.find<ProductRepository>()),
      );
    }
    if (!Get.isRegistered<UpdateProductStatusUseCase>()) {
      Get.lazyPut(
        () => UpdateProductStatusUseCase(Get.find<ProductRepository>()),
      );
    }

    // ViewModel
    if (!Get.isRegistered<ProductViewModel>()) {
      Get.lazyPut(
        () => ProductViewModel(
          getProductsUseCase: Get.find<GetProductsUseCase>(),
          getProductByIdUseCase: Get.find<GetProductByIdUseCase>(),
          createProductUseCase: Get.find<CreateProductUseCase>(),
          updateProductUseCase: Get.find<UpdateProductUseCase>(),
          deleteProductUseCase: Get.find<DeleteProductUseCase>(),
          uploadProductImageUseCase: Get.find<UploadProductImageUseCase>(),
          updateProductStatusUseCase: Get.find<UpdateProductStatusUseCase>(),
        ),
      );
    }
  }
}
