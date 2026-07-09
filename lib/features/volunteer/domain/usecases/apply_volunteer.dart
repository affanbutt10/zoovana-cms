import '../../../../core/error/result.dart';
import '../../data/models/volunteer_application_model.dart';
import '../entities/volunteer_application_entity.dart';
import '../repositories/volunteer_repository.dart';

class ApplyVolunteer {
  ApplyVolunteer({required VolunteerRepository repository})
    : _repository = repository;

  final VolunteerRepository _repository;

  Future<Result<VolunteerApplicationEntity>> call(
    VolunteerApplicationRequest request,
  ) {
    return _repository.apply(request);
  }
}
