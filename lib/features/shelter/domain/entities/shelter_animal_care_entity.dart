class ShelterAnimalCareEntity {
  const ShelterAnimalCareEntity({
    required this.id,
    required this.animalName,
    required this.taskType,
    required this.status,
    this.assignedTo,
    this.notes,
    this.dueAt,
  });

  final String id;
  final String animalName;
  final String taskType;
  final String status;
  final String? assignedTo;
  final String? notes;
  final DateTime? dueAt;
}
