import '../../../../core/error/result.dart';
import '../../data/models/product_model.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository _repository;
  CreateProduct({required ProductRepository repository})
      : _repository = repository;

  Future<Result<ProductEntity>> call({
    required String branchId,
    required CreateProductRequest request,
  }) =>
      _repository.createProduct(branchId: branchId, request: request);
}
