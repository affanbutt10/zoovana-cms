import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/shelter_adoption_entity.dart';
import '../../domain/entities/shelter_animal_care_entity.dart';
import '../../domain/entities/shelter_animal_entity.dart';
import '../../domain/entities/shelter_donation_entity.dart';
import '../../domain/entities/shelter_kennel_entity.dart';
import '../../domain/entities/shelter_lost_found_entity.dart';
import '../../domain/entities/shelter_medical_record_entity.dart';
import '../../domain/entities/shelter_operation_entity.dart';
import '../../domain/entities/shelter_overview_entity.dart';
import '../../domain/entities/shelter_profile_entity.dart';
import '../../domain/entities/shelter_vaccination_entity.dart';
import '../../domain/entities/shelter_volunteer_entity.dart';
import '../../domain/repositories/shelter_repository.dart';
import '../datasources/shelter_remote_datasource.dart';
import '../models/shelter_adoption_model.dart';
import '../models/shelter_animal_model.dart';
import '../models/shelter_kennel_model.dart';
import '../models/shelter_medical_record_model.dart';
import '../models/shelter_profile_model.dart';
import '../models/shelter_vaccination_model.dart';

class ShelterRepositoryImpl implements ShelterRepository {
  ShelterRepositoryImpl({required ShelterRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ShelterRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ShelterOverviewEntity>> getOverview() async {
    try {
      final stats = await _remoteDataSource.getStats();
      final activity = await _remoteDataSource.getOperations('animals');
      return Success(
        ShelterOverviewEntity(
          stats: stats.map((stat) => stat.toEntity()).toList(),
          recentActivity: activity
              .take(5)
              .map((item) => item.toEntity())
              .toList(),
        ),
      );
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterOperationEntity>>> getOperations(
    String module,
  ) async {
    try {
      final items = await _remoteDataSource.getOperations(module);
      return Success(items.map((item) => item.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterProfileEntity>>> getShelters() async {
    try {
      final shelters = await _remoteDataSource.getShelters();
      return Success(shelters.map((shelter) => shelter.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterProfileEntity>> createShelter(
    CreateShelterRequest request,
  ) async {
    try {
      final shelter = await _remoteDataSource.createShelter(request);
      return Success(shelter.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterAnimalEntity>>> getAnimals() async {
    try {
      final animals = await _remoteDataSource.getAnimals();
      return Success(animals.map((animal) => animal.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterAnimalEntity>> createAnimal(
    CreateShelterAnimalRequest request,
  ) async {
    try {
      final animal = await _remoteDataSource.createAnimal(request);
      return Success(animal.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterMedicalRecordEntity>>> getMedicalRecords() async {
    try {
      final records = await _remoteDataSource.getMedicalRecords();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterMedicalRecordEntity>> createMedicalRecord(
    CreateMedicalRecordRequest request,
  ) async {
    try {
      final record = await _remoteDataSource.createMedicalRecord(request);
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterVaccinationEntity>>> getVaccinations() async {
    try {
      final records = await _remoteDataSource.getVaccinations();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterVaccinationEntity>> createVaccination(
    CreateVaccinationRequest request,
  ) async {
    try {
      final record = await _remoteDataSource.createVaccination(request);
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterKennelEntity>>> getKennels() async {
    try {
      final records = await _remoteDataSource.getKennels();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterKennelEntity>> createKennel(
    CreateKennelRequest request,
  ) async {
    try {
      final record = await _remoteDataSource.createKennel(request);
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterAdoptionEntity>>> getAdoptions() async {
    try {
      final records = await _remoteDataSource.getAdoptions();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterAdoptionEntity>> createAdoption(
    CreateAdoptionRequest request,
  ) async {
    try {
      final record = await _remoteDataSource.createAdoption(request);
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterAdoptionEntity>> updateAdoptionStatus({
    required String adoptionId,
    required String status,
  }) async {
    try {
      final record = await _remoteDataSource.updateAdoptionStatus(
        adoptionId: adoptionId,
        status: status,
      );
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterVolunteerEntity>>> getVolunteers() async {
    try {
      final records = await _remoteDataSource.getVolunteers();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterVolunteerEntity>> updateVolunteerStatus({
    required String volunteerId,
    required String status,
  }) async {
    try {
      final record = await _remoteDataSource.updateVolunteerStatus(
        volunteerId: volunteerId,
        status: status,
      );
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterDonationEntity>>> getDonations() async {
    try {
      final records = await _remoteDataSource.getDonations();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterDonationEntity>> updateDonationStatus({
    required String donationId,
    required String status,
  }) async {
    try {
      final record = await _remoteDataSource.updateDonationStatus(
        donationId: donationId,
        status: status,
      );
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterLostFoundEntity>>> getLostFoundReports() async {
    try {
      final records = await _remoteDataSource.getLostFoundReports();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterLostFoundEntity>> updateLostFoundStatus({
    required String reportId,
    required String status,
  }) async {
    try {
      final record = await _remoteDataSource.updateLostFoundStatus(
        reportId: reportId,
        status: status,
      );
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ShelterAnimalCareEntity>>> getAnimalCareTasks() async {
    try {
      final records = await _remoteDataSource.getAnimalCareTasks();
      return Success(records.map((record) => record.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ShelterAnimalCareEntity>> updateAnimalCareStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final record = await _remoteDataSource.updateAnimalCareStatus(
        taskId: taskId,
        status: status,
      );
      return Success(record.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }
}
