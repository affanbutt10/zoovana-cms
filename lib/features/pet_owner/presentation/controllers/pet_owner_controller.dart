import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../data/models/pet_booking_model.dart';
import '../../data/models/pet_model.dart';
import '../../domain/entities/pet_booking_entity.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_owner_overview_entity.dart';
import '../../domain/entities/pet_service_entity.dart';
import '../../domain/usecases/create_pet.dart';
import '../../domain/usecases/get_my_pets.dart';
import '../../domain/usecases/get_pet_bookings.dart';
import '../../domain/usecases/get_pet_owner_overview.dart';
import '../../domain/usecases/request_pet_booking.dart';
import '../../domain/usecases/search_pet_services.dart';

enum PetOwnerStatus { idle, loading, success, error }

enum PetOwnerMutationStatus { idle, loading, success, error }

class PetOwnerController extends GetxController {
  PetOwnerController({
    required GetPetOwnerOverview getOverview,
    required GetMyPets getMyPets,
    required CreatePet createPet,
    required SearchPetServices searchServices,
    required GetPetBookings getBookings,
    required RequestPetBooking requestBooking,
  }) : _getOverview = getOverview,
       _getMyPets = getMyPets,
       _createPet = createPet,
       _searchServices = searchServices,
       _getBookings = getBookings,
       _requestBooking = requestBooking;

  final GetPetOwnerOverview _getOverview;
  final GetMyPets _getMyPets;
  final CreatePet _createPet;
  final SearchPetServices _searchServices;
  final GetPetBookings _getBookings;
  final RequestPetBooking _requestBooking;

  final overviewStatus = PetOwnerStatus.idle.obs;
  final petsStatus = PetOwnerStatus.idle.obs;
  final servicesStatus = PetOwnerStatus.idle.obs;
  final bookingsStatus = PetOwnerStatus.idle.obs;
  final mutationStatus = PetOwnerMutationStatus.idle.obs;

  final overview = Rxn<PetOwnerOverviewEntity>();
  final pets = <PetEntity>[].obs;
  final services = <PetServiceEntity>[].obs;
  final bookings = <PetBookingEntity>[].obs;

  final errorMessage = ''.obs;
  final mutationError = ''.obs;
  final selectedBookingFilter = 'all'.obs;

  List<PetBookingEntity> get filteredBookings {
    final filter = selectedBookingFilter.value;
    if (filter == 'all') return bookings.toList();
    return bookings.where((booking) => booking.status == filter).toList();
  }

  Future<void> loadOverview() async {
    overviewStatus.value = PetOwnerStatus.loading;
    errorMessage.value = '';
    debugPrint('[PET_OWNER_CTRL] Loading overview');

    final result = await _getOverview();
    switch (result) {
      case Success(:final data):
        overview.value = data;
        pets.assignAll(data.pets);
        bookings.assignAll(data.bookings);
        overviewStatus.value = PetOwnerStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        overviewStatus.value = PetOwnerStatus.error;
    }
  }

  Future<void> loadPets() async {
    petsStatus.value = PetOwnerStatus.loading;
    errorMessage.value = '';

    final result = await _getMyPets();
    switch (result) {
      case Success(:final data):
        pets.assignAll(data);
        petsStatus.value = PetOwnerStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        petsStatus.value = PetOwnerStatus.error;
    }
  }

  Future<void> loadServices({String? query}) async {
    servicesStatus.value = PetOwnerStatus.loading;
    errorMessage.value = '';

    final result = await _searchServices(query: query);
    switch (result) {
      case Success(:final data):
        services.assignAll(data);
        servicesStatus.value = PetOwnerStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        servicesStatus.value = PetOwnerStatus.error;
    }
  }

  Future<void> loadBookings() async {
    bookingsStatus.value = PetOwnerStatus.loading;
    errorMessage.value = '';

    final result = await _getBookings();
    switch (result) {
      case Success(:final data):
        bookings.assignAll(data);
        bookingsStatus.value = PetOwnerStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        bookingsStatus.value = PetOwnerStatus.error;
    }
  }

  Future<bool> createNewPet(CreatePetRequest request) async {
    mutationStatus.value = PetOwnerMutationStatus.loading;
    mutationError.value = '';

    final result = await _createPet(request);
    switch (result) {
      case Success(:final data):
        pets.insert(0, data);
        mutationStatus.value = PetOwnerMutationStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = PetOwnerMutationStatus.error;
        return false;
    }
  }

  Future<bool> requestNewBooking(BookingRequest request) async {
    mutationStatus.value = PetOwnerMutationStatus.loading;
    mutationError.value = '';

    final result = await _requestBooking(request);
    switch (result) {
      case Success(:final data):
        bookings.insert(0, data);
        mutationStatus.value = PetOwnerMutationStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = PetOwnerMutationStatus.error;
        return false;
    }
  }
}
