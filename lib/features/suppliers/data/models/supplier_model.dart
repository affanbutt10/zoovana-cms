import '../../domain/entities/supplier_entity.dart';

class SupplierModel {
  final String id;
  final String name;       // from name_en
  final String? nameAr;    // from name_ar
  final String? contactPerson;  // from contact_name
  final String? email;     // from contact_email
  final String? phone;     // from contact_phone
  final String? address;   // from address.street
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupplierModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    // address is an object: { "street": "..." }
    final addressObj = json['address'];
    String? addressStr;
    if (addressObj is Map<String, dynamic>) {
      addressStr = addressObj['street']?.toString();
    } else if (addressObj is String) {
      addressStr = addressObj;
    }

    return SupplierModel(
      id: json['id']?.toString() ?? '',
      name: json['name_en']?.toString() ?? json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      contactPerson: json['contact_name']?.toString(),
      email: json['contact_email']?.toString(),
      phone: json['contact_phone']?.toString(),
      address: addressStr,
      notes: json['notes']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id,
      name: name,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      address: address,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Request model for creating a new supplier.
class CreateSupplierRequest {
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;

  const CreateSupplierRequest({
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_en': name,
      if (contactPerson != null && contactPerson!.isNotEmpty)
        'contact_name': contactPerson,
      if (email != null && email!.isNotEmpty) 'contact_email': email,
      if (phone != null && phone!.isNotEmpty) 'contact_phone': phone,
      if (address != null && address!.isNotEmpty)
        'address': {'street': address},
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

/// Response model for paginated supplier list.
/// API shape: { success, message, data: [...], meta: { total, page, page_size } }
class SupplierListResponse {
  final List<SupplierModel> suppliers;
  final int total;
  final int page;
  final int pageSize;

  const SupplierListResponse({
    required this.suppliers,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory SupplierListResponse.fromJson(Map<String, dynamic> json) {
    // Unwrap envelope: { success, data: [...], meta: {...} }
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return SupplierListResponse(
      suppliers: data
          .map((item) => SupplierModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int? ?? data.length,
      page: meta['page'] as int? ?? 1,
      pageSize: meta['page_size'] as int? ?? 10,
    );
  }
}
