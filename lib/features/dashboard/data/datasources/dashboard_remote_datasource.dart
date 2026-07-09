import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/dashboard_overview_model.dart';

abstract class DashboardRemoteDatasource {
  Future<DashboardOverviewModel> getDashboardOverview();
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  // Uses the Shop gateway client with authentication and error mapping.
  // which already has AuthInterceptor and ErrorInterceptor attached.
  final Dio _dio;

  DashboardRemoteDatasourceImpl({required Dio shopDio}) : _dio = shopDio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<DashboardOverviewModel> getDashboardOverview() async {
    try {
      debugPrint('[DASHBOARD] GET /api/v1/dashboard/overview');
      final response = await _dio.get<dynamic>('/api/v1/dashboard/overview');
      debugPrint('[DASHBOARD] ${response.statusCode}');

      final data = response.data;
      // Handle both { success: true, data: {...} } and flat response shapes
      final body = (data is Map<String, dynamic> && data['data'] != null)
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      return DashboardOverviewModel.fromJson(body);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }
}
