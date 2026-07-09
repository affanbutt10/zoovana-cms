import '../../domain/entities/shelter_vaccination_entity.dart';

class ShelterVaccinationModel {
  const ShelterVaccinationModel({
    required this.id,
    required this.animalName,
    required this.vaccineName,
    required this.status,
    this.givenAt,
    this.dueAt,
    this.notes,
  });

  final String id;
  final String animalName;
  final String vaccineName;
  final String status;
  final DateTime? givenAt;
  final DateTime? dueAt;
  final String? notes;

  factory ShelterVaccinationModel.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] is Map<String, dynamic>
        ? json['animal'] as Map<String, dynamic>
        : null;
    return ShelterVaccinationModel(
      id: _string(json['id']),
      animalName: _string(
        animal?['name'] ?? json['animal_name'],
        fallback: 'Animal',
      ),
      vaccineName: _string(
        json['vaccine_name'] ?? json['name'],
        fallback: 'Vaccine',
      ),
      status: _string(json['status'], fallback: 'scheduled'),
      givenAt: _date(json['given_at'] ?? json['date']),
      dueAt: _date(json['due_at'] ?? json['due_date']),
      notes: _nullableString(json['notes']),
    );
  }

  ShelterVaccinationEntity toEntity() => ShelterVaccinationEntity(
    id: id,
    animalName: animalName,
    vaccineName: vaccineName,
    status: status,
    givenAt: givenAt,
    dueAt: dueAt,
    notes: notes,
  );

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class CreateVaccinationRequest {
  const CreateVaccinationRequest({
    required this.animalId,
    required this.vaccineName,
    this.givenAt,
    this.dueAt,
    this.notes,
  });

  final String animalId;
  final String vaccineName;
  final DateTime? givenAt;
  final DateTime? dueAt;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'animal_id': animalId,
    'vaccine_name': vaccineName,
    if (givenAt != null) 'given_at': givenAt!.toIso8601String(),
    if (dueAt != null) 'due_at': dueAt!.toIso8601String(),
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
