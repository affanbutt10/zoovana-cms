class ShelterAdoptionEntity {
  const ShelterAdoptionEntity({
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
}
