import '../../../../core/error/result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Updates an existing product.
///
/// Called by [ProductViewModel.updateProduct].
class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  ///
  /// [product] must contain the `id` of the product to update along with
  /// all fields (including unchanged ones).
  /// Returns [Result<ProductEntity>] with the updated entity on success.
  Future<Result<ProductEntity>> call(ProductEntity product) {
    return _repository.updateProduct(product);
  }
}
