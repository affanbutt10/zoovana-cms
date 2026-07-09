import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/pet_booking_model.dart';
import '../models/pet_model.dart';
import '../models/pet_service_model.dart';

abstract class PetOwnerRemoteDataSource {
  Future<List<PetModel>> getPets();

  Future<PetModel> createPet(CreatePetRequest request);

  Future<List<PetServiceModel>> searchServices({String? query});

  Future<List<PetBookingModel>> getBookings();

  Future<PetBookingModel> requestBooking(BookingRequest request);
}

class PetOwnerRemoteDataSourceImpl implements PetOwnerRemoteDataSource {
  PetOwnerRemoteDataSourceImpl({required Dio cmsDio}) : _dio = cmsDio;

  final Dio _dio;

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<List<PetModel>> getPets() async {
    try {
      debugPrint('[PET_OWNER] GET /api/v1/pets?page=1&page_size=20');
      final response = await _dio.get<dynamic>(
        '/api/v1/pets',
        queryParameters: const {'page': 1, 'page_size': 20},
      );
      return _extractList(
        response.data,
      ).whereType<Map<String, dynamic>>().map(PetModel.fromJson).toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<PetModel> createPet(CreatePetRequest request) async {
    try {
      debugPrint('[PET_OWNER] POST /api/v1/pets');
      final response = await _dio.post<dynamic>(
        '/api/v1/pets',
        data: request.toJson(),
      );
      return PetModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<PetServiceModel>> searchServices({String? query}) async {
    try {
      debugPrint(
        '[PET_OWNER] GET /api/v1/search/providers?page=1&page_size=20',
      );
      final response = await _dio.get<dynamic>(
        '/api/v1/search/providers',
        queryParameters: {
          'page': 1,
          'page_size': 20,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(PetServiceModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<PetBookingModel>> getBookings() async {
    try {
      debugPrint(
        '[PET_OWNER] GET /api/v1/bookings/my?page=1&page_size=20&search=&filter=created',
      );
      final response = await _dio.get<dynamic>(
        '/api/v1/bookings/my',
        queryParameters: const {
          'page': 1,
          'page_size': 20,
          'search': '',
          'filter': 'created',
        },
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(PetBookingModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<PetBookingModel> requestBooking(BookingRequest request) async {
    try {
      debugPrint('[PET_OWNER] POST /api/v1/bookings/request');
      final response = await _dio.post<dynamic>(
        '/api/v1/bookings/request',
        data: request.toJson(),
      );
      return PetBookingModel.fromJson(_extractObject(response.data));
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
          'pets',
          'providers',
          'services',
          'bookings',
        ]) {
          final value = nested[key];
          if (value is List) return value;
        }
      }
      for (final key in const [
        'items',
        'results',
        'pets',
        'providers',
        'services',
        'bookings',
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
