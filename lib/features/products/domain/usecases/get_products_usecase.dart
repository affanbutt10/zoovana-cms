import '../../../../core/error/result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Retrieves a paginated list of products.
///
/// Called by [ProductViewModel.fetchProducts] and [ProductViewModel.fetchNextPage].
class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  ///
  /// [page] is the 1-based page number to fetch. Defaults to 1.
  /// Returns [Result<List<ProductEntity>>].
  Future<Result<List<ProductEntity>>> call({int page = 1}) {
    return _repository.getProducts(page: page);
  }
}
