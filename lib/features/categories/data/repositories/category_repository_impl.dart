import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl({required CategoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<CategoryListResponse>> getCategories({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getCategories(
        branchId: branchId,
        page: page,
        pageSize: pageSize,
      );
      return Success(response);
    } on AppError catch (e) {
      debugPrint('[CATEGORIES_REPO][ERROR] ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[CATEGORIES_REPO][ERROR] Unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<CategoryEntity>> createCategory({
    required String branchId,
    required CreateCategoryRequest request,
  }) async {
    try {
      final model = await _remoteDataSource.createCategory(
        branchId: branchId,
        request: request,
      );
      return Success(model.toEntity());
    } on AppError catch (e) {
      debugPrint('[CATEGORIES_REPO][ERROR] Create: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[CATEGORIES_REPO][ERROR] Create unexpected: $e');
      return Failure(AppError.serverError());
    }
  }
}
