import '../../domain/entities/user_entity.dart';
import 'role_model.dart';

/// Data-layer model that parses a user object from the API response.
///
/// Constructed via [UserModel.fromJson] from a raw JSON map.
/// Call [toEntity] to obtain the domain-layer [UserEntity].
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isSuperuser,
    required this.isEmailVerified,
    required this.roles,
    required this.defaultTenantId,
  });

  /// Unique identifier for the user.
  final String id;

  /// Email address of the user.
  final String email;

  /// Full display name of the user.
  final String fullName;

  /// Whether the user has superuser (admin) privileges.
  final bool isSuperuser;

  /// Whether the user's email address has been verified.
  final bool isEmailVerified;

  /// List of role models assigned to the user.
  final List<RoleModel> roles;

  /// The default tenant ID associated with the user.
  final String defaultTenantId;

  /// Parses a [UserModel] from a JSON map.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": "user-uuid",
  ///   "email": "user@example.com",
  ///   "full_name": "Jane Doe",
  ///   "is_superuser": false,
  ///   "is_email_verified": true,
  ///   "roles": [...],
  ///   "default_tenant_id": "tenant-uuid"
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['id'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    fullName: (json['full_name'] ?? '').toString(),
    isSuperuser: (json['is_superuser'] as bool?) ?? false,
    isEmailVerified: (json['is_email_verified'] as bool?) ?? false,
    // Login responses may contain full role objects, while the profile API
    // returns role names such as "shop_owner" and "shelter". Support both.
    roles: ((json['roles'] as List<dynamic>?) ?? []).map((role) {
      if (role is Map<String, dynamic>) {
        return RoleModel.fromJson(role);
      }
      final name = role.toString();
      return RoleModel(
        // Profile role strings do not include UUIDs. The stable name is
        // sufficient for local selection, persistence, and dashboard routing.
        id: name,
        name: name,
        scope: 'tenant',
      );
    }).toList(),
    defaultTenantId: (json['default_tenant_id'] ?? '').toString(),
  );

  /// Converts this data-layer model to the domain-layer [UserEntity].
  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    fullName: fullName,
    isSuperuser: isSuperuser,
    isEmailVerified: isEmailVerified,
    roles: roles.map((r) => r.toEntity()).toList(),
    defaultTenantId: defaultTenantId,
  );
}
