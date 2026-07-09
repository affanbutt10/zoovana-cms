class PetEntity {
  const PetEntity({
    required this.id,
    required this.name,
    this.species,
    this.breed,
    this.ageLabel,
    this.photoUrl,
    this.healthStatus,
  });

  final String id;
  final String name;
  final String? species;
  final String? breed;
  final String? ageLabel;
  final String? photoUrl;
  final String? healthStatus;
}
