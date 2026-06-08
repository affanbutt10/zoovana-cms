import '../../domain/entities/business_entity.dart';

/// Data-layer model for a business, parsed from the Shop Service JSON response.
///
/// Use [fromJson] to deserialise the API payload and [toEntity] to convert to
/// the domain [BusinessEntity].
class BusinessModel {
  const BusinessModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.tenantId,
    required this.status,
    required this.createdAt,
  });

  /// Deserialises a business from the Shop Service JSON payload.
  ///
  /// Expected keys: `id`, `name`, `owner_id`, `tenant_id`, `status`,
  /// `created_at` (ISO-8601 string).
  factory BusinessModel.fromJson(Map<String, dynamic> json) => BusinessModel(
    id: json['id'] as String,
    name: json['name'] as String,
    ownerId: json['owner_id'] as String,
    tenantId: json['tenant_id'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final String name;
  final String ownerId;
  final String tenantId;
  final String status;
  final DateTime createdAt;

  /// Converts this model to the domain [BusinessEntity].
  BusinessEntity toEntity() => BusinessEntity(
    id: id,
    name: name,
    ownerId: ownerId,
    tenantId: tenantId,
    status: status,
    createdAt: createdAt,
  );
}
