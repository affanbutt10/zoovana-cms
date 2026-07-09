import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../data/models/provider_profile_model.dart';
import '../../data/models/provider_service_model.dart';
import '../../domain/entities/provider_booking_entity.dart';
import '../../domain/entities/provider_overview_entity.dart';
import '../../domain/entities/provider_profile_entity.dart';
import '../../domain/entities/provider_service_entity.dart';
import '../../domain/usecases/apply_provider_profile.dart';
import '../../domain/usecases/create_provider_service.dart';
import '../../domain/usecases/get_provider_bookings.dart';
import '../../domain/usecases/get_provider_overview.dart';
import '../../domain/usecases/get_provider_services.dart';
import '../../domain/usecases/update_provider_booking_status.dart';

enum ProviderStatus { idle, loading, success, error }

enum ProviderMutationStatus { idle, loading, success, error }

class ProviderController extends GetxController {
  ProviderController({
    required GetProviderOverview getOverview,
    required ApplyProviderProfile applyProfile,
    required GetProviderServices getServices,
    required CreateProviderService createService,
    required GetProviderBookings getBookings,
    required UpdateProviderBookingStatus updateBookingStatus,
  }) : _getOverview = getOverview,
       _applyProfile = applyProfile,
       _getServices = getServices,
       _createService = createService,
       _getBookings = getBookings,
       _updateBookingStatus = updateBookingStatus;

  final GetProviderOverview _getOverview;
  final ApplyProviderProfile _applyProfile;
  final GetProviderServices _getServices;
  final CreateProviderService _createService;
  final GetProviderBookings _getBookings;
  final UpdateProviderBookingStatus _updateBookingStatus;

  final overviewStatus = ProviderStatus.idle.obs;
  final servicesStatus = ProviderStatus.idle.obs;
  final bookingsStatus = ProviderStatus.idle.obs;
  final mutationStatus = ProviderMutationStatus.idle.obs;

  final overview = Rxn<ProviderOverviewEntity>();
  final profile = Rxn<ProviderProfileEntity>();
  final services = <ProviderServiceEntity>[].obs;
  final bookings = <ProviderBookingEntity>[].obs;

  final errorMessage = ''.obs;
  final mutationError = ''.obs;
  final selectedBookingFilter = 'pending'.obs;

  List<ProviderBookingEntity> get filteredBookings {
    final filter = selectedBookingFilter.value;
    if (filter == 'all') return bookings.toList();
    return bookings.where((booking) => booking.status == filter).toList();
  }

  Future<void> loadOverview() async {
    overviewStatus.value = ProviderStatus.loading;
    errorMessage.value = '';
    final result = await _getOverview();
    switch (result) {
      case Success(:final data):
        overview.value = data;
        profile.value = data.profile;
        services.assignAll(data.services);
        bookings.assignAll(data.bookings);
        overviewStatus.value = ProviderStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        overviewStatus.value = ProviderStatus.error;
    }
  }

  Future<void> loadServices() async {
    servicesStatus.value = ProviderStatus.loading;
    final result = await _getServices();
    switch (result) {
      case Success(:final data):
        services.assignAll(data);
        servicesStatus.value = ProviderStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        servicesStatus.value = ProviderStatus.error;
    }
  }

  Future<void> loadBookings() async {
    bookingsStatus.value = ProviderStatus.loading;
    final result = await _getBookings();
    switch (result) {
      case Success(:final data):
        bookings.assignAll(data);
        bookingsStatus.value = ProviderStatus.success;
      case Failure(:final error):
        errorMessage.value = error.message;
        bookingsStatus.value = ProviderStatus.error;
    }
  }

  Future<bool> apply(ProviderApplicationRequest request) async {
    mutationStatus.value = ProviderMutationStatus.loading;
    mutationError.value = '';
    final result = await _applyProfile(request);
    switch (result) {
      case Success(:final data):
        profile.value = data;
        mutationStatus.value = ProviderMutationStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ProviderMutationStatus.error;
        return false;
    }
  }

  Future<bool> createService(ProviderServiceRequest request) async {
    mutationStatus.value = ProviderMutationStatus.loading;
    mutationError.value = '';
    final result = await _createService(request);
    switch (result) {
      case Success(:final data):
        services.insert(0, data);
        mutationStatus.value = ProviderMutationStatus.success;
        return true;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ProviderMutationStatus.error;
        return false;
    }
  }

  Future<void> updateBooking({
    required ProviderBookingEntity booking,
    required String action,
    String? reason,
  }) async {
    mutationStatus.value = ProviderMutationStatus.loading;
    final result = await _updateBookingStatus(
      bookingId: booking.id,
      action: action,
      reason: reason,
    );
    switch (result) {
      case Success(:final data):
        final index = bookings.indexWhere((item) => item.id == booking.id);
        if (index >= 0) bookings[index] = data;
        mutationStatus.value = ProviderMutationStatus.success;
      case Failure(:final error):
        mutationError.value = error.message;
        mutationStatus.value = ProviderMutationStatus.error;
    }
  }
}
