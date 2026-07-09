import '../../domain/entities/shelter_kennel_entity.dart';

class ShelterKennelModel {
  const ShelterKennelModel({
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

  factory ShelterKennelModel.fromJson(Map<String, dynamic> json) {
    final shelter = json['shelter'] is Map<String, dynamic>
        ? json['shelter'] as Map<String, dynamic>
        : null;
    return ShelterKennelModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['code']?.toString() ?? 'Kennel',
      status: json['status']?.toString() ?? 'available',
      capacity: _int(json['capacity']),
      occupied: _int(json['occupied'] ?? json['current_occupancy']),
      shelterName:
          shelter?['name']?.toString() ?? json['shelter_name']?.toString(),
    );
  }

  ShelterKennelEntity toEntity() => ShelterKennelEntity(
    id: id,
    name: name,
    status: status,
    capacity: capacity,
    occupied: occupied,
    shelterName: shelterName,
  );

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CreateKennelRequest {
  const CreateKennelRequest({
    required this.name,
    required this.shelterId,
    required this.capacity,
  });

  final String name;
  final String shelterId;
  final int capacity;

  Map<String, dynamic> toJson() => {
    'name': name,
    'shelter_id': shelterId,
    'capacity': capacity,
  };
}
