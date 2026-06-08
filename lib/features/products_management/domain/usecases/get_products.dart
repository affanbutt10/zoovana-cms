import '../../../../core/error/result.dart';
import '../../data/models/product_model.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository _repository;
  GetProducts({required ProductRepository repository})
      : _repository = repository;

  Future<Result<ProductListResponse>> call({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) =>
      _repository.getProducts(
          branchId: branchId, page: page, pageSize: pageSize);
}
