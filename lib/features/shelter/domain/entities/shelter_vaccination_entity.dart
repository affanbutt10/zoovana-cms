class ShelterVaccinationEntity {
  const ShelterVaccinationEntity({
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
}
