import '../../../../core/error/result.dart';
import '../entities/volunteer_application_entity.dart';
import '../repositories/volunteer_repository.dart';

class GetVolunteerApplications {
  GetVolunteerApplications({required VolunteerRepository repository})
    : _repository = repository;

  final VolunteerRepository _repository;

  Future<Result<List<VolunteerApplicationEntity>>> call() {
    return _repository.getApplications();
  }
}
