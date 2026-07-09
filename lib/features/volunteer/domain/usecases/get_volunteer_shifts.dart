import '../../../../core/error/result.dart';
import '../entities/volunteer_shift_entity.dart';
import '../repositories/volunteer_repository.dart';

class GetVolunteerShifts {
  GetVolunteerShifts({required VolunteerRepository repository})
    : _repository = repository;

  final VolunteerRepository _repository;

  Future<Result<List<VolunteerShiftEntity>>> call() => _repository.getShifts();
}
