import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/provider_booking_entity.dart';
import '../../domain/entities/provider_overview_entity.dart';
import '../../domain/entities/provider_profile_entity.dart';
import '../../domain/entities/provider_service_entity.dart';
import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_remote_datasource.dart';
import '../models/provider_booking_model.dart';
import '../models/provider_overview_model.dart';
import '../models/provider_profile_model.dart';
import '../models/provider_service_model.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  ProviderRepositoryImpl({required ProviderRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ProviderRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ProviderOverviewEntity>> getOverview() async {
    try {
      final results = await Future.wait([
        _remoteDataSource.getProfile(),
        _remoteDataSource.getDashboardOverview(),
        _remoteDataSource.getServices(),
        _remoteDataSource.getBookings(),
      ]);
      final profile = results[0] as ProviderProfileModel?;
      final dashboard = results[1] as ProviderOverviewModel;
      final services = (results[2] as List<ProviderServiceModel>)
          .map((service) => service.toEntity())
          .toList();
      final bookings = (results[3] as List<ProviderBookingModel>)
          .map((booking) => booking.toEntity())
          .toList();
      return Success(
        dashboard.toEntity(
          profile: profile?.toEntity(),
          services: services,
          bookings: bookings,
        ),
      );
    } on AppError catch (e) {
      debugPrint('[PROVIDER_REPO][ERROR] Overview: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PROVIDER_REPO][ERROR] Overview unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ProviderProfileEntity?>> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      return Success(profile?.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ProviderProfileEntity>> apply(
    ProviderApplicationRequest request,
  ) async {
    try {
      final profile = await _remoteDataSource.apply(request);
      return Success(profile.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ProviderServiceEntity>>> getServices() async {
    try {
      final services = await _remoteDataSource.getServices();
      return Success(services.map((service) => service.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ProviderServiceEntity>> createService(
    ProviderServiceRequest request,
  ) async {
    try {
      final service = await _remoteDataSource.createService(request);
      return Success(service.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<ProviderBookingEntity>>> getBookings() async {
    try {
      final bookings = await _remoteDataSource.getBookings();
      return Success(bookings.map((booking) => booking.toEntity()).toList());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<ProviderBookingEntity>> updateBookingStatus({
    required String bookingId,
    required String action,
    String? reason,
  }) async {
    try {
      final booking = await _remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        action: action,
        reason: reason,
      );
      return Success(booking.toEntity());
    } on AppError catch (e) {
      return Failure(e);
    } catch (_) {
      return Failure(AppError.serverError());
    }
  }
}
