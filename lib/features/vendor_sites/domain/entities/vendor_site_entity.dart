/// Domain entity representing a vendor site (branch/location) in the Zoovana CMS.
///
/// Lives in the domain layer and is independent of API response structure.
/// All fields are immutable and non-nullable.
class VendorSiteEntity {
  const VendorSiteEntity({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.address,
    required this.status,
  });

  /// Unique identifier for the vendor site.
  final String id;

  /// Identifier of the vendor this site belongs to.
  final String vendorId;

  /// Display name of the vendor site.
  final String name;

  /// Physical address of the vendor site.
  final String address;

  /// Current status of the vendor site (e.g. "active", "inactive").
  final String status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorSiteEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vendorId == other.vendorId &&
          name == other.name &&
          address == other.address &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      vendorId.hashCode ^
      name.hashCode ^
      address.hashCode ^
      status.hashCode;

  @override
  String toString() =>
      'VendorSiteEntity(id: $id, vendorId: $vendorId, name: $name, '
      'address: $address, status: $status)';
}
