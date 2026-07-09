import '../../../../core/error/result.dart';
import '../../data/models/shelter_adoption_model.dart';
import '../entities/shelter_adoption_entity.dart';
import '../repositories/shelter_repository.dart';

class CreateShelterAdoption {
  CreateShelterAdoption({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterAdoptionEntity>> call(CreateAdoptionRequest request) {
    return _repository.createAdoption(request);
  }
}
