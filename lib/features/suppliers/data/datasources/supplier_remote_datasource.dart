import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/supplier_model.dart';

abstract class SupplierRemoteDataSource {
  Future<SupplierListResponse> getSuppliers({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  });

  Future<SupplierModel> createSupplier({
    required String branchId,
    required CreateSupplierRequest request,
  });
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  // Uses the shop Dio instance (base: AppConfig.shopBaseUrl) which already
  // has AuthInterceptor and ErrorInterceptor attached.
  final Dio _dio;

  SupplierRemoteDataSourceImpl({required Dio shopDio}) : _dio = shopDio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<SupplierListResponse> getSuppliers({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint('[SUPPLIERS] GET branch=$branchId page=$page');
      final response = await _dio.get<dynamic>(
        '/api/shop/api/v1/$branchId/suppliers',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      debugPrint('[SUPPLIERS] ${response.statusCode}');
      return SupplierListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<SupplierModel> createSupplier({
    required String branchId,
    required CreateSupplierRequest request,
  }) async {
    try {
      debugPrint('[SUPPLIERS] POST branch=$branchId name=${request.name}');
      final response = await _dio.post<dynamic>(
        '/api/shop/api/v1/$branchId/suppliers',
        data: request.toJson(),
      );
      debugPrint('[SUPPLIERS] Created ${response.statusCode}');
      return SupplierModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }
}
