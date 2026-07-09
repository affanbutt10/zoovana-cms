import '../../../../core/error/result.dart';
import '../entities/shelter_volunteer_entity.dart';
import '../repositories/shelter_repository.dart';

class UpdateShelterVolunteerStatus {
  UpdateShelterVolunteerStatus({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterVolunteerEntity>> call({
    required String volunteerId,
    required String status,
  }) {
    return _repository.updateVolunteerStatus(
      volunteerId: volunteerId,
      status: status,
    );
  }
}
