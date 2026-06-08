import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<CategoryListResponse> getCategories({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  });

  Future<CategoryModel> createCategory({
    required String branchId,
    required CreateCategoryRequest request,
  });
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  // Uses the shop Dio instance (base: AppConfig.shopBaseUrl) which already
  // has AuthInterceptor and ErrorInterceptor attached.
  final Dio _dio;

  CategoryRemoteDataSourceImpl({required Dio shopDio}) : _dio = shopDio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<CategoryListResponse> getCategories({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint('[CATEGORIES] GET branch=$branchId page=$page');
      final response = await _dio.get<dynamic>(
        '/api/shop/api/v1/products/categories/$branchId',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      debugPrint('[CATEGORIES] ${response.statusCode}');
      return CategoryListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<CategoryModel> createCategory({
    required String branchId,
    required CreateCategoryRequest request,
  }) async {
    try {
      debugPrint('[CATEGORIES] POST branch=$branchId name=${request.name}');

      final formData = FormData();
      formData.fields.add(MapEntry('name', request.name));
      if (request.description != null && request.description!.isNotEmpty) {
        formData.fields.add(MapEntry('description', request.description!));
      }
      if (request.image != null) {
        final fileName = request.image!.path.split('/').last;
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(request.image!.path, filename: fileName),
        ));
      }

      final response = await _dio.post<dynamic>(
        '/api/shop/api/v1/products/categories/$branchId',
        data: formData,
      );
      debugPrint('[CATEGORIES] Created ${response.statusCode}');
      return CategoryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }
}
