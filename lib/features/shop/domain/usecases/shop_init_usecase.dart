import 'package:flutter/foundation.dart';

import '../../../../core/error/result.dart';
import '../entities/branch_entity.dart';
import '../entities/business_with_branches_entity.dart';
import '../repositories/shop_repository.dart';

/// Use case that initialises the shop by fetching both the business (with its
/// embedded branches) and the flat list of branches in sequence.
///
/// The two calls are intentionally sequential: [getBusinessWithBranches] must
/// succeed before [getBranches] is attempted.  If either call fails the use
/// case short-circuits and returns the [Failure] immediately.
///
/// On success it returns a record containing both results so the caller
/// receives everything it needs in a single await.
///
/// Usage:
/// ```dart
/// final result = await shopInitUseCase();
/// result.when(
///   success: (data) {
///     final (business, branches) = data;
///     // use business and branches
///   },
///   failure: (error) => print(error.message),
/// );
/// ```
class ShopInitUseCase {
  const ShopInitUseCase(this._repository);

  final ShopRepository _repository;

  /// Fetches business-with-branches (required), then branches (optional).
  ///
  /// The flat branches call is treated as optional — if it fails, the branches
  /// embedded in the business response are used as a fallback. This prevents
  /// an optional API failure from blocking the entire initialization.
  Future<Result<(BusinessWithBranchesEntity, List<BranchEntity>)>>
  call() async {
    debugPrint('[INIT] ShopInitUseCase → starting');

    // Required: business with embedded branches
    final businessResult = await _repository.getBusinessWithBranches();

    if (businessResult.isFailure) {
      debugPrint('[INIT] ShopInitUseCase → getBusinessWithBranches FAILED: '
          '${businessResult.error?.message}');
      return Failure(businessResult.error!);
    }

    final business = businessResult.data!;
    debugPrint('[INIT] ShopInitUseCase → getBusinessWithBranches OK '
        'branches=${business.branches.length}');

    // Optional: flat branches list — fall back to embedded branches on failure
    final branchesResult = await _repository.getBranches();
    final List<BranchEntity> branches;
    if (branchesResult.isSuccess) {
      branches = branchesResult.data!;
      debugPrint('[INIT] ShopInitUseCase → getBranches OK count=${branches.length}');
    } else {
      // Non-fatal: use branches already embedded in the business response
      branches = business.branches;
      debugPrint('[INIT] ShopInitUseCase → getBranches FAILED (non-fatal), '
          'using embedded branches count=${branches.length}');
    }

    debugPrint('[INIT] ShopInitUseCase → complete');
    return Success((business, branches));
  }
}
