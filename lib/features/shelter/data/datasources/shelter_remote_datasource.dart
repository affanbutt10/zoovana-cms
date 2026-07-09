import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../models/shelter_adoption_model.dart';
import '../models/shelter_animal_care_model.dart';
import '../models/shelter_animal_model.dart';
import '../models/shelter_donation_model.dart';
import '../models/shelter_kennel_model.dart';
import '../models/shelter_lost_found_model.dart';
import '../models/shelter_medical_record_model.dart';
import '../models/shelter_operation_model.dart';
import '../models/shelter_profile_model.dart';
import '../models/shelter_vaccination_model.dart';
import '../models/shelter_volunteer_model.dart';

abstract class ShelterRemoteDataSource {
  Future<List<ShelterStatModel>> getStats();
  Future<List<ShelterOperationModel>> getOperations(String module);
  Future<List<ShelterProfileModel>> getShelters();
  Future<ShelterProfileModel> createShelter(CreateShelterRequest request);
  Future<List<ShelterAnimalModel>> getAnimals();
  Future<ShelterAnimalModel> createAnimal(CreateShelterAnimalRequest request);
  Future<List<ShelterMedicalRecordModel>> getMedicalRecords();
  Future<ShelterMedicalRecordModel> createMedicalRecord(
    CreateMedicalRecordRequest request,
  );
  Future<List<ShelterVaccinationModel>> getVaccinations();
  Future<ShelterVaccinationModel> createVaccination(
    CreateVaccinationRequest request,
  );
  Future<List<ShelterKennelModel>> getKennels();
  Future<ShelterKennelModel> createKennel(CreateKennelRequest request);
  Future<List<ShelterAdoptionModel>> getAdoptions();
  Future<ShelterAdoptionModel> createAdoption(CreateAdoptionRequest request);
  Future<ShelterAdoptionModel> updateAdoptionStatus({
    required String adoptionId,
    required String status,
  });
  Future<List<ShelterVolunteerModel>> getVolunteers();
  Future<ShelterVolunteerModel> updateVolunteerStatus({
    required String volunteerId,
    required String status,
  });
  Future<List<ShelterDonationModel>> getDonations();
  Future<ShelterDonationModel> updateDonationStatus({
    required String donationId,
    required String status,
  });
  Future<List<ShelterLostFoundModel>> getLostFoundReports();
  Future<ShelterLostFoundModel> updateLostFoundStatus({
    required String reportId,
    required String status,
  });
  Future<List<ShelterAnimalCareModel>> getAnimalCareTasks();
  Future<ShelterAnimalCareModel> updateAnimalCareStatus({
    required String taskId,
    required String status,
  });
}

class ShelterRemoteDataSourceImpl implements ShelterRemoteDataSource {
  ShelterRemoteDataSourceImpl({required Dio cmsDio}) : _dio = cmsDio;

  final Dio _dio;

  static const Map<String, String> _paths = {
    'shelters': '/api/v1/shelters',
    'animals': '/api/v1/animals',
    'medical': '/api/v1/medical-records',
    'vaccinations': '/api/v1/vaccinations',
    'kennels': '/api/v1/kennels',
    'adoptions': '/api/v1/adoptions',
    'volunteers': '/api/v1/volunteers',
    'donations': '/api/v1/donations',
    'lost_found': '/api/v1/lost-found',
    'animal_care': '/api/v1/animal-care',
  };

  Never _rethrow(DioException err) {
    final appError = err.error;
    if (appError is AppError) throw appError;
    throw AppError.serverError();
  }

