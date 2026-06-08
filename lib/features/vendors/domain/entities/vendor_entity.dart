/// Domain entity representing a vendor in the Zoovana CMS.
///
/// Lives in the domain layer and is independent of API response structure.
/// All fields are immutable and non-nullable (except where the domain
/// explicitly allows absence).
class VendorEntity {
  const VendorEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  /// Unique identifier for the vendor.
  final String id;

  /// Display name of the vendor.
  final String name;

  /// Contact email address of the vendor.
  final String email;

  /// Current status of the vendor account (e.g. "active", "inactive").
  final String status;

  /// Timestamp when the vendor account was created.
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      status.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'VendorEntity(id: $id, name: $name, email: $email, '
      'status: $status, createdAt: $createdAt)';
}
