import '../../../../core/error/result.dart';
import '../entities/volunteer_shift_entity.dart';
import '../repositories/volunteer_repository.dart';

class SignInVolunteerShift {
  SignInVolunteerShift({required VolunteerRepository repository})
    : _repository = repository;

  final VolunteerRepository _repository;

  Future<Result<VolunteerShiftEntity>> call(String shiftId) {
    return _repository.signIn(shiftId);
  }
}
