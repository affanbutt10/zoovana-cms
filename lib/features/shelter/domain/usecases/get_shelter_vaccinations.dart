import '../../../../core/error/result.dart';
import '../entities/shelter_vaccination_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterVaccinations {
  GetShelterVaccinations({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterVaccinationEntity>>> call() {
    return _repository.getVaccinations();
  }
}
