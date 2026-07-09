import '../../../../core/error/result.dart';
import '../entities/shelter_lost_found_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterLostFoundReports {
  GetShelterLostFoundReports({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterLostFoundEntity>>> call() {
    return _repository.getLostFoundReports();
  }
}
