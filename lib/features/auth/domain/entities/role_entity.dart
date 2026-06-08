/// Domain-layer representation of a user role.
///
/// Produced by [RoleModel.toEntity()] and consumed by the presentation layer
/// for RBAC navigation guards.
class RoleEntity {
  const RoleEntity({
    required this.id,
    required this.name,
    required this.scope,
    this.description = '',
  });

  final String id;
  final String name;
  final String scope;
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          scope == other.scope;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ scope.hashCode;

  @override
  String toString() => 'RoleEntity(id: $id, name: $name, scope: $scope)';
}
