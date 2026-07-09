import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../data/models/shelter_animal_model.dart';
import '../../data/models/shelter_adoption_model.dart';
import '../../data/models/shelter_kennel_model.dart';
import '../../data/models/shelter_medical_record_model.dart';
import '../../data/models/shelter_profile_model.dart';
import '../../data/models/shelter_vaccination_model.dart';
import '../../domain/entities/shelter_animal_entity.dart';
import '../../domain/entities/shelter_adoption_entity.dart';
import '../../domain/entities/shelter_animal_care_entity.dart';
import '../../domain/entities/shelter_donation_entity.dart';
import '../../domain/entities/shelter_kennel_entity.dart';
import '../../domain/entities/shelter_lost_found_entity.dart';
import '../../domain/entities/shelter_medical_record_entity.dart';
import '../../domain/entities/shelter_operation_entity.dart';
import '../../domain/entities/shelter_overview_entity.dart';
import '../../domain/entities/shelter_profile_entity.dart';
import '../../domain/entities/shelter_vaccination_entity.dart';
import '../../domain/entities/shelter_volunteer_entity.dart';
import '../../domain/usecases/create_shelter_animal.dart';
import '../../domain/usecases/create_shelter_adoption.dart';
import '../../domain/usecases/create_shelter_kennel.dart';
import '../../domain/usecases/create_shelter_medical_record.dart';
import '../../domain/usecases/create_shelter_profile.dart';
import '../../domain/usecases/create_shelter_vaccination.dart';
import '../../domain/usecases/get_shelter_animal_care_tasks.dart';
import '../../domain/usecases/get_shelter_animals.dart';
import '../../domain/usecases/get_shelter_adoptions.dart';
import '../../domain/usecases/get_shelter_donations.dart';
import '../../domain/usecases/get_shelter_kennels.dart';
import '../../domain/usecases/get_shelter_lost_found_reports.dart';
import '../../domain/usecases/get_shelter_medical_records.dart';
import '../../domain/usecases/get_shelter_operations.dart';
import '../../domain/usecases/get_shelter_overview.dart';
import '../../domain/usecases/get_shelter_profiles.dart';
import '../../domain/usecases/get_shelter_vaccinations.dart';
import '../../domain/usecases/get_shelter_volunteers.dart';
import '../../domain/usecases/update_shelter_adoption_status.dart';
import '../../domain/usecases/update_shelter_animal_care_status.dart';
import '../../domain/usecases/update_shelter_donation_status.dart';
import '../../domain/usecases/update_shelter_lost_found_status.dart';
import '../../domain/usecases/update_shelter_volunteer_status.dart';

enum ShelterStatus { idle, loading, success, error }

class ShelterController extends GetxController {
  ShelterController({
    required GetShelterOverview getOverview,
    required GetShelterOperations getOperations,
    required GetShelterProfiles getShelters,
    required CreateShelterProfile createShelter,
    required GetShelterAnimals getAnimals,
    required CreateShelterAnimal createAnimal,
    required GetShelterMedicalRecords getMedicalRecords,
    required CreateShelterMedicalRecord createMedicalRecord,
    required GetShelterVaccinations getVaccinations,
    required CreateShelterVaccination createVaccination,
    required GetShelterKennels getKennels,
    required CreateShelterKennel createKennel,
    required GetShelterAdoptions getAdoptions,
    required CreateShelterAdoption createAdoption,
    required UpdateShelterAdoptionStatus updateAdoptionStatus,
    required GetShelterVolunteers getVolunteers,
    required UpdateShelterVolunteerStatus updateVolunteerStatus,
    required GetShelterDonations getDonations,
    required UpdateShelterDonationStatus updateDonationStatus,
    required GetShelterLostFoundReports getLostFoundReports,
    required UpdateShelterLostFoundStatus updateLostFoundStatus,
    required GetShelterAnimalCareTasks getAnimalCareTasks,
    required UpdateShelterAnimalCareStatus updateAnimalCareStatus,
  }) : _getOverview = getOverview,
       _getOperations = getOperations,
       _getShelters = getShelters,
       _createShelter = createShelter,
       _getAnimals = getAnimals,
       _createAnimal = createAnimal,
       _getMedicalRecords = getMedicalRecords,
       _createMedicalRecord = createMedicalRecord,
       _getVaccinations = getVaccinations,
       _createVaccination = createVaccination,
       _getKennels = getKennels,
       _createKennel = createKennel,
       _getAdoptions = getAdoptions,
       _createAdoption = createAdoption,
       _updateAdoptionStatus = updateAdoptionStatus,
       _getVolunteers = getVolunteers,
       _updateVolunteerStatus = updateVolunteerStatus,
       _getDonations = getDonations,
       _updateDonationStatus = updateDonationStatus,
       _getLostFoundReports = getLostFoundReports,
       _updateLostFoundStatus = updateLostFoundStatus,
       _getAnimalCareTasks = getAnimalCareTasks,
       _updateAnimalCareStatus = updateAnimalCareStatus;

