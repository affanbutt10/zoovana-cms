import '../../../../core/error/result.dart';
import '../../data/models/shelter_profile_model.dart';
import '../entities/shelter_profile_entity.dart';
import '../repositories/shelter_repository.dart';

class CreateShelterProfile {
  CreateShelterProfile({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterProfileEntity>> call(CreateShelterRequest request) {
    return _repository.createShelter(request);
  }
}
