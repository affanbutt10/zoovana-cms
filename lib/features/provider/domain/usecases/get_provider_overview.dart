import '../../../../core/error/result.dart';
import '../entities/provider_overview_entity.dart';
import '../repositories/provider_repository.dart';

class GetProviderOverview {
  GetProviderOverview({required ProviderRepository repository})
    : _repository = repository;

  final ProviderRepository _repository;

  Future<Result<ProviderOverviewEntity>> call() => _repository.getOverview();
}
