import '../../../../core/error/result.dart';
import '../../data/models/supplier_model.dart';
import '../repositories/supplier_repository.dart';

/// Use case for fetching a paginated list of suppliers.
///
/// Encapsulates the business logic for retrieving suppliers for a specific
/// branch with pagination support.
class GetSuppliers {
  final SupplierRepository _repository;

  GetSuppliers({required SupplierRepository repository})
      : _repository = repository;

  /// Executes the use case to fetch suppliers.
  ///
  /// [branchId] - The ID of the branch to fetch suppliers for
  /// [page] - Page number (default: 1)
  /// [pageSize] - Number of items per page (default: 10)
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [SupplierListResponse] on success
  /// - [Failure] with [AppError] on error
  Future<Result<SupplierListResponse>> call({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) {
    return _repository.getSuppliers(
      branchId: branchId,
      page: page,
      pageSize: pageSize,
    );
  }
}