  final GetShelterOverview _getOverview;
  final GetShelterOperations _getOperations;
  final GetShelterProfiles _getShelters;
  final CreateShelterProfile _createShelter;
  final GetShelterAnimals _getAnimals;
  final CreateShelterAnimal _createAnimal;
  final GetShelterMedicalRecords _getMedicalRecords;
  final CreateShelterMedicalRecord _createMedicalRecord;
  final GetShelterVaccinations _getVaccinations;
  final CreateShelterVaccination _createVaccination;
  final GetShelterKennels _getKennels;
  final CreateShelterKennel _createKennel;
  final GetShelterAdoptions _getAdoptions;
  final CreateShelterAdoption _createAdoption;
  final UpdateShelterAdoptionStatus _updateAdoptionStatus;
  final GetShelterVolunteers _getVolunteers;
  final UpdateShelterVolunteerStatus _updateVolunteerStatus;
  final GetShelterDonations _getDonations;
  final UpdateShelterDonationStatus _updateDonationStatus;
  final GetShelterLostFoundReports _getLostFoundReports;
  final UpdateShelterLostFoundStatus _updateLostFoundStatus;
  final GetShelterAnimalCareTasks _getAnimalCareTasks;
  final UpdateShelterAnimalCareStatus _updateAnimalCareStatus;

  final overviewStatus = ShelterStatus.idle.obs;
  final moduleStatus = ShelterStatus.idle.obs;
  final sheltersStatus = ShelterStatus.idle.obs;
  final animalsStatus = ShelterStatus.idle.obs;
  final medicalStatus = ShelterStatus.idle.obs;
  final vaccinationsStatus = ShelterStatus.idle.obs;
  final kennelsStatus = ShelterStatus.idle.obs;
  final adoptionsStatus = ShelterStatus.idle.obs;
  final volunteersStatus = ShelterStatus.idle.obs;
  final donationsStatus = ShelterStatus.idle.obs;
  final lostFoundStatus = ShelterStatus.idle.obs;
  final animalCareStatus = ShelterStatus.idle.obs;
  final mutationStatus = ShelterStatus.idle.obs;
  final overview = Rxn<ShelterOverviewEntity>();
  final moduleItems = <ShelterOperationEntity>[].obs;
  final shelters = <ShelterProfileEntity>[].obs;
  final animals = <ShelterAnimalEntity>[].obs;
  final medicalRecords = <ShelterMedicalRecordEntity>[].obs;
  final vaccinations = <ShelterVaccinationEntity>[].obs;
  final kennels = <ShelterKennelEntity>[].obs;
  final adoptions = <ShelterAdoptionEntity>[].obs;
  final shelterVolunteers = <ShelterVolunteerEntity>[].obs;
  final donations = <ShelterDonationEntity>[].obs;
  final lostFoundReports = <ShelterLostFoundEntity>[].obs;
  final animalCareTasks = <ShelterAnimalCareEntity>[].obs;
  final errorMessage = ''.obs;
  final mutationError = ''.obs;

