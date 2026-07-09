import '../../../../core/error/result.dart';
import '../../data/models/shelter_kennel_model.dart';
import '../entities/shelter_kennel_entity.dart';
import '../repositories/shelter_repository.dart';

class CreateShelterKennel {
  CreateShelterKennel({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterKennelEntity>> call(CreateKennelRequest request) {
    return _repository.createKennel(request);
  }
}
