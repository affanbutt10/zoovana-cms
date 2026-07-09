import '../../domain/entities/shelter_volunteer_entity.dart';

class ShelterVolunteerModel {
  const ShelterVolunteerModel({
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

  factory ShelterVolunteerModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;
    final shelter = json['shelter'] is Map<String, dynamic>
        ? json['shelter'] as Map<String, dynamic>
        : null;
    final rawSkills = json['skills'];
    return ShelterVolunteerModel(
      id: json['id']?.toString() ?? '',
      name:
          user?['name']?.toString() ??
          user?['full_name']?.toString() ??
          json['name']?.toString() ??
          'Volunteer',
      status: json['status']?.toString() ?? 'pending',
      shelterName:
          shelter?['name']?.toString() ?? json['shelter_name']?.toString(),
      skills: rawSkills is List ? rawSkills.join(', ') : rawSkills?.toString(),
      appliedAt: _date(json['applied_at'] ?? json['created_at']),
    );
  }

  ShelterVolunteerEntity toEntity() => ShelterVolunteerEntity(
    id: id,
    name: name,
    status: status,
    shelterName: shelterName,
    skills: skills,
    appliedAt: appliedAt,
  );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
