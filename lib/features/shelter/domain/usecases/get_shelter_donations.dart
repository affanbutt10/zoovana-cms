import '../../../../core/error/result.dart';
import '../entities/shelter_donation_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterDonations {
  GetShelterDonations({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterDonationEntity>>> call() {
    return _repository.getDonations();
  }
}
