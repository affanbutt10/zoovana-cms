import '../../../../core/error/result.dart';
import '../entities/shelter_adoption_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterAdoptions {
  GetShelterAdoptions({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterAdoptionEntity>>> call() {
    return _repository.getAdoptions();
  }
}
