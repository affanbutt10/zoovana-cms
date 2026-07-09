import '../../../../core/error/result.dart';
import '../entities/shelter_overview_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterOverview {
  GetShelterOverview({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterOverviewEntity>> call() => _repository.getOverview();
}
