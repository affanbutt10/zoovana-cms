import '../../../../core/error/result.dart';
import '../repositories/product_repository.dart';

/// Deletes a product from the system.
///
/// Called by [ProductViewModel.deleteProduct].
class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  ///
  /// [id] is the unique identifier of the product to delete.
  /// Returns [Result<void>] — success indicates the product was removed.
  Future<Result<void>> call(String id) {
    return _repository.deleteProduct(id);
  }
}
