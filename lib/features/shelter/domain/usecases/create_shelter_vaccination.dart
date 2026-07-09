import '../../../../core/error/result.dart';
import '../../data/models/shelter_vaccination_model.dart';
import '../entities/shelter_vaccination_entity.dart';
import '../repositories/shelter_repository.dart';

class CreateShelterVaccination {
  CreateShelterVaccination({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterVaccinationEntity>> call(
    CreateVaccinationRequest request,
  ) {
    return _repository.createVaccination(request);
  }
}
