import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/branch_model.dart';

/// Abstract contract for the branches remote data source.
abstract class BranchRemoteDataSource {
  /// Returns a paginated list of branches.
  Future<BranchPageResult> getBranches({int page = 1, int pageSize = 20});

  /// Creates a new branch and returns the created model.
  Future<BranchModel> createBranch(Map<String, dynamic> payload);
}

/// Concrete implementation using a [Dio] instance pointed at the Shop Service.
class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  const BranchRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const _path = '/api/v1/branches';

  @override
  Future<BranchPageResult> getBranches({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final body = response.data as Map<String, dynamic>;
      final List<dynamic> items = (body['data'] as List?) ?? [];
      final meta = BranchPageMeta.fromJson(
          (body['meta'] as Map<String, dynamic>?) ?? {});

      return BranchPageResult(
        branches: items
            .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: meta,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('No internet connection.');
      }
      final msg = (e.response?.data as Map?)?['message']?.toString() ??
          e.message ??
          'Failed to load branches';
      throw ServerException(
          message: msg, statusCode: e.response?.statusCode ?? 500);
    }
  }

  @override
  Future<BranchModel> createBranch(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post<dynamic>(_path, data: payload);
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      return BranchModel.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('No internet connection.');
      }
      final msg = (e.response?.data as Map?)?['message']?.toString() ??
          e.message ??
          'Failed to create branch';
      throw ServerException(
          message: msg, statusCode: e.response?.statusCode ?? 500);
    }
  }
}
