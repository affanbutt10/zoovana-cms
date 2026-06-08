import '../../../../core/error/result.dart';
import '../entities/dashboard_overview_entity.dart';

abstract class DashboardRepository {
  Future<Result<DashboardOverviewEntity>> getDashboardOverview();
}
