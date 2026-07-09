class ShelterMedicalRecordEntity {
  const ShelterMedicalRecordEntity({
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
}
