import '../../domain/entities/shelter_adoption_entity.dart';

class ShelterAdoptionModel {
  const ShelterAdoptionModel({
    required this.id,
    required this.animalName,
    required this.applicantName,
    required this.status,
    this.submittedAt,
    this.notes,
  });

  final String id;
  final String animalName;
  final String applicantName;
  final String status;
  final DateTime? submittedAt;
  final String? notes;

  factory ShelterAdoptionModel.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] is Map<String, dynamic>
        ? json['animal'] as Map<String, dynamic>
        : null;
    final applicant = json['applicant'] is Map<String, dynamic>
        ? json['applicant'] as Map<String, dynamic>
        : null;
    return ShelterAdoptionModel(
      id: json['id']?.toString() ?? '',
      animalName:
          animal?['name']?.toString() ??
          json['animal_name']?.toString() ??
          'Animal',
      applicantName:
          applicant?['name']?.toString() ??
          applicant?['full_name']?.toString() ??
          json['applicant_name']?.toString() ??
          'Applicant',
      status: json['status']?.toString() ?? 'pending',
      submittedAt: _date(json['submitted_at'] ?? json['created_at']),
      notes: json['notes']?.toString(),
    );
  }

  ShelterAdoptionEntity toEntity() => ShelterAdoptionEntity(
    id: id,
    animalName: animalName,
    applicantName: applicantName,
    status: status,
    submittedAt: submittedAt,
    notes: notes,
  );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class CreateAdoptionRequest {
  const CreateAdoptionRequest({
    required this.animalId,
    required this.applicantName,
    this.notes,
  });

  final String animalId;
  final String applicantName;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'animal_id': animalId,
    'applicant_name': applicantName,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