  Future<void> loadOverview() async {
    overviewStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getOverview();
    switch (result) {
      case Success(:final data):
        overview.value = data;
        overviewStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        overviewStatus.value = ShelterStatus.error;
    }
  }

  Future<void> loadModule(String module) async {
    moduleStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getOperations(module);
    switch (result) {
      case Success(:final data):
        moduleItems.assignAll(data);
        moduleStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        moduleStatus.value = ShelterStatus.error;
    }
  }

  Future<void> loadShelters() async {
    sheltersStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getShelters();
    switch (result) {
      case Success(:final data):
        shelters.assignAll(data);
        sheltersStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        sheltersStatus.value = ShelterStatus.error;
    }
  }

  Future<void> loadAnimals() async {
    animalsStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getAnimals();
    switch (result) {
      case Success(:final data):
        animals.assignAll(data);
        animalsStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        animalsStatus.value = ShelterStatus.error;
    }
  }

  Future<bool> createShelter(CreateShelterRequest request) async {
    mutationStatus.value = ShelterStatus.loading;
    mutationError.value = '';
    final result = await _createShelter(request);
    switch (result) {
      case Success(:final data):
        shelters.insert(0, data);
        mutationStatus.value = ShelterStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ShelterStatus.error;
        return false;
    }
  }

  Future<bool> createAnimal(CreateShelterAnimalRequest request) async {
    mutationStatus.value = ShelterStatus.loading;
    mutationError.value = '';
    final result = await _createAnimal(request);
    switch (result) {
      case Success(:final data):
        animals.insert(0, data);
        mutationStatus.value = ShelterStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ShelterStatus.error;
        return false;
    }
  }

  Future<void> loadMedicalRecords() async {
    medicalStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getMedicalRecords();
    switch (result) {
      case Success(:final data):
        medicalRecords.assignAll(data);
        medicalStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        medicalStatus.value = ShelterStatus.error;
    }
  }

  Future<void> loadVaccinations() async {
    vaccinationsStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getVaccinations();
    switch (result) {
      case Success(:final data):
        vaccinations.assignAll(data);
        vaccinationsStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        vaccinationsStatus.value = ShelterStatus.error;
    }
  }

  Future<bool> createMedicalRecord(CreateMedicalRecordRequest request) async {
    mutationStatus.value = ShelterStatus.loading;
    mutationError.value = '';
    final result = await _createMedicalRecord(request);
    switch (result) {
      case Success(:final data):
        medicalRecords.insert(0, data);
        mutationStatus.value = ShelterStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ShelterStatus.error;
        return false;
    }
  }

  Future<bool> createVaccination(CreateVaccinationRequest request) async {
    mutationStatus.value = ShelterStatus.loading;
    mutationError.value = '';
    final result = await _createVaccination(request);
    switch (result) {
      case Success(:final data):
        vaccinations.insert(0, data);
        mutationStatus.value = ShelterStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ShelterStatus.error;
        return false;
    }
  }

  Future<void> loadKennels() async {
    kennelsStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getKennels();
    switch (result) {
      case Success(:final data):
        kennels.assignAll(data);
        kennelsStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        kennelsStatus.value = ShelterStatus.error;
    }
  }

  Future<void> loadAdoptions() async {
    adoptionsStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getAdoptions();
    switch (result) {
      case Success(:final data):
        adoptions.assignAll(data);
        adoptionsStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        adoptionsStatus.value = ShelterStatus.error;
    }
  }

  Future<bool> createKennel(CreateKennelRequest request) async {
    mutationStatus.value = ShelterStatus.loading;
    mutationError.value = '';
    final result = await _createKennel(request);
    switch (result) {
      case Success(:final data):
        kennels.insert(0, data);
        mutationStatus.value = ShelterStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ShelterStatus.error;
        return false;
    }
  }

