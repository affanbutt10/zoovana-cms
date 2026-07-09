import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/pet_booking_entity.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_owner_overview_entity.dart';
import '../../domain/entities/pet_service_entity.dart';
import '../../domain/repositories/pet_owner_repository.dart';
import '../datasources/pet_owner_remote_datasource.dart';
import '../models/pet_booking_model.dart';
import '../models/pet_model.dart';

class PetOwnerRepositoryImpl implements PetOwnerRepository {
  PetOwnerRepositoryImpl({required PetOwnerRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final PetOwnerRemoteDataSource _remoteDataSource;

  @override
  Future<Result<PetOwnerOverviewEntity>> getOverview() async {
    try {
      final pets = (await _remoteDataSource.getPets())
          .map((pet) => pet.toEntity())
          .toList();
      final bookings = await _getOverviewBookingsSafely();
      return Success(PetOwnerOverviewEntity(pets: pets, bookings: bookings));
    } on AppError catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Overview: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Overview unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  Future<List<PetBookingEntity>> _getOverviewBookingsSafely() async {
    try {
      return (await _remoteDataSource.getBookings())
          .map((booking) => booking.toEntity())
          .toList();
    } on AppError catch (e) {
      debugPrint(
        '[PET_OWNER_REPO][WARN] Overview bookings unavailable: ${e.message}',
      );
      return const <PetBookingEntity>[];
    } catch (e) {
      debugPrint(
        '[PET_OWNER_REPO][WARN] Overview bookings unexpected error: $e',
      );
      return const <PetBookingEntity>[];
    }
  }

  @override
  Future<Result<List<PetEntity>>> getPets() async {
    try {
      final pets = await _remoteDataSource.getPets();
      return Success(pets.map((pet) => pet.toEntity()).toList());
    } on AppError catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Pets: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Pets unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<PetEntity>> createPet(CreatePetRequest request) async {
    try {
      final pet = await _remoteDataSource.createPet(request);
      return Success(pet.toEntity());
    } on AppError catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Create pet: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Create pet unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<PetServiceEntity>>> searchServices({String? query}) async {
    try {
      final services = await _remoteDataSource.searchServices(query: query);
      return Success(services.map((service) => service.toEntity()).toList());
    } on AppError catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Services: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Services unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<List<PetBookingEntity>>> getBookings() async {
    try {
      final bookings = await _remoteDataSource.getBookings();
      return Success(bookings.map((booking) => booking.toEntity()).toList());
    } on AppError catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Bookings: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Bookings unexpected: $e');
      return Failure(AppError.serverError());
    }
  }

  @override
  Future<Result<PetBookingEntity>> requestBooking(
    BookingRequest request,
  ) async {
    try {
      final booking = await _remoteDataSource.requestBooking(request);
      return Success(booking.toEntity());
    } on AppError catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Request booking: ${e.message}');
      return Failure(e);
    } catch (e) {
      debugPrint('[PET_OWNER_REPO][ERROR] Request booking unexpected: $e');
      return Failure(AppError.serverError());
    }
  }
}
