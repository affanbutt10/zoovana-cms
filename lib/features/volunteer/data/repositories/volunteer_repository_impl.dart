import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/volunteer_application_entity.dart';
import '../../domain/entities/volunteer_shelter_entity.dart';
import '../../domain/entities/volunteer_shift_entity.dart';
import '../../domain/repositories/volunteer_repository.dart';
import '../datasources/volunteer_remote_datasource.dart';
import '../models/volunteer_application_model.dart';

class VolunteerRepositoryImpl implements VolunteerRepository {
  VolunteerRepositoryImpl({required VolunteerRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final VolunteerRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<VolunteerShiftEntity>>> getShifts() async {
    try {
      final shifts = await _remoteDataSource.getShifts();
      return Success(shifts.map((shift) => shift.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<VolunteerApplicationEntity>>> getApplications() async {
    try {
      final apps = await _remoteDataSource.getApplications();
      return Success(apps.map((app) => app.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<VolunteerShelterEntity>>> getShelters() async {
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
  Future<Result<VolunteerApplicationEntity>> apply(
    VolunteerApplicationRequest request,
  ) async {
    try {
      final app = await _remoteDataSource.apply(request);
      return Success(app.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<VolunteerShiftEntity>> signIn(String shiftId) async {
    try {
      final shift = await _remoteDataSource.signIn(shiftId);
      return Success(shift.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<VolunteerShiftEntity>> signOut(String shiftId) async {
    try {
      final shift = await _remoteDataSource.signOut(shiftId);
      return Success(shift.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }
}