  Future<bool> createAdoption(CreateAdoptionRequest request) async {
    mutationStatus.value = ShelterStatus.loading;
    mutationError.value = '';
    final result = await _createAdoption(request);
    switch (result) {
      case Success(:final data):
        adoptions.insert(0, data);
        mutationStatus.value = ShelterStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ShelterStatus.error;
        return false;
    }
  }

  Future<void> updateAdoptionStatus(
    ShelterAdoptionEntity adoption,
    String status,
  ) async {
    final result = await _updateAdoptionStatus(
      adoptionId: adoption.id,
      status: status,
    );
    switch (result) {
      case Success(:final data):
        final index = adoptions.indexWhere((item) => item.id == adoption.id);
        if (index >= 0) adoptions[index] = data;
      case Failure(:final error):
        mutationError.value = error.message;
    }
  }

  Future<void> loadVolunteers() async {
    volunteersStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getVolunteers();
    switch (result) {
      case Success(:final data):
        shelterVolunteers.assignAll(data);
        volunteersStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        volunteersStatus.value = ShelterStatus.error;
    }
  }

  Future<void> updateVolunteerStatus(
    ShelterVolunteerEntity volunteer,
    String status,
  ) async {
    final result = await _updateVolunteerStatus(
      volunteerId: volunteer.id,
      status: status,
    );
    switch (result) {
      case Success(:final data):
        final index = shelterVolunteers.indexWhere(
          (item) => item.id == volunteer.id,
        );
        if (index >= 0) shelterVolunteers[index] = data;
      case Failure(:final error):
        mutationError.value = error.message;
    }
  }

  Future<void> loadDonations() async {
    donationsStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getDonations();
    switch (result) {
      case Success(:final data):
        donations.assignAll(data);
        donationsStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        donationsStatus.value = ShelterStatus.error;
    }
  }

  Future<void> updateDonationStatus(
    ShelterDonationEntity donation,
    String status,
  ) async {
    final result = await _updateDonationStatus(
      donationId: donation.id,
      status: status,
    );
    switch (result) {
      case Success(:final data):
        final index = donations.indexWhere((item) => item.id == donation.id);
        if (index >= 0) donations[index] = data;
      case Failure(:final error):
        mutationError.value = error.message;
    }
  }

  Future<void> loadLostFoundReports() async {
    lostFoundStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getLostFoundReports();
    switch (result) {
      case Success(:final data):
        lostFoundReports.assignAll(data);
        lostFoundStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        lostFoundStatus.value = ShelterStatus.error;
    }
  }

  Future<void> updateLostFoundStatus(
    ShelterLostFoundEntity report,
    String status,
  ) async {
    final result = await _updateLostFoundStatus(
      reportId: report.id,
      status: status,
    );
    switch (result) {
      case Success(:final data):
        final index = lostFoundReports.indexWhere(
          (item) => item.id == report.id,
        );
        if (index >= 0) lostFoundReports[index] = data;
      case Failure(:final error):
        mutationError.value = error.message;
    }
  }

  Future<void> loadAnimalCareTasks() async {
    animalCareStatus.value = ShelterStatus.loading;
    errorMessage.value = '';
    final result = await _getAnimalCareTasks();
    switch (result) {
      case Success(:final data):
        animalCareTasks.assignAll(data);
        animalCareStatus.value = ShelterStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        animalCareStatus.value = ShelterStatus.error;
    }
  }

  Future<void> updateAnimalCareStatus(
    ShelterAnimalCareEntity task,
    String status,
  ) async {
    final result = await _updateAnimalCareStatus(
      taskId: task.id,
      status: status,
    );
    switch (result) {
      case Success(:final data):
        final index = animalCareTasks.indexWhere((item) => item.id == task.id);
        if (index >= 0) animalCareTasks[index] = data;
      case Failure(:final error):
        mutationError.value = error.message;
    }
  }
}
