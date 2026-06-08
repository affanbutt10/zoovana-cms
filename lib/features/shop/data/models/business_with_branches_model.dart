import '../../domain/entities/business_with_branches_entity.dart';
import 'branch_model.dart';

/// Data-layer model for a business with its branches, parsed from the Shop
/// Service JSON response.
///
/// Use [fromJson] to deserialise the API payload and [toEntity] to convert to
/// the domain [BusinessWithBranchesEntity].
class BusinessWithBranchesModel {
  const BusinessWithBranchesModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.tenantId,
    required this.status,
    required this.createdAt,
    required this.branches,
  });

  /// Deserialises a business-with-branches from the Shop Service JSON payload.
  ///
  /// Supports both the real API shape (name_en, owner_id, etc.) and the
  /// mock/legacy shape. All casts are null-safe.
  factory BusinessWithBranchesModel.fromJson(Map<String, dynamic> json) {
    // name: real API may use name_en or name
    final name = (json['name_en'] ?? json['name'] ?? '').toString();
    // owner_id: real API uses owner_id
    final ownerId = (json['owner_id'] ?? json['ownerId'] ?? '').toString();
    // tenant_id
    final tenantId = (json['tenant_id'] ?? json['tenantId'] ?? '').toString();
    // created_at — parse safely
    DateTime createdAt;
    try {
      createdAt = DateTime.parse((json['created_at'] ?? '').toString());
    } catch (_) {
      createdAt = DateTime.now();
    }
    // branches — may be absent or empty
    final rawBranches = json['branches'];
    final List<BranchModel> branches = rawBranches is List
        ? rawBranches
            .map((b) => BranchModel.fromJson(b as Map<String, dynamic>))
            .toList()
        : [];

    return BusinessWithBranchesModel(
      id: (json['id'] ?? '').toString(),
      name: name,
      ownerId: ownerId,
      tenantId: tenantId,
      status: (json['status'] ?? 'active').toString(),
      createdAt: createdAt,
      branches: branches,
    );
  }

  final String id;
  final String name;
  final String ownerId;
  final String tenantId;
  final String status;
  final DateTime createdAt;
  final List<BranchModel> branches;

  /// Converts this model to the domain [BusinessWithBranchesEntity].
  BusinessWithBranchesEntity toEntity() => BusinessWithBranchesEntity(
    id: id,
    name: name,
    ownerId: ownerId,
    tenantId: tenantId,
    status: status,
    createdAt: createdAt,
    branches: branches.map((b) => b.toEntity()).toList(),
  );
}
