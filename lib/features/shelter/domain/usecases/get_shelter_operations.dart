import '../../../../core/error/result.dart';
import '../entities/shelter_operation_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterOperations {
  GetShelterOperations({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterOperationEntity>>> call(String module) {
    return _repository.getOperations(module);
  }
}
