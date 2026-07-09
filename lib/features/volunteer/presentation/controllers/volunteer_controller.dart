import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../data/models/volunteer_application_model.dart';
import '../../domain/entities/volunteer_application_entity.dart';
import '../../domain/entities/volunteer_shelter_entity.dart';
import '../../domain/entities/volunteer_shift_entity.dart';
import '../../domain/usecases/apply_volunteer.dart';
import '../../domain/usecases/get_volunteer_applications.dart';
import '../../domain/usecases/get_volunteer_shelters.dart';
import '../../domain/usecases/get_volunteer_shifts.dart';
import '../../domain/usecases/sign_in_volunteer_shift.dart';
import '../../domain/usecases/sign_out_volunteer_shift.dart';

enum VolunteerStatus { idle, loading, success, error }

enum VolunteerMutationStatus { idle, loading, success, error }

class VolunteerController extends GetxController {
  VolunteerController({
    required GetVolunteerShifts getShifts,
    required GetVolunteerApplications getApplications,
    required GetVolunteerShelters getShelters,
    required ApplyVolunteer applyVolunteer,
    required SignInVolunteerShift signInShift,
    required SignOutVolunteerShift signOutShift,
  }) : _getShifts = getShifts,
       _getApplications = getApplications,
       _getShelters = getShelters,
       _applyVolunteer = applyVolunteer,
       _signInShift = signInShift,
       _signOutShift = signOutShift;

  final GetVolunteerShifts _getShifts;
  final GetVolunteerApplications _getApplications;
  final GetVolunteerShelters _getShelters;
  final ApplyVolunteer _applyVolunteer;
  final SignInVolunteerShift _signInShift;
  final SignOutVolunteerShift _signOutShift;

  final status = VolunteerStatus.idle.obs;
  final sheltersStatus = VolunteerStatus.idle.obs;
  final mutationStatus = VolunteerMutationStatus.idle.obs;

  final shifts = <VolunteerShiftEntity>[].obs;
  final applications = <VolunteerApplicationEntity>[].obs;
  final shelters = <VolunteerShelterEntity>[].obs;
  final errorMessage = ''.obs;
  final mutationError = ''.obs;

  VolunteerApplicationEntity? get latestApplication {
    if (applications.isEmpty) return null;
    return applications.first;
  }

  int get totalHours {
    return shifts.fold<int>(
      0,
      (sum, shift) => sum + (shift.hoursWorked ?? 0).round(),
    );
  }

  Future<void> loadDashboard() async {
    status.value = VolunteerStatus.loading;
    errorMessage.value = '';
    final shiftResult = await _getShifts();
    final appResult = await _getApplications();

    switch (shiftResult) {
      case Success(:final data):
        shifts.assignAll(data);
      case Failure(:final error):
        errorMessage.value = error.message;
        status.value = VolunteerStatus.error;
        return;
    }

    switch (appResult) {
      case Success(:final data):
        applications.assignAll(data);
        status.value = VolunteerStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        status.value = VolunteerStatus.error;
    }
  }

  Future<void> loadShelters() async {
    sheltersStatus.value = VolunteerStatus.loading;
    final result = await _getShelters();
    switch (result) {
      case Success(:final data):
        shelters.assignAll(data);
        sheltersStatus.value = VolunteerStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        sheltersStatus.value = VolunteerStatus.error;
    }
  }

  Future<bool> apply(VolunteerApplicationRequest request) async {
    mutationStatus.value = VolunteerMutationStatus.loading;
    mutationError.value = '';
    final result = await _applyVolunteer(request);
    switch (result) {
      case Success(:final data):
        applications.insert(0, data);
        mutationStatus.value = VolunteerMutationStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = VolunteerMutationStatus.error;
        return false;
    }
  }

  Future<void> signIn(VolunteerShiftEntity shift) async {
    await _updateShift(await _signInShift(shift.id), shift.id);
  }

  Future<void> signOut(VolunteerShiftEntity shift) async {
    await _updateShift(await _signOutShift(shift.id), shift.id);
  }

  Future<void> _updateShift(
    Result<VolunteerShiftEntity> result,
    String shiftId,
  ) async {
    switch (result) {
      case Success(:final data):
        final index = shifts.indexWhere((shift) => shift.id == shiftId);
        if (index >= 0) shifts[index] = data;
      case Failure(:final error):
        mutationError.value = error.message;
    }
  }
}
