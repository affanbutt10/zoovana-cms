import '../../../../core/error/result.dart';
import '../../data/models/supplier_model.dart';
import '../entities/supplier_entity.dart';

/// Repository interface for supplier operations.
///
/// Defines the contract for supplier data operations. Implementations
/// handle the actual data fetching and error handling.
abstract class SupplierRepository {
  /// Fetches a paginated list of suppliers for a specific branch.
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [SupplierListResponse] on success
  /// - [Failure] with [AppError] on error
  Future<Result<SupplierListResponse>> getSuppliers({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  });

  /// Creates a new supplier for a specific branch.
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [SupplierEntity] on success
  /// - [Failure] with [AppError] on error
  Future<Result<SupplierEntity>> createSupplier({
    required String branchId,
    required CreateSupplierRequest request,
  });
}
