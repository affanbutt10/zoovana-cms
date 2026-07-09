import '../../../../core/error/result.dart';
import '../entities/shelter_animal_care_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterAnimalCareTasks {
  GetShelterAnimalCareTasks({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterAnimalCareEntity>>> call() {
    return _repository.getAnimalCareTasks();
  }
}
