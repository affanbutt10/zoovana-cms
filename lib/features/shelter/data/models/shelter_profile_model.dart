import '../../domain/entities/shelter_profile_entity.dart';

class ShelterProfileModel {
  const ShelterProfileModel({
    required this.id,
    required this.name,
    required this.status,
    this.location,
    this.contact,
    this.acceptingVolunteers = false,
    this.donationsEnabled = false,
  });

  final String id;
  final String name;
  final String status;
  final String? location;
  final String? contact;
  final bool acceptingVolunteers;
  final bool donationsEnabled;

  factory ShelterProfileModel.fromJson(Map<String, dynamic> json) {
    return ShelterProfileModel(
      id: _string(json['id']),
      name: _string(json['name'] ?? json['name_en'], fallback: 'Shelter'),
      status: _string(json['status'], fallback: 'active'),
      location: _nullableString(
        json['location'] ?? json['city'] ?? json['address'],
      ),
      contact: _nullableString(
        json['phone'] ?? json['email'] ?? json['contact'],
      ),
      acceptingVolunteers:
          json['accepting_volunteers'] == true ||
          json['volunteers_enabled'] == true,
      donationsEnabled:
          json['donations_enabled'] == true ||
          json['accepts_donations'] == true,
    );
  }

  ShelterProfileEntity toEntity() => ShelterProfileEntity(
    id: id,
    name: name,
    status: status,
    location: location,
    contact: contact,
    acceptingVolunteers: acceptingVolunteers,
    donationsEnabled: donationsEnabled,
  );

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}

class CreateShelterRequest {
  const CreateShelterRequest({
    required this.name,
    this.location,
    this.contact,
    this.acceptingVolunteers = false,
    this.donationsEnabled = false,
  });

  final String name;
  final String? location;
  final String? contact;
  final bool acceptingVolunteers;
  final bool donationsEnabled;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (location != null && location!.isNotEmpty) 'location': location,
    if (contact != null && contact!.isNotEmpty) 'contact': contact,
    'accepting_volunteers': acceptingVolunteers,
    'donations_enabled': donationsEnabled,
  };
}
