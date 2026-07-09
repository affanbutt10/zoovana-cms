import '../../domain/entities/shelter_medical_record_entity.dart';

class ShelterMedicalRecordModel {
  const ShelterMedicalRecordModel({
    required this.id,
    required this.animalName,
    required this.diagnosis,
    required this.status,
    this.treatment,
    this.provider,
    this.recordedAt,
  });

  final String id;
  final String animalName;
  final String diagnosis;
  final String status;
  final String? treatment;
  final String? provider;
  final DateTime? recordedAt;

  factory ShelterMedicalRecordModel.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] is Map<String, dynamic>
        ? json['animal'] as Map<String, dynamic>
        : null;
    return ShelterMedicalRecordModel(
      id: _string(json['id']),
      animalName: _string(
        animal?['name'] ?? json['animal_name'],
        fallback: 'Animal',
      ),
      diagnosis: _string(
        json['diagnosis'] ?? json['title'],
        fallback: 'Medical record',
      ),
      status: _string(json['status'], fallback: 'open'),
      treatment: _nullableString(json['treatment']),
      provider: _nullableString(json['provider'] ?? json['vet_name']),
      recordedAt: _date(
        json['date'] ?? json['recorded_at'] ?? json['created_at'],
      ),
    );
  }

  ShelterMedicalRecordEntity toEntity() => ShelterMedicalRecordEntity(
    id: id,
    animalName: animalName,
    diagnosis: diagnosis,
    status: status,
    treatment: treatment,
    provider: provider,
    recordedAt: recordedAt,
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

class CreateMedicalRecordRequest {
  const CreateMedicalRecordRequest({
    required this.animalId,
    required this.diagnosis,
    this.treatment,
    this.provider,
    this.recordedAt,
  });

  final String animalId;
  final String diagnosis;
  final String? treatment;
  final String? provider;
  final DateTime? recordedAt;

  Map<String, dynamic> toJson() => {
    'animal_id': animalId,
    'diagnosis': diagnosis,
    if (treatment != null && treatment!.isNotEmpty) 'treatment': treatment,
    if (provider != null && provider!.isNotEmpty) 'provider': provider,
    if (recordedAt != null) 'date': recordedAt!.toIso8601String(),
  };
}
