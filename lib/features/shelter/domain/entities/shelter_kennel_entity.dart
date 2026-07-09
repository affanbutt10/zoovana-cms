class ShelterKennelEntity {
  const ShelterKennelEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.capacity,
    this.occupied = 0,
    this.shelterName,
  });

  final String id;
  final String name;
  final String status;
  final int capacity;
  final int occupied;
  final String? shelterName;

  int get available => capacity - occupied;
}
