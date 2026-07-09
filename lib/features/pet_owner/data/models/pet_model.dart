import '../../domain/entities/pet_entity.dart';

class PetModel {
  const PetModel({
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

  factory PetModel.fromJson(Map<String, dynamic> json) {
    final photos = json['photos'];
    final firstPhoto = photos is List && photos.isNotEmpty
        ? photos.whereType<Map<String, dynamic>>().firstOrNull
        : null;
    final vaccinated = json['is_vaccinated'];

    return PetModel(
      id: _string(json['id'] ?? json['pet_id']),
      name: _string(json['name'] ?? json['pet_name'], fallback: 'Pet'),
      species: _nullableString(
        json['species'] ?? json['type'] ?? json['pet_type'] ?? json['domain'],
      ),
      breed: _nullableString(json['breed'] ?? json['breed_name']),
      ageLabel: _ageLabel(json['age_label'] ?? json['age']),
      photoUrl: _nullableString(
        json['photo_url'] ??
            json['image_url'] ??
            json['avatar_url'] ??
            firstPhoto?['photo_url'],
      ),
      healthStatus: _nullableString(
        json['health_status'] ??
            json['status'] ??
            (vaccinated is bool
                ? vaccinated
                      ? 'Vaccinated'
                      : 'Not vaccinated'
                : null),
      ),
    );
  }

  PetEntity toEntity() => PetEntity(
    id: id,
    name: name,
    species: species,
    breed: breed,
    ageLabel: ageLabel,
    photoUrl: photoUrl,
    healthStatus: healthStatus,
  );

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static String? _ageLabel(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      final years = value.toInt();
      return years == 1 ? '1 year' : '$years years';
    }
    final text = value.toString();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) return text;
    return parsed == 1 ? '1 year' : '$parsed years';
  }
}

class CreatePetRequest {
  const CreatePetRequest({
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.healthNotes,
  });

  final String name;
  final String species;
  final String? breed;
  final String? age;
  final String? healthNotes;

  Map<String, dynamic> toJson() => {
    'name': name,
    'species': species,
    if (breed != null && breed!.isNotEmpty) 'breed': breed,
    if (age != null && age!.isNotEmpty) 'age': age,
    if (healthNotes != null && healthNotes!.isNotEmpty)
      'health_notes': healthNotes,
  };
}
