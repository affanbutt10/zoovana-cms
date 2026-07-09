import '../../../../core/error/result.dart';
import '../../data/models/volunteer_application_model.dart';
import '../entities/volunteer_application_entity.dart';
import '../entities/volunteer_shelter_entity.dart';
import '../entities/volunteer_shift_entity.dart';

abstract class VolunteerRepository {
  Future<Result<List<VolunteerShiftEntity>>> getShifts();
  Future<Result<List<VolunteerApplicationEntity>>> getApplications();
  Future<Result<List<VolunteerShelterEntity>>> getShelters();
  Future<Result<VolunteerApplicationEntity>> apply(
    VolunteerApplicationRequest request,
  );
  Future<Result<VolunteerShiftEntity>> signIn(String shiftId);
  Future<Result<VolunteerShiftEntity>> signOut(String shiftId);
}
