import '../../../../core/error/result.dart';
import '../../data/models/shelter_animal_model.dart';
import '../entities/shelter_animal_entity.dart';
import '../repositories/shelter_repository.dart';

class CreateShelterAnimal {
  CreateShelterAnimal({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterAnimalEntity>> call(CreateShelterAnimalRequest request) {
    return _repository.createAnimal(request);
  }
}
