import '../../../../core/error/result.dart';
import '../entities/shelter_adoption_entity.dart';
import '../repositories/shelter_repository.dart';

class UpdateShelterAdoptionStatus {
  UpdateShelterAdoptionStatus({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterAdoptionEntity>> call({
    required String adoptionId,
    required String status,
  }) {
    return _repository.updateAdoptionStatus(
      adoptionId: adoptionId,
      status: status,
    );
  }
}
