import '../../../../core/error/result.dart';
import '../../data/models/category_model.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// Use case for creating a new category.
///
/// Encapsulates the business logic for creating a category for a specific
/// branch, including optional image upload.
class CreateCategory {
  final CategoryRepository _repository;

  CreateCategory({required CategoryRepository repository})
      : _repository = repository;

  /// Executes the use case to create a category.
  ///
  /// [branchId] - The ID of the branch to create the category for
  /// [request] - The category data to create (includes optional image)
  ///
  /// Returns [Result] containing either:
  /// - [Success] with [CategoryEntity] on success
  /// - [Failure] with [AppError] on error
  Future<Result<CategoryEntity>> call({
    required String branchId,
    required CreateCategoryRequest request,
  }) {
    return _repository.createCategory(
      branchId: branchId,
      request: request,
    );
  }
}