  @override
  Future<List<ShelterStatModel>> getStats() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/dashboard/overview');
      final response = await _dio.get<dynamic>('/api/v1/dashboard/overview');
      final data = _extractObject(response.data);
      return [
        ShelterStatModel.fromJson('Animals', data['total_animals']),
        ShelterStatModel.fromJson('Available', data['available_animals']),
        ShelterStatModel.fromJson('Treatments', data['treatments_needed']),
        ShelterStatModel.fromJson('Vaccinations', data['vaccinations_due']),
      ];
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterOperationModel>> getOperations(String module) async {
    try {
      final path = _paths[module] ?? '/api/v1/$module';
      debugPrint('[SHELTER] GET $path');
      final response = await _dio.get<dynamic>(path);
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterOperationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterProfileModel>> getShelters() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/shelters');
      final response = await _dio.get<dynamic>('/api/v1/shelters');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterProfileModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterProfileModel> createShelter(
    CreateShelterRequest request,
  ) async {
    try {
      debugPrint('[SHELTER] POST /api/v1/shelters');
      final response = await _dio.post<dynamic>(
        '/api/v1/shelters',
        data: request.toJson(),
      );
      return ShelterProfileModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterAnimalModel>> getAnimals() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/animals');
      final response = await _dio.get<dynamic>('/api/v1/animals');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterAnimalModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterAnimalModel> createAnimal(
    CreateShelterAnimalRequest request,
  ) async {
    try {
      debugPrint('[SHELTER] POST /api/v1/animals');
      final response = await _dio.post<dynamic>(
        '/api/v1/animals',
        data: request.toJson(),
      );
      return ShelterAnimalModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterMedicalRecordModel>> getMedicalRecords() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/medical-records');
      final response = await _dio.get<dynamic>('/api/v1/medical-records');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterMedicalRecordModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterMedicalRecordModel> createMedicalRecord(
    CreateMedicalRecordRequest request,
  ) async {
    try {
      debugPrint('[SHELTER] POST /api/v1/medical-records');
      final response = await _dio.post<dynamic>(
        '/api/v1/medical-records',
        data: request.toJson(),
      );
      return ShelterMedicalRecordModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterVaccinationModel>> getVaccinations() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/vaccinations');
      final response = await _dio.get<dynamic>('/api/v1/vaccinations');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterVaccinationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterVaccinationModel> createVaccination(
    CreateVaccinationRequest request,
  ) async {
    try {
      debugPrint('[SHELTER] POST /api/v1/vaccinations');
      final response = await _dio.post<dynamic>(
        '/api/v1/vaccinations',
        data: request.toJson(),
      );
      return ShelterVaccinationModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterKennelModel>> getKennels() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/kennels');
      final response = await _dio.get<dynamic>('/api/v1/kennels');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterKennelModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterKennelModel> createKennel(CreateKennelRequest request) async {
    try {
      debugPrint('[SHELTER] POST /api/v1/kennels');
      final response = await _dio.post<dynamic>(
        '/api/v1/kennels',
        data: request.toJson(),
      );
      return ShelterKennelModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterAdoptionModel>> getAdoptions() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/adoptions');
      final response = await _dio.get<dynamic>('/api/v1/adoptions');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterAdoptionModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterAdoptionModel> createAdoption(
    CreateAdoptionRequest request,
  ) async {
    try {
      debugPrint('[SHELTER] POST /api/v1/adoptions');
      final response = await _dio.post<dynamic>(
        '/api/v1/adoptions',
        data: request.toJson(),
      );
      return ShelterAdoptionModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterAdoptionModel> updateAdoptionStatus({
    required String adoptionId,
    required String status,
  }) async {
    try {
      debugPrint('[SHELTER] PATCH /api/v1/adoptions/$adoptionId/status');
      final response = await _dio.patch<dynamic>(
        '/api/v1/adoptions/$adoptionId/status',
        data: {'status': status},
      );
      return ShelterAdoptionModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterVolunteerModel>> getVolunteers() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/volunteers');
      final response = await _dio.get<dynamic>('/api/v1/volunteers');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterVolunteerModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterVolunteerModel> updateVolunteerStatus({
    required String volunteerId,
    required String status,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/api/v1/volunteers/$volunteerId/status',
        data: {'status': status},
      );
      return ShelterVolunteerModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterDonationModel>> getDonations() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/donations');
      final response = await _dio.get<dynamic>('/api/v1/donations');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterDonationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterDonationModel> updateDonationStatus({
    required String donationId,
    required String status,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/api/v1/donations/$donationId/status',
        data: {'status': status},
      );
      return ShelterDonationModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterLostFoundModel>> getLostFoundReports() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/lost-found');
      final response = await _dio.get<dynamic>('/api/v1/lost-found');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterLostFoundModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterLostFoundModel> updateLostFoundStatus({
    required String reportId,
    required String status,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/api/v1/lost-found/$reportId/status',
        data: {'status': status},
      );
      return ShelterLostFoundModel.fromJson(_extractObject(response.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<List<ShelterAnimalCareModel>> getAnimalCareTasks() async {
    try {
      debugPrint('[SHELTER] GET /api/v1/animal-care');
      final response = await _dio.get<dynamic>('/api/v1/animal-care');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ShelterAnimalCareModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<ShelterAnimalCareModel> updateAnimalCareStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/api/v1/animal-care/$taskId/status',
        data: {'status': status},
      );
      return ShelterAnimalCareModel.fromJson(_extractObject(response.data));
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
        for (final key in const ['items', 'results', 'data', 'records']) {
          final value = nested[key];
          if (value is List) return value;
        }
      }
      for (final key in const ['items', 'results', 'records']) {
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
