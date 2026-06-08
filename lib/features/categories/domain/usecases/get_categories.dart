import '../../../../core/error/result.dart';
import '../../data/models/category_model.dart';
import '../repositories/category_repository.dart';

/// Use case for fetching a paginated list of categories.
///
/// Encapsulates the business logic for retrieving categories for a specific
/// branch with pagination support.
class GetCategories {
  final CategoryRepository _repository;

  GetCategories({required CategoryRepository repository})
      : _repository = repository;

  /// Executes the use case to fetch categories.
  ///
  /// [branchId] - The ID of the branch to fetch categories for
  /// [page] - Page number (default: 1)
  /// [pageSize] - Number of items per page (default: 10)
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [CategoryListResponse] on success
  /// - [Failure] with [AppError] on error
  Future<Result<CategoryListResponse>> call({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) {
    return _repository.getCategories(
      branchId: branchId,
      page: page,
      pageSize: pageSize,
    );
  }
}
