import '../../../../core/error/result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Creates a new product in the system.
///
/// Called by [ProductViewModel.createProduct].
class CreateProductUseCase {
  const CreateProductUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  ///
  /// [product] is the entity containing the data for the new product.
  /// Returns [Result<ProductEntity>] with the persisted entity on success.
  Future<Result<ProductEntity>> call(ProductEntity product) {
    return _repository.createProduct(product);
  }
}
