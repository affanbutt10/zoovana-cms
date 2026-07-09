import '../../domain/entities/volunteer_shelter_entity.dart';

class VolunteerShelterModel {
  const VolunteerShelterModel({
    required this.id,
    required this.name,
    this.location,
    this.acceptingVolunteers = true,
  });

  final String id;
  final String name;
  final String? location;
  final bool acceptingVolunteers;

  factory VolunteerShelterModel.fromJson(Map<String, dynamic> json) {
    return VolunteerShelterModel(
      id: json['id']?.toString() ?? '',
      name:
          json['name']?.toString() ?? json['name_en']?.toString() ?? 'Shelter',
      location: json['location']?.toString() ?? json['city']?.toString(),
      acceptingVolunteers:
          json['accepting_volunteers'] != false &&
          json['volunteers_enabled'] != false,
    );
  }

  VolunteerShelterEntity toEntity() => VolunteerShelterEntity(
    id: id,
    name: name,
    location: location,
    acceptingVolunteers: acceptingVolunteers,
  );
}
