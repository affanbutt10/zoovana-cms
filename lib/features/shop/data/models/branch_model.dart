import '../../domain/entities/branch_entity.dart';

/// Data-layer model for a branch, parsed from the Shop Service JSON response.
///
/// Use [fromJson] to deserialise the API payload and [toEntity] to convert to
/// the domain [BranchEntity].
class BranchModel {
  const BranchModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.address,
    required this.isActive,
    required this.createdAt,
  });

  /// Deserialises a branch from the Shop Service JSON payload.
  ///
  /// Supports both real API shape (name_en, status) and mock shape (name, is_active).
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    // name: real API uses name_en
    final name = (json['name_en'] ?? json['name'] ?? '').toString();
    // is_active: real API uses status == 'active'
    final bool isActive;
    if (json.containsKey('is_active')) {
      isActive = (json['is_active'] as bool?) ?? true;
    } else {
      isActive = (json['status'] ?? 'active').toString() == 'active';
    }
    // created_at — parse safely
    DateTime createdAt;
    try {
      createdAt = DateTime.parse((json['created_at'] ?? '').toString());
    } catch (_) {
      createdAt = DateTime.now();
    }
    // address — may be a string or a nested object
    String? address;
    final rawAddr = json['address'];
    if (rawAddr is String) {
      address = rawAddr.isEmpty ? null : rawAddr;
    } else if (rawAddr is Map) {
      final parts = [
        rawAddr['street'],
        rawAddr['city'],
        rawAddr['country'],
      ].where((v) => v != null && v.toString().isNotEmpty).toList();
      address = parts.isEmpty ? null : parts.join(', ');
    }

    return BranchModel(
      id: (json['id'] ?? '').toString(),
      businessId: (json['business_id'] ?? json['businessId'] ?? '').toString(),
      name: name,
      address: address,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  final String id;
  final String businessId;
  final String name;
  final String? address;
  final bool isActive;
  final DateTime createdAt;

  /// Converts this model to the domain [BranchEntity].
  BranchEntity toEntity() => BranchEntity(
    id: id,
    businessId: businessId,
    name: name,
    address: address,
    isActive: isActive,
    createdAt: createdAt,
  );
}
