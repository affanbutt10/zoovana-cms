import '../../../../core/error/result.dart';
import '../entities/provider_service_entity.dart';
import '../repositories/provider_repository.dart';

class GetProviderServices {
  GetProviderServices({required ProviderRepository repository})
    : _repository = repository;

  final ProviderRepository _repository;

  Future<Result<List<ProviderServiceEntity>>> call() {
    return _repository.getServices();
  }
}
