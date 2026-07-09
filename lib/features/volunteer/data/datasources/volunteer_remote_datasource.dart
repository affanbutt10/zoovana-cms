import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/volunteer_application_model.dart';
import '../models/volunteer_shelter_model.dart';
import '../models/volunteer_shift_model.dart';

abstract class VolunteerRemoteDataSource {
  Future<List<VolunteerShiftModel>> getShifts();
  Future<List<VolunteerApplicationModel>> getApplications();
  Future<List<VolunteerShelterModel>> getShelters();
  Future<VolunteerApplicationModel> apply(VolunteerApplicationRequest request);
  Future<VolunteerShiftModel> signIn(String shiftId);
  Future<VolunteerShiftModel> signOut(String shiftId);
}

class VolunteerRemoteDataSourceImpl implements VolunteerRemoteDataSource {
  VolunteerRemoteDataSourceImpl({required Dio cmsDio}) : _dio = cmsDio;

  final Dio _dio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<List<VolunteerShiftModel>> getShifts() async {
    try {
      debugPrint('[VOLUNTEER] GET /api/v1/volunteers/me/shifts');
      final response = await _dio.get<dynamic>('/api/v1/volunteers/me/shifts');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(VolunteerShiftModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<VolunteerApplicationModel>> getApplications() async {
    try {
      debugPrint('[VOLUNTEER] GET /api/v1/volunteers/me/applications');
      final response = await _dio.get<dynamic>(
        '/api/v1/volunteers/me/applications',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(VolunteerApplicationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<VolunteerShelterModel>> getShelters() async {
    try {
      debugPrint('[VOLUNTEER] GET /api/v1/shelters/public');
      final response = await _dio.get<dynamic>('/api/v1/shelters/public');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(VolunteerShelterModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<VolunteerApplicationModel> apply(
    VolunteerApplicationRequest request,
  ) async {
    try {
      debugPrint('[VOLUNTEER] POST /api/v1/volunteers/apply');
      final response = await _dio.post<dynamic>(
        '/api/v1/volunteers/apply',
        data: request.toJson(),
      );
      return VolunteerApplicationModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<VolunteerShiftModel> signIn(String shiftId) async {
    return _shiftAction(shiftId, 'sign-in');
  }

  @override
  Future<VolunteerShiftModel> signOut(String shiftId) async {
    return _shiftAction(shiftId, 'sign-out');
  }

  Future<VolunteerShiftModel> _shiftAction(
    String shiftId,
    String action,
  ) async {
    try {
      debugPrint('[VOLUNTEER] POST /api/v1/volunteers/shifts/$shiftId/$action');
      final response = await _dio.post<dynamic>(
        '/api/v1/volunteers/shifts/$shiftId/$action',
      );
      return VolunteerShiftModel.fromJson(_extractObject(response.data));
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
        for (final key in const [
          'items',
          'results',
          'shifts',
          'applications',
          'shelters',
        ]) {
          final value = nested[key];
          if (value is List) return value;
        }
      }
      for (final key in const [
        'items',
        'results',
        'shifts',
        'applications',
        'shelters',
      ]) {
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
