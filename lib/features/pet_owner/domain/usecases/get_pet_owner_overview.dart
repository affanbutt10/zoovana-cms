import '../../../../core/error/result.dart';
import '../entities/pet_owner_overview_entity.dart';
import '../repositories/pet_owner_repository.dart';

class GetPetOwnerOverview {
  GetPetOwnerOverview({required PetOwnerRepository repository})
    : _repository = repository;

  final PetOwnerRepository _repository;

  Future<Result<PetOwnerOverviewEntity>> call() => _repository.getOverview();
}
