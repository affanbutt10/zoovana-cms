class ShelterAnimalEntity {
  const ShelterAnimalEntity({
    required this.id,
    required this.name,
    required this.status,
    this.code,
    this.species,
    this.breed,
    this.healthStatus,
    this.photoUrl,
    this.shelterName,
  });

  final String id;
  final String name;
  final String status;
  final String? code;
  final String? species;
  final String? breed;
  final String? healthStatus;
  final String? photoUrl;
  final String? shelterName;
}
