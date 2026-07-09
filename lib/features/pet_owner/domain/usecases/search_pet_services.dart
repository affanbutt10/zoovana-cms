import '../../../../core/error/result.dart';
import '../entities/pet_service_entity.dart';
import '../repositories/pet_owner_repository.dart';

class SearchPetServices {
  SearchPetServices({required PetOwnerRepository repository})
    : _repository = repository;

  final PetOwnerRepository _repository;

  Future<Result<List<PetServiceEntity>>> call({String? query}) {
    return _repository.searchServices(query: query);
  }
}
