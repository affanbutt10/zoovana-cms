import '../../../../core/error/result.dart';
import '../../data/models/shelter_adoption_model.dart';
import '../../data/models/shelter_animal_model.dart';
import '../../data/models/shelter_kennel_model.dart';
import '../../data/models/shelter_medical_record_model.dart';
import '../../data/models/shelter_profile_model.dart';
import '../../data/models/shelter_vaccination_model.dart';
import '../entities/shelter_animal_entity.dart';
import '../entities/shelter_adoption_entity.dart';
import '../entities/shelter_animal_care_entity.dart';
import '../entities/shelter_donation_entity.dart';
import '../entities/shelter_kennel_entity.dart';
import '../entities/shelter_lost_found_entity.dart';
import '../entities/shelter_medical_record_entity.dart';
import '../entities/shelter_operation_entity.dart';
import '../entities/shelter_overview_entity.dart';
import '../entities/shelter_profile_entity.dart';
import '../entities/shelter_vaccination_entity.dart';
import '../entities/shelter_volunteer_entity.dart';

abstract class ShelterRepository {
  Future<Result<ShelterOverviewEntity>> getOverview();
  Future<Result<List<ShelterOperationEntity>>> getOperations(String module);
  Future<Result<List<ShelterProfileEntity>>> getShelters();
  Future<Result<ShelterProfileEntity>> createShelter(
    CreateShelterRequest request,
  );
  Future<Result<List<ShelterAnimalEntity>>> getAnimals();
  Future<Result<ShelterAnimalEntity>> createAnimal(
    CreateShelterAnimalRequest request,
  );
  Future<Result<List<ShelterMedicalRecordEntity>>> getMedicalRecords();
  Future<Result<ShelterMedicalRecordEntity>> createMedicalRecord(
    CreateMedicalRecordRequest request,
  );
  Future<Result<List<ShelterVaccinationEntity>>> getVaccinations();
  Future<Result<ShelterVaccinationEntity>> createVaccination(
    CreateVaccinationRequest request,
  );
  Future<Result<List<ShelterKennelEntity>>> getKennels();
  Future<Result<ShelterKennelEntity>> createKennel(CreateKennelRequest request);
  Future<Result<List<ShelterAdoptionEntity>>> getAdoptions();
  Future<Result<ShelterAdoptionEntity>> createAdoption(
    CreateAdoptionRequest request,
  );
  Future<Result<ShelterAdoptionEntity>> updateAdoptionStatus({
    required String adoptionId,
    required String status,
  });
  Future<Result<List<ShelterVolunteerEntity>>> getVolunteers();
  Future<Result<ShelterVolunteerEntity>> updateVolunteerStatus({
    required String volunteerId,
    required String status,
  });
  Future<Result<List<ShelterDonationEntity>>> getDonations();
  Future<Result<ShelterDonationEntity>> updateDonationStatus({
    required String donationId,
    required String status,
  });
  Future<Result<List<ShelterLostFoundEntity>>> getLostFoundReports();
  Future<Result<ShelterLostFoundEntity>> updateLostFoundStatus({
    required String reportId,
    required String status,
  });
  Future<Result<List<ShelterAnimalCareEntity>>> getAnimalCareTasks();
  Future<Result<ShelterAnimalCareEntity>> updateAnimalCareStatus({
    required String taskId,
    required String status,
  });
}
