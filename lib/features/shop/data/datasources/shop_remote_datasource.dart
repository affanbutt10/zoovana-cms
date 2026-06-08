import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/branch_model.dart';
import '../models/business_with_branches_model.dart';

/// Abstract contract for the shop remote data source.
///
/// All methods throw an [AppError] (wrapped in a [DioException]) on failure.
/// The repository layer catches these and wraps them in [Result].
abstract class ShopRemoteDataSource {
  /// Retrieves the authenticated owner's business together with its branches.
  Future<BusinessWithBranchesModel> getBusinessWithBranches();

  /// Retrieves the list of branches for the authenticated owner's business.
  Future<List<BranchModel>> getBranches();
}

/// Concrete implementation that communicates with the Zoovana Shop Service
/// via a [Dio] instance.
///
/// Each method catches [DioException], extracts the [AppError] that was
/// attached by [ErrorInterceptor], and rethrows it so the repository layer
/// can wrap it in a typed [Result].
class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  const ShopRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts the [AppError] from a [DioException] and rethrows it.
  ///
  /// [ErrorInterceptor] stores the mapped [AppError] in [DioException.error].
  /// If the error field is not an [AppError] (e.g. an unexpected exception),
  /// a generic server error is rethrown instead.
  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  // ---------------------------------------------------------------------------
  // Interface implementation
  // ---------------------------------------------------------------------------

  @override
  Future<BusinessWithBranchesModel> getBusinessWithBranches() async {
    try {
      final response = await _dio.get(ApiEndpoints.businessMeWithBranches);
      final body = response.data as Map<String, dynamic>;
      // Unwrap the `data` envelope: {"success": true, "data": {...}}
      final Map<String, dynamic> payload =
          (body['data'] as Map<String, dynamic>?) ?? body;
      debugPrint('[INIT] getBusinessWithBranches → status=${response.statusCode} '
          'hasAuth=${response.requestOptions.headers.containsKey("Authorization")} '
          'keys=${payload.keys.toList()}');
      return BusinessWithBranchesModel.fromJson(payload);
    } on DioException catch (err) {
      debugPrint('[INIT][ERROR] getBusinessWithBranches DioException: '
          'status=${err.response?.statusCode} type=${err.type}');
      _rethrow(err);
    } catch (e, st) {
      debugPrint('[INIT][ERROR] getBusinessWithBranches parse error: $e');
      debugPrint('[INIT][STACK] $st');
      throw AppError.serverError('Response format mismatch. Check model mapping.');
    }
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await _dio.get(ApiEndpoints.branches);
      final body = response.data;
      debugPrint('[INIT] getBranches → status=${response.statusCode}');
      // Support both wrapped {"data": [...]} and raw list
      List<dynamic> list;
      if (body is List) {
        list = body;
      } else if (body is Map<String, dynamic>) {
        list = (body['data'] as List<dynamic>?) ?? [];
      } else {
        list = [];
      }
      return list
          .map((item) => BranchModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (err) {
      debugPrint('[INIT][ERROR] getBranches DioException: '
          'status=${err.response?.statusCode} type=${err.type}');
      _rethrow(err);
    } catch (e, st) {
      debugPrint('[INIT][ERROR] getBranches parse error: $e');
      debugPrint('[INIT][STACK] $st');
      throw AppError.serverError('Response format mismatch. Check model mapping.');
    }
  }
}
