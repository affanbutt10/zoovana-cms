import 'shelter_operation_entity.dart';
import 'shelter_stat_entity.dart';

class ShelterOverviewEntity {
  const ShelterOverviewEntity({
    required this.stats,
    required this.recentActivity,
  });

  final List<ShelterStatEntity> stats;
  final List<ShelterOperationEntity> recentActivity;
}
