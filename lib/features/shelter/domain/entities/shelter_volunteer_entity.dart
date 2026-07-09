class ShelterVolunteerEntity {
  const ShelterVolunteerEntity({
    required this.id,
    required this.name,
    required this.status,
    this.shelterName,
    this.skills,
    this.appliedAt,
  });

  final String id;
  final String name;
  final String status;
  final String? shelterName;
  final String? skills;
  final DateTime? appliedAt;
}
