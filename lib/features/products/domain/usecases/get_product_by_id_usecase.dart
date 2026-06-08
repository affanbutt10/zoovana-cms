import '../../../../core/error/result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Retrieves a single product by its identifier.
///
/// Called by [ProductViewModel.fetchProductById].
class GetProductByIdUseCase {
  const GetProductByIdUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  ///
  /// [id] is the unique identifier of the product to fetch.
  /// Returns [Result<ProductEntity>].
  Future<Result<ProductEntity>> call(String id) {
    return _repository.getProductById(id);
  }
}
