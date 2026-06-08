import '../../../../core/error/result.dart';
import '../../data/models/supplier_model.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

/// Use case for creating a new supplier.
///
/// Encapsulates the business logic for creating a supplier for a specific
/// branch.
class CreateSupplier {
  final SupplierRepository _repository;

  CreateSupplier({required SupplierRepository repository})
      : _repository = repository;

  /// Executes the use case to create a supplier.
  ///
  /// [branchId] - The ID of the branch to create the supplier for
  /// [request] - The supplier data to create
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [SupplierEntity] on success
  /// - [Failure] with [AppError] on error
  Future<Result<SupplierEntity>> call({
    required String branchId,
    required CreateSupplierRequest request,
  }) {
    return _repository.createSupplier(
      branchId: branchId,
      request: request,
    );
  }
}
