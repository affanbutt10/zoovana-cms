import '../../../../core/error/result.dart';
import '../../data/models/pet_booking_model.dart';
import '../entities/pet_booking_entity.dart';
import '../repositories/pet_owner_repository.dart';

class RequestPetBooking {
  RequestPetBooking({required PetOwnerRepository repository})
    : _repository = repository;

  final PetOwnerRepository _repository;

  Future<Result<PetBookingEntity>> call(BookingRequest request) {
    return _repository.requestBooking(request);
  }
}
