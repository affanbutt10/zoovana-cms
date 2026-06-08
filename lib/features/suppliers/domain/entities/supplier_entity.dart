/// Entity representing a supplier in the system.
///
/// This is a domain-level entity that represents a supplier with all its
/// properties. It's immutable and contains only business logic data.
class SupplierEntity {
  final String id;
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupplierEntity({
    required this.id,
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          contactPerson == other.contactPerson &&
          email == other.email &&
          phone == other.phone &&
          address == other.address &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      contactPerson.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      notes.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'SupplierEntity(id: $id, name: $name, contactPerson: $contactPerson, '
        'email: $email, phone: $phone, address: $address, notes: $notes, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
