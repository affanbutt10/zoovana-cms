import '../../../../core/error/result.dart';
import '../entities/shelter_profile_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterProfiles {
  GetShelterProfiles({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterProfileEntity>>> call() {
    return _repository.getShelters();
  }
}
