import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/entities/business_with_branches_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_datasource.dart';

/// Concrete implementation of [ShopRepository].
///
/// Delegates network calls to [ShopRemoteDataSource] and persists the active
/// branch ID via [LocalStorageService].
class ShopRepositoryImpl implements ShopRepository {
  const ShopRepositoryImpl({
    required ShopRemoteDataSource remoteDataSource,
    required LocalStorageService localStorage,
  }) : _remoteDataSource = remoteDataSource,
       _localStorage = localStorage;

  final ShopRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorage;

  // ---------------------------------------------------------------------------
  // ShopRepository
  // ---------------------------------------------------------------------------

  @override
  Future<Result<BusinessWithBranchesEntity>> getBusinessWithBranches() async {
    try {
      debugPrint('[INIT] ShopRepository.getBusinessWithBranches → calling datasource');
      final model = await _remoteDataSource.getBusinessWithBranches();
      final entity = model.toEntity();
      debugPrint('[INIT] ShopRepository.getBusinessWithBranches → success '
          'id=${entity.id} branches=${entity.branches.length}');

      if (entity.branches.isNotEmpty) {
        await _localStorage.setString(
          LocalStorageKeys.activeBranchId,
          entity.branches[0].id,
        );
      }

      return Success(entity);
    } on AppError catch (appError) {
      debugPrint('[INIT][ERROR] ShopRepository.getBusinessWithBranches AppError: '
          '${appError.message}');
      return Failure(appError);
    } catch (e, st) {
      debugPrint('[INIT][ERROR] ShopRepository.getBusinessWithBranches: $e');
      debugPrint('[INIT][STACK] $st');
      return Failure(AppError.serverError(
          'Response format mismatch. Check model mapping.'));
    }
  }

  @override
  Future<Result<List<BranchEntity>>> getBranches() async {
    try {
      debugPrint('[INIT] ShopRepository.getBranches → calling datasource');
      final models = await _remoteDataSource.getBranches();
      final branches = models.map((m) => m.toEntity()).toList();
      debugPrint('[INIT] ShopRepository.getBranches → success count=${branches.length}');
      return Success(branches);
    } on AppError catch (appError) {
      debugPrint('[INIT][ERROR] ShopRepository.getBranches AppError: '
          '${appError.message}');
      return Failure(appError);
    } catch (e, st) {
      debugPrint('[INIT][ERROR] ShopRepository.getBranches: $e');
      debugPrint('[INIT][STACK] $st');
      return Failure(AppError.serverError(
          'Response format mismatch. Check model mapping.'));
    }
  }
}
