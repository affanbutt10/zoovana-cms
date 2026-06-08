import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductListResponse> getProducts({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  });

  Future<ProductModel> createProduct({
    required String branchId,
    required CreateProductRequest request,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  // Uses the shop Dio instance (base: AppConfig.shopBaseUrl) which already
  // has AuthInterceptor and ErrorInterceptor attached.
  final Dio _dio;

  ProductRemoteDataSourceImpl({required Dio shopDio}) : _dio = shopDio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<ProductListResponse> getProducts({
    required String branchId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint('[PRODUCTS] GET branch=$branchId page=$page');
      final response = await _dio.get<dynamic>(
        '/api/shop/api/v1/products/$branchId',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      debugPrint('[PRODUCTS] ${response.statusCode}');
      return ProductListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ProductModel> createProduct({
    required String branchId,
    required CreateProductRequest request,
  }) async {
    try {
      debugPrint('[PRODUCTS] POST branch=$branchId name=${request.name}');

      final formData = FormData();
      formData.fields.add(MapEntry('name', request.name));
      formData.fields.add(MapEntry('category_id', request.categoryId));
      formData.fields.add(MapEntry('price', request.price.toString()));
      formData.fields.add(MapEntry('stock', request.stock.toString()));
      if (request.description != null && request.description!.isNotEmpty) {
        formData.fields.add(MapEntry('description', request.description!));
      }

      // Multiple images
      for (final image in request.images) {
        final fileName = image.path.split('/').last;
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(image.path, filename: fileName),
        ));
      }

      // Variants serialised as JSON string (multipart + nested JSON pattern)
      if (request.variants.isNotEmpty) {
        formData.fields.add(MapEntry(
          'variants',
          jsonEncode(request.variants.map((v) => v.toJson()).toList()),
        ));
      }

      final response = await _dio.post<dynamic>(
        '/api/shop/api/v1/products/$branchId',
        data: formData,
      );
      debugPrint('[PRODUCTS] Created ${response.statusCode}');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }
}
