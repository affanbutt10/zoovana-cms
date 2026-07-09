import '../../../../core/error/result.dart';
import '../entities/provider_booking_entity.dart';
import '../repositories/provider_repository.dart';

class GetProviderBookings {
  GetProviderBookings({required ProviderRepository repository})
    : _repository = repository;

  final ProviderRepository _repository;

  Future<Result<List<ProviderBookingEntity>>> call() {
    return _repository.getBookings();
  }
}
