import '../../domain/entities/shelter_animal_entity.dart';

class ShelterAnimalModel {
  const ShelterAnimalModel({
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

  factory ShelterAnimalModel.fromJson(Map<String, dynamic> json) {
    final shelter = json['shelter'] is Map<String, dynamic>
        ? json['shelter'] as Map<String, dynamic>
        : null;
    return ShelterAnimalModel(
      id: _string(json['id']),
      name: _string(json['name'], fallback: 'Animal'),
      status: _string(json['status'], fallback: 'intake'),
      code: _nullableString(json['code'] ?? json['animal_code']),
      species: _nullableString(
        json['species'] ?? json['type'] ?? json['pet_type'],
      ),
      breed: _nullableString(json['breed'] ?? json['breed_name']),
      healthStatus: _nullableString(json['health_status']),
      photoUrl: _nullableString(json['photo_url'] ?? json['image_url']),
      shelterName: _nullableString(shelter?['name'] ?? json['shelter_name']),
    );
  }

  ShelterAnimalEntity toEntity() => ShelterAnimalEntity(
    id: id,
    name: name,
    status: status,
    code: code,
    species: species,
    breed: breed,
    healthStatus: healthStatus,
    photoUrl: photoUrl,
    shelterName: shelterName,
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

class CreateShelterAnimalRequest {
  const CreateShelterAnimalRequest({
    required this.name,
    required this.shelterId,
    this.species,
    this.breed,
    this.status = 'intake',
  });

  final String name;
  final String shelterId;
  final String? species;
  final String? breed;
  final String status;

  Map<String, dynamic> toJson() => {
    'name': name,
    'shelter_id': shelterId,
    'status': status,
    if (species != null && species!.isNotEmpty) 'species': species,
    if (breed != null && breed!.isNotEmpty) 'breed': breed,
  };
}
