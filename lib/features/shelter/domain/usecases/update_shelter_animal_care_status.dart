import '../../../../core/error/result.dart';
import '../entities/shelter_animal_care_entity.dart';
import '../repositories/shelter_repository.dart';

class UpdateShelterAnimalCareStatus {
  UpdateShelterAnimalCareStatus({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterAnimalCareEntity>> call({
    required String taskId,
    required String status,
  }) {
    return _repository.updateAnimalCareStatus(taskId: taskId, status: status);
  }
}
