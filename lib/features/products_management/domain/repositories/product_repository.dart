import '../../../../core/error/result.dart';
import '../../data/models/product_model.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<ProductListResponse>> getProducts({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  });

  Future<Result<ProductEntity>> createProduct({
    required String branchId,
    required CreateProductRequest request,
  });
}
