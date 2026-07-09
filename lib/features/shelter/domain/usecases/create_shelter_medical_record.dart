import '../../../../core/error/result.dart';
import '../../data/models/shelter_medical_record_model.dart';
import '../entities/shelter_medical_record_entity.dart';
import '../repositories/shelter_repository.dart';

class CreateShelterMedicalRecord {
  CreateShelterMedicalRecord({required ShelterRepository repository})
    : _repository = repository;

  final ShelterRepository _repository;

  Future<Result<ShelterMedicalRecordEntity>> call(
    CreateMedicalRecordRequest request,
  ) {
    return _repository.createMedicalRecord(request);
  }
}
