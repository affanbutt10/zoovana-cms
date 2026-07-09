import '../../../../core/error/result.dart';
import '../entities/shelter_volunteer_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterVolunteers {
  GetShelterVolunteers({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterVolunteerEntity>>> call() {
    return _repository.getVolunteers();
  }
}
