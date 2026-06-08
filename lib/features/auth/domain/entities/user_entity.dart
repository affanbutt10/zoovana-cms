import 'role_entity.dart';

/// Domain-layer representation of an authenticated user.
///
/// This entity is independent of any API response shape. It is produced by
/// [UserModel.toEntity()] and consumed by the presentation layer.
///
/// Supports role-based UI switching via [activeRole] — when a user has
/// multiple roles, the UI renders based on the active role selection.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isSuperuser,
    required this.isEmailVerified,
    required this.roles,
    required this.defaultTenantId,
    this.activeRole,
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

  /// List of roles assigned to the user.
  final List<RoleEntity> roles;

  /// The default tenant ID associated with the user.
  final String defaultTenantId;

  /// The currently active role for UI rendering.
  /// When null, defaults to the first role in [roles] or determined by UI logic.
  final RoleEntity? activeRole;

  /// Creates a copy of this user with the specified fields replaced.
  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? isSuperuser,
    bool? isEmailVerified,
    List<RoleEntity>? roles,
    String? defaultTenantId,
    RoleEntity? activeRole,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      roles: roles ?? this.roles,
      defaultTenantId: defaultTenantId ?? this.defaultTenantId,
      activeRole: activeRole ?? this.activeRole,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          isSuperuser == other.isSuperuser &&
          isEmailVerified == other.isEmailVerified &&
          defaultTenantId == other.defaultTenantId &&
          activeRole == other.activeRole;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      isSuperuser.hashCode ^
      isEmailVerified.hashCode ^
      defaultTenantId.hashCode ^
      activeRole.hashCode;

  @override
  String toString() =>
      'UserEntity(id: $id, email: $email, fullName: $fullName, '
      'isSuperuser: $isSuperuser, isEmailVerified: $isEmailVerified, '
      'roles: $roles, defaultTenantId: $defaultTenantId, activeRole: $activeRole)';
}
