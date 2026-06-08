import 'branch_entity.dart';

/// Domain-layer representation of a business together with its branches.
///
/// Produced by [BusinessWithBranchesModel.toEntity()] and consumed by
/// [ShopInitUseCase] and the shop presentation layer.
class BusinessWithBranchesEntity {
  const BusinessWithBranchesEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.tenantId,
    required this.status,
    required this.createdAt,
    required this.branches,
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

  /// All branches associated with this business.
  final List<BranchEntity> branches;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessWithBranchesEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          ownerId == other.ownerId &&
          tenantId == other.tenantId &&
          status == other.status &&
          createdAt == other.createdAt &&
          branches == other.branches;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      ownerId.hashCode ^
      tenantId.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      branches.hashCode;

  @override
  String toString() =>
      'BusinessWithBranchesEntity(id: $id, name: $name, ownerId: $ownerId, '
      'tenantId: $tenantId, status: $status, createdAt: $createdAt, '
      'branches: $branches)';
}
