import '../../../../core/error/result.dart';
import '../entities/shelter_lost_found_entity.dart';
import '../repositories/shelter_repository.dart';

class UpdateShelterLostFoundStatus {
  UpdateShelterLostFoundStatus({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterLostFoundEntity>> call({
    required String reportId,
    required String status,
  }) {
    return _repository.updateLostFoundStatus(
      reportId: reportId,
      status: status,
    );
  }
}
