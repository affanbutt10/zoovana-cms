import '../../../../core/error/result.dart';
import '../entities/branch_entity.dart';
import '../entities/business_with_branches_entity.dart';

/// Abstract contract for the shop repository.
///
/// Implementations are responsible for fetching shop data from the remote
/// data source and persisting any side-effects (e.g. storing the active
/// branch ID) via [LocalStorageService].
abstract class ShopRepository {
  /// Retrieves the authenticated owner's business together with its branches.
  ///
  /// On success, stores `branches[0].id` as `active_branch_id` in local
  /// storage (when the branches list is non-empty) and returns
  /// [Success<BusinessWithBranchesEntity>].
  /// On failure, returns [Failure<AppError>].
  Future<Result<BusinessWithBranchesEntity>> getBusinessWithBranches();

  /// Retrieves the list of branches for the authenticated owner's business.
  ///
  /// Returns [Success<List<BranchEntity>>] on success or
  /// [Failure<AppError>] on failure.
  Future<Result<List<BranchEntity>>> getBranches();
}
