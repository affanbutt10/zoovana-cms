import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource _remoteDataSource;

  SupplierRepositoryImpl({required SupplierRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<SupplierListResponse>> getSuppliers({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getSuppliers(
        branchId: branchId,
        page: page,
        pageSize: pageSize,
      );
      return Success(response);
    } on AppError catch (e) {
      debugPrint('[SUPPLIERS_REPO][ERROR] ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[SUPPLIERS_REPO][ERROR] Unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<SupplierEntity>> createSupplier({
    required String branchId,
    required CreateSupplierRequest request,
  }) async {
    try {
      final model = await _remoteDataSource.createSupplier(
        branchId: branchId,
        request: request,
      );
      return Success(model.toEntity());
    } on AppError catch (e) {
      debugPrint('[SUPPLIERS_REPO][ERROR] Create: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[SUPPLIERS_REPO][ERROR] Create unexpected: $e');
      return Failure(AppError.serverError());
    }
  }
}
