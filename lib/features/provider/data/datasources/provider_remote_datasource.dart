import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/provider_booking_model.dart';
import '../models/provider_profile_model.dart';
import '../models/provider_service_model.dart';
import '../models/provider_overview_model.dart';

abstract class ProviderRemoteDataSource {
  Future<ProviderProfileModel?> getProfile();

  Future<ProviderOverviewModel> getDashboardOverview();

  Future<ProviderProfileModel> apply(ProviderApplicationRequest request);

  Future<List<ProviderServiceModel>> getServices();

  Future<ProviderServiceModel> createService(ProviderServiceRequest request);

  Future<List<ProviderBookingModel>> getBookings();

  Future<ProviderBookingModel> updateBookingStatus({
    required String bookingId,
    required String action,
    String? reason,
  });
}

class ProviderRemoteDataSourceImpl implements ProviderRemoteDataSource {
  ProviderRemoteDataSourceImpl({required Dio cmsDio}) : _dio = cmsDio;

  final Dio _dio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<ProviderOverviewModel> getDashboardOverview() async {
    try {
      debugPrint('[PROVIDER] GET /api/v1/provider/overview/dashboard');
      final response = await _dio.get<dynamic>(
        '/api/v1/provider/overview/dashboard',
      );
      return ProviderOverviewModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ProviderProfileModel?> getProfile() async {
    try {
      debugPrint('[PROVIDER] GET /api/v1/provider-profiles/me');
      final response = await _dio.get<dynamic>('/api/v1/provider-profiles/me');
      final object = _extractObject(response.data);
      if (object.isEmpty) return null;
      return ProviderProfileModel.fromJson(object);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _rethrow(e);
    }
  }

  @override
  Future<ProviderProfileModel> apply(ProviderApplicationRequest request) async {
    try {
      debugPrint('[PROVIDER] POST /api/v1/provider-profiles/apply');
      final response = await _dio.post<dynamic>(
        '/api/v1/provider-profiles/apply',
        data: request.toJson(),
      );
      return ProviderProfileModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ProviderServiceModel>> getServices() async {
    try {
      debugPrint('[PROVIDER] GET /api/v1/provider/services');
      final response = await _dio.get<dynamic>(
        '/api/v1/provider/services',
        queryParameters: const {'skip': 0, 'limit': 50, 'search': ''},
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ProviderServiceModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ProviderServiceModel> createService(
    ProviderServiceRequest request,
  ) async {
    try {
      debugPrint('[PROVIDER] POST /api/v1/provider/services');
      final response = await _dio.post<dynamic>(
        '/api/v1/provider/services',
        data: request.toJson(),
      );
      return ProviderServiceModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ProviderBookingModel>> getBookings() async {
    try {
      debugPrint('[PROVIDER] GET /api/v1/provider/bookings');
      final response = await _dio.get<dynamic>(
        '/api/v1/provider/bookings',
        queryParameters: const {
          'page': 1,
          'page_size': 10,
          'search': '',
          'filter': 'pending',
        },
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ProviderBookingModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ProviderBookingModel> updateBookingStatus({
    required String bookingId,
    required String action,
    String? reason,
  }) async {
    try {
      debugPrint(
        '[PROVIDER] PATCH /api/v1/provider/bookings/$bookingId/$action',
      );
      final response = await _dio.patch<dynamic>(
        '/api/v1/provider/bookings/$bookingId/$action',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
      return ProviderBookingModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) return nested;
      if (nested is Map<String, dynamic>) {
        for (final key in const ['items', 'results', 'services', 'bookings']) {
          final value = nested[key];
          if (value is List) return value;
        }
      }
      for (final key in const ['items', 'results', 'services', 'bookings']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return const {};
  }
}
