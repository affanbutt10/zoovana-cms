import '../../../../core/error/result.dart';
import '../entities/pet_booking_entity.dart';
import '../repositories/pet_owner_repository.dart';

class GetPetBookings {
  GetPetBookings({required PetOwnerRepository repository})
    : _repository = repository;

  final PetOwnerRepository _repository;

  Future<Result<List<PetBookingEntity>>> call() => _repository.getBookings();
}
