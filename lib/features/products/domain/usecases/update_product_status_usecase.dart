import '../../../../core/error/result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Updates the status of a product.
///
/// Called by [ProductViewModel.updateStatus].
class UpdateProductStatusUseCase {
  const UpdateProductStatusUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  ///
  /// [id] is the unique identifier of the product.
  /// [status] is the new [ProductStatus] to apply.
  /// Returns [Result<ProductEntity>] with the updated entity on success.
  Future<Result<ProductEntity>> call(String id, ProductStatus status) {
    return _repository.updateProductStatus(id, status);
  }
}
