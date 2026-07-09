class ShelterLostFoundEntity {
  const ShelterLostFoundEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.animalName,
    this.location,
    this.reporterName,
    this.reportedAt,
  });

  final String id;
  final String title;
  final String type;
  final String status;
  final String? animalName;
  final String? location;
  final String? reporterName;
  final DateTime? reportedAt;
}
