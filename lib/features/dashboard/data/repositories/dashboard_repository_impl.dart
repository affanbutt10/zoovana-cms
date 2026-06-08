import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/dashboard_overview_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _remoteDatasource;

  DashboardRepositoryImpl({
    required DashboardRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Future<Result<DashboardOverviewEntity>> getDashboardOverview() async {
    try {
      final model = await _remoteDatasource.getDashboardOverview();
      return Success(model.toEntity());
    } on AppError catch (e) {
      debugPrint('[DASHBOARD_REPO][ERROR] ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[DASHBOARD_REPO][ERROR] Unexpected: $e');
      return Failure(AppError.serverError());
    }
  }
}
