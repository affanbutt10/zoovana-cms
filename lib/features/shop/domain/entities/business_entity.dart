/// Domain-layer representation of a business.
///
/// Produced by [BusinessModel.toEntity()] and consumed by the presentation
/// layer and use cases.
class BusinessEntity {
  const BusinessEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.tenantId,
    required this.status,
    required this.createdAt,
  });

  /// Unique identifier for the business.
  final String id;

  /// Display name of the business.
  final String name;

  /// ID of the user who owns this business.
  final String ownerId;

  /// Tenant this business belongs to.
  final String tenantId;

  /// Current status of the business (e.g. `active`, `inactive`).
  final String status;

  /// Timestamp when the business was created.
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ownerId == other.ownerId &&
          tenantId == other.tenantId &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      ownerId.hashCode ^
      tenantId.hashCode ^
      status.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'BusinessEntity(id: $id, name: $name, ownerId: $ownerId, '
      'tenantId: $tenantId, status: $status, createdAt: $createdAt)';
}
