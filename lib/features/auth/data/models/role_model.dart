import '../../domain/entities/role_entity.dart';

/// Data-layer model that parses a role object from the API response.
///
/// Constructed via [RoleModel.fromJson] from a raw JSON map.
/// Call [toEntity] to obtain the domain-layer [RoleEntity].
class RoleModel {
  const RoleModel({
    required this.id,
    required this.name,
    required this.scope,
    this.description = '',
  });

  final String id;
  final String name;
  final String scope;
  final String description;

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
    id: (json['id'] ?? '').toString(),
    name: (json['name_en'] ?? json['name'] ?? '').toString(),
    scope: (json['scope'] ?? 'tenant').toString(),
    description: (json['description_en'] ?? json['description'] ?? '').toString(),
  );

  RoleEntity toEntity() => RoleEntity(
    id: id,
    name: name,
    scope: scope,
    description: description,
  );
}
