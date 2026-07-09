import '../../../../core/error/result.dart';
import '../entities/shelter_animal_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterAnimals {
  GetShelterAnimals({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterAnimalEntity>>> call() {
    return _repository.getAnimals();
  }
}
