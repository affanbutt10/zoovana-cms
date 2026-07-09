import '../../../../core/error/result.dart';
import '../../data/models/provider_service_model.dart';
import '../entities/provider_service_entity.dart';
import '../repositories/provider_repository.dart';

class CreateProviderService {
  CreateProviderService({required ProviderRepository repository})
    : _repository = repository;

  final ProviderRepository _repository;

  Future<Result<ProviderServiceEntity>> call(ProviderServiceRequest request) {
    return _repository.createService(request);
  }
}
