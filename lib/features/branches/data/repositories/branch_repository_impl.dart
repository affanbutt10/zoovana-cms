import '../../../../core/error/app_error.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/branch_entity.dart';
import '../datasources/branch_remote_datasource.dart';
import '../models/branch_model.dart';

/// Wraps [BranchRemoteDataSource] calls in [Result] — keeps exceptions
/// out of the presentation layer.
class BranchRepository {
  const BranchRepository(this._remote);

  final BranchRemoteDataSource _remote;

  Future<Result<({List<BranchEntity> branches, BranchPageMeta meta})>>
      getBranches({int page = 1, int pageSize = 20}) async {
    try {
      final result =
          await _remote.getBranches(page: page, pageSize: pageSize);
      return Success((
        branches: result.branches.map((m) => m.toEntity()).toList(),
        meta: result.meta,
      ));
    } on NetworkException {
      return Failure(AppError.network(
          'Unable to connect to server. Please check your connection.'));
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        return Failure(AppError.unauthorized(
            'Session expired. Please login again.'));
      }
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }

  Future<Result<BranchEntity>> createBranch(
      Map<String, dynamic> payload) async {
    try {
      final model = await _remote.createBranch(payload);
      return Success(model.toEntity());
    } on NetworkException {
      return Failure(AppError.network(
          'Unable to connect to server. Please check your connection.'));
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        return Failure(AppError.unauthorized(
            'Session expired. Please login again.'));
      }
      return Failure(AppError.serverError(e.message));
    } catch (e) {
      return Failure(AppError.serverError(e.toString()));
    }
  }
}
