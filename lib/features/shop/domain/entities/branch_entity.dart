/// Domain-layer representation of a branch belonging to a business.
///
/// Produced by [BranchModel.toEntity()] and consumed by the presentation
/// layer and use cases.
class BranchEntity {
  const BranchEntity({
    required this.id,
    required this.businessId,
    required this.name,
    this.address,
    required this.isActive,
    required this.createdAt,
  });

  /// Unique identifier for the branch.
  final String id;

  /// ID of the business this branch belongs to.
  final String businessId;

  /// Display name of the branch.
  final String name;

  /// Physical address of the branch. May be null if not provided.
  final String? address;

  /// Whether this branch is currently active.
  final bool isActive;

  /// Timestamp when the branch was created.
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          businessId == other.businessId &&
          name == other.name &&
          address == other.address &&
          isActive == other.isActive &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      businessId.hashCode ^
      name.hashCode ^
      address.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'BranchEntity(id: $id, businessId: $businessId, name: $name, '
      'address: $address, isActive: $isActive, createdAt: $createdAt)';
}
