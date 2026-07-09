import '../../../../core/error/result.dart';
import '../../data/models/provider_profile_model.dart';
import '../entities/provider_profile_entity.dart';
import '../repositories/provider_repository.dart';

class ApplyProviderProfile {
  ApplyProviderProfile({required ProviderRepository repository})
    : _repository = repository;

  final ProviderRepository _repository;

  Future<Result<ProviderProfileEntity>> call(
    ProviderApplicationRequest request,
  ) {
    return _repository.apply(request);
  }
}
