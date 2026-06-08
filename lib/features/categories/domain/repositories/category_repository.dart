import '../../../../core/error/result.dart';
import '../../data/models/category_model.dart';
import '../entities/category_entity.dart';

/// Repository interface for category operations.
///
/// Defines the contract for category data operations. Implementations
/// handle the actual data fetching and error handling.
abstract class CategoryRepository {
  /// Fetches a paginated list of categories for a specific branch.
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [CategoryListResponse] on success
  /// - [Failure] with [AppError] on error
  Future<Result<CategoryListResponse>> getCategories({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  });

  /// Creates a new category for a specific branch.
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [CategoryEntity] on success
  /// - [Failure] with [AppError] on error
  Future<Result<CategoryEntity>> createCategory({
    required String branchId,
    required CreateCategoryRequest request,
  });
}
