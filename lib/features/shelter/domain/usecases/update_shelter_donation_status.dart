import '../../../../core/error/result.dart';
import '../entities/shelter_donation_entity.dart';
import '../repositories/shelter_repository.dart';

class UpdateShelterDonationStatus {
  UpdateShelterDonationStatus({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterDonationEntity>> call({
    required String donationId,
    required String status,
  }) {
    return _repository.updateDonationStatus(
      donationId: donationId,
      status: status,
    );
  }
}
