import '../../domain/entities/branch_entity.dart';

/// Data-layer model that parses a branch API response.
class BranchModel {
  const BranchModel({
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
  final BranchAddressModel? address;

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    final addr = json['address'];
    return BranchModel(
      id: (json['id'] ?? '').toString(),
      businessId: (json['business_id'] ?? '').toString(),
      tenantId: (json['tenant_id'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      descriptionEn: (json['description_en'] ?? '').toString(),
      descriptionAr: (json['description_ar'] ?? '').toString(),
      contactEmail: (json['contact_email'] ?? '').toString(),
      contactPhone: (json['contact_phone'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      address: addr is Map<String, dynamic>
          ? BranchAddressModel.fromJson(addr)
          : null,
    );
  }

  BranchEntity toEntity() => BranchEntity(
        id: id,
        businessId: businessId,
        tenantId: tenantId,
        nameEn: nameEn,
        nameAr: nameAr,
        slug: slug,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        status: status,
        createdAt: createdAt,
        address: address?.toEntity(),
      );
}

class BranchAddressModel {
  const BranchAddressModel({
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
  });

  final String street;
  final String city;
  final String country;
  final String postalCode;

  factory BranchAddressModel.fromJson(Map<String, dynamic> json) =>
      BranchAddressModel(
        street: (json['street'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        country: (json['country'] ?? '').toString(),
        postalCode: (json['postal_code'] ?? '').toString(),
      );

  BranchAddressEntity toEntity() => BranchAddressEntity(
        street: street,
        city: city,
        country: country,
        postalCode: postalCode,
      );
}

/// Pagination meta from the API response.
class BranchPageMeta {
  const BranchPageMeta({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  factory BranchPageMeta.fromJson(Map<String, dynamic> json) => BranchPageMeta(
        total: (json['total'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
        hasNext: (json['has_next'] as bool?) ?? false,
        hasPrev: (json['has_prev'] as bool?) ?? false,
      );
}

class BranchPageResult {
  const BranchPageResult({required this.branches, required this.meta});
  final List<BranchModel> branches;
  final BranchPageMeta meta;
}
