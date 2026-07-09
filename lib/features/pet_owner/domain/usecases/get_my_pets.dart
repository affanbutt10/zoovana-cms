import '../../../../core/error/result.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_owner_repository.dart';

class GetMyPets {
  GetMyPets({required PetOwnerRepository repository})
    : _repository = repository;

  final PetOwnerRepository _repository;

  Future<Result<List<PetEntity>>> call() => _repository.getPets();
}
