import '../../../../core/error/result.dart';
import '../entities/volunteer_shelter_entity.dart';
import '../repositories/volunteer_repository.dart';

class GetVolunteerShelters {
  GetVolunteerShelters({required VolunteerRepository repository})
    : _repository = repository;

  final VolunteerRepository _repository;

  Future<Result<List<VolunteerShelterEntity>>> call() {
    return _repository.getShelters();
  }
}
