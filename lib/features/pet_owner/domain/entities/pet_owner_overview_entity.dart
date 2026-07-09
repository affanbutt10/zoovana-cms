import 'pet_booking_entity.dart';
import 'pet_entity.dart';

class PetOwnerOverviewEntity {
  const PetOwnerOverviewEntity({
    required this.pets,
    required this.bookings,
    this.unreadMessages = 0,
  });

  final List<PetEntity> pets;
  final List<PetBookingEntity> bookings;
  final int unreadMessages;

  int get petCount => pets.length;

  int get activeBookingCount {
    return bookings
        .where(
          (booking) =>
              booking.status == 'pending' || booking.status == 'confirmed',
        )
        .length;
  }

  List<PetEntity> get petPreview => pets.take(3).toList();
}
