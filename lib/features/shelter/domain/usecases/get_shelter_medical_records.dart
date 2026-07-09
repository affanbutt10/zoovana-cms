import '../../../../core/error/result.dart';
import '../entities/shelter_medical_record_entity.dart';
import '../repositories/shelter_repository.dart';

class GetShelterMedicalRecords {
  GetShelterMedicalRecords({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<List<ShelterMedicalRecordEntity>>> call() {
    return _repository.getMedicalRecords();
  }
}
