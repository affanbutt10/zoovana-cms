import '../../../../core/error/result.dart';
import '../../data/models/pet_booking_model.dart';
import '../../data/models/pet_model.dart';
import '../entities/pet_booking_entity.dart';
import '../entities/pet_entity.dart';
import '../entities/pet_owner_overview_entity.dart';
import '../entities/pet_service_entity.dart';

abstract class PetOwnerRepository {
  Future<Result<PetOwnerOverviewEntity>> getOverview();

  Future<Result<List<PetEntity>>> getPets();

  Future<Result<PetEntity>> createPet(CreatePetRequest request);

  Future<Result<List<PetServiceEntity>>> searchServices({String? query});

  Future<Result<List<PetBookingEntity>>> getBookings();

  Future<Result<PetBookingEntity>> requestBooking(BookingRequest request);
}
