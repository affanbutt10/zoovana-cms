import '../../../../core/error/result.dart';
import '../entities/provider_booking_entity.dart';
import '../repositories/provider_repository.dart';

class UpdateProviderBookingStatus {
  UpdateProviderBookingStatus({required ProviderRepository repository})
    : _repository = repository;

  final ProviderRepository _repository;

  Future<Result<ProviderBookingEntity>> call({
    required String bookingId,
    required String action,
    String? reason,
  }) {
    return _repository.updateBookingStatus(
      bookingId: bookingId,
      action: action,
      reason: reason,
    );
  }
}
