import '../../../../core/error/result.dart';
import '../../data/models/provider_profile_model.dart';
import '../../data/models/provider_service_model.dart';
import '../entities/provider_booking_entity.dart';
import '../entities/provider_overview_entity.dart';
import '../entities/provider_profile_entity.dart';
import '../entities/provider_service_entity.dart';

abstract class ProviderRepository {
  Future<Result<ProviderOverviewEntity>> getOverview();

  Future<Result<ProviderProfileEntity?>> getProfile();

  Future<Result<ProviderProfileEntity>> apply(
    ProviderApplicationRequest request,
  );

  Future<Result<List<ProviderServiceEntity>>> getServices();

  Future<Result<ProviderServiceEntity>> createService(
    ProviderServiceRequest request,
  );

  Future<Result<List<ProviderBookingEntity>>> getBookings();

  Future<Result<ProviderBookingEntity>> updateBookingStatus({
    required String bookingId,
    required String action,
    String? reason,
  });
}
