import '../../../../core/error/result.dart';
import '../entities/dashboard_overview_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardOverview {
  final DashboardRepository _repository;

  GetDashboardOverview({required DashboardRepository repository})
      : _repository = repository;

  Future<Result<DashboardOverviewEntity>> call() async {
    return await _repository.getDashboardOverview();
  }
}
