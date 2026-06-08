import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<ProductListResponse>> getProducts({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getProducts(
        branchId: branchId,
        page: page,
        pageSize: pageSize,
      );
      return Success(response);
    } on AppError catch (e) {
      debugPrint('[PRODUCTS_REPO][ERROR] ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PRODUCTS_REPO][ERROR] Unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ProductEntity>> createProduct({
    required String branchId,
    required CreateProductRequest request,
  }) async {
    try {
      final model = await _remoteDataSource.createProduct(
        branchId: branchId,
        request: request,
      );
      return Success(model.toEntity());
    } on AppError catch (e) {
      debugPrint('[PRODUCTS_REPO][ERROR] Create: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PRODUCTS_REPO][ERROR] Create unexpected: $e');
      return Failure(AppError.serverError());
    }
  }
}
