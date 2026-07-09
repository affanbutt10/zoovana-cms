import '../../domain/entities/shelter_animal_care_entity.dart';

class ShelterAnimalCareModel {
  const ShelterAnimalCareModel({
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

  factory ShelterAnimalCareModel.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] is Map<String, dynamic>
        ? json['animal'] as Map<String, dynamic>
        : null;
    final assignee = json['assignee'] is Map<String, dynamic>
        ? json['assignee'] as Map<String, dynamic>
        : null;
    return ShelterAnimalCareModel(
      id: _string(json['id']),
      animalName: _string(
        json['animal_name'] ?? animal?['name'],
        fallback: 'Animal',
      ),
      taskType: _string(
        json['task_type'] ?? json['type'] ?? json['title'],
        fallback: 'Care task',
      ),
      status: _string(json['status'], fallback: 'pending'),
      assignedTo: _nullableString(
        json['assigned_to'] ?? json['caregiver_name'] ?? assignee?['name'],
      ),
      notes: _nullableString(json['notes'] ?? json['description']),
      dueAt: _date(json['due_at'] ?? json['scheduled_at']),
    );
  }

  ShelterAnimalCareEntity toEntity() => ShelterAnimalCareEntity(
    id: id,
    animalName: animalName,
    taskType: taskType,
    status: status,
    assignedTo: assignedTo,
    notes: notes,
    dueAt: dueAt,
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
