/// Domain-layer entity for a branch.
class BranchEntity {
  const BranchEntity({
    required this.id,
    required this.businessId,
    required this.tenantId,
    required this.nameEn,
    required this.nameAr,
    required this.slug,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.contactEmail,
    required this.contactPhone,
    required this.status,
    required this.createdAt,
    this.address,
  });

  final String id;
  final String businessId;
  final String tenantId;
  final String nameEn;
  final String nameAr;
  final String slug;
  final String descriptionEn;
  final String descriptionAr;
  final String contactEmail;
  final String contactPhone;
  final String status;
  final String createdAt;
  final BranchAddressEntity? address;

  bool get isActive => status == 'active';

  /// Formatted creation date: DD/MM/YYYY
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }
}

class BranchAddressEntity {
  const BranchAddressEntity({
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
  });

  final String street;
  final String city;
  final String country;
  final String postalCode;

  String get displayAddress {
    final parts = [street, city, country].where((s) => s.isNotEmpty).toList();
    return parts.join(', ');
  }
}
