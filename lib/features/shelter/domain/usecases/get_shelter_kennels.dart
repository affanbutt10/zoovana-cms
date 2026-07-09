import '../../../../core/error/result.dart';
import '../entities/shelter_kennel_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterKennels {
  GetShelterKennels({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterKennelEntity>>> call() => _repository.getKennels();
}
