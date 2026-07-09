import '../../../../core/error/result.dart';
import '../../data/models/pet_model.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_owner_repository.dart';

class CreatePet {
  CreatePet({required PetOwnerRepository repository})
    : _repository = repository;

  final PetOwnerRepository _repository;

  Future<Result<PetEntity>> call(CreatePetRequest request) {
    return _repository.createPet(request);
  }
}
