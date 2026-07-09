import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/error/result.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// GetX controller that manages the user's available roles and the currently
/// selected role for RBAC navigation guards.
///
/// Responsibilities:
/// - Holds the list of roles returned from the login response.
/// - Persists the selected role's id to [LocalStorageService] under the key
///   [LocalStorageKeys.zoovanaRoleStorage] so it survives app restarts.
/// - Restores the selected role on [onInit] if a persisted id is found and
///   the roles list is already populated.
///
/// Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6
class RoleController extends GetxController {
  RoleController({required LocalStorageService localStorage})
    : _localStorage = localStorage;

  final LocalStorageService _localStorage;

  /// All roles available on the platform (fetched from the API on startup).
  /// Used by the register screen and role-select screen.
  final RxList<RoleEntity> allRoles = <RoleEntity>[].obs;

  /// The full list of roles assigned to the authenticated user.
  final RxList<RoleEntity> roles = <RoleEntity>[].obs;

  /// The role the user has actively selected.
  final Rxn<RoleEntity> selectedRole = Rxn<RoleEntity>();

  /// Whether the all-roles fetch is in progress.
  final RxBool allRolesLoading = false.obs;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> onInit() async {
    super.onInit();
    await _restoreSelectedRole();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches all available platform roles from the backend.
  /// Called on app startup so the register screen has data immediately.
  Future<void> fetchAllRoles() async {
    allRolesLoading.value = true;
    try {
      final repo = GetIt.instance<AuthRepository>();
      final result = await repo.getRoles();
      switch (result) {
        case Success(:final data):
          allRoles.assignAll(data);
          debugPrint('[Roles] Fetched ${data.length} platform roles');
        case Failure(:final error):
          debugPrint(
            '[Roles] Failed to fetch platform roles: ${error.message}',
          );
      }
    } catch (e) {
      debugPrint('[Roles] fetchAllRoles error: $e');
    } finally {
      allRolesLoading.value = false;
    }
  }

  /// Replaces the current roles list with [newRoles].
  ///
  /// If [newRoles] contains exactly one role, [setSelectedRole] is called
  /// automatically so the user is not prompted to choose.
  void setRoles(List<RoleEntity> newRoles) {
    roles.assignAll(newRoles);
    if (newRoles.length == 1) {
      setSelectedRole(newRoles.first);
    } else if (newRoles.isNotEmpty &&
        !newRoles.any((role) => role.id == selectedRole.value?.id)) {
      // Keep a valid active role until the user explicitly chooses another.
      setSelectedRole(newRoles.first);
    }
    update();
  }

  /// Sets [role] as the active role and persists its id, name, and scope to local storage.
  Future<void> setSelectedRole(RoleEntity role) async {
    selectedRole.value = role;
    update();
    await Future.wait([
      _localStorage.setString(LocalStorageKeys.zoovanaRoleStorage, role.id),
      _localStorage.setString(LocalStorageKeys.zoovanaRoleName, role.name),
      _localStorage.setString(LocalStorageKeys.zoovanaRoleScope, role.scope),
    ]);
  }

  /// Clears the active role and removes the persisted id from local storage.
  Future<void> clearSelectedRole() async {
    selectedRole.value = null;
    await _localStorage.remove(LocalStorageKeys.zoovanaRoleStorage);
  }

  /// Returns the id of the currently selected role, or `null` if none.
  String? getSelectedRoleId() => selectedRole.value?.id;

  /// Returns the name of the currently selected role, or `null` if none.
  String? getSelectedRoleName() => selectedRole.value?.name;

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Reads the persisted role from [LocalStorageService] and restores it.
  ///
  /// On app restart the roles list is empty, so we rebuild the [RoleEntity]
  /// directly from the stored id, name, and scope.
  Future<void> _restoreSelectedRole() async {
    final persistedId = await _localStorage.getString(
      LocalStorageKeys.zoovanaRoleStorage,
    );
    if (persistedId == null) return;

    // Try to find in the current roles list first
    if (roles.isNotEmpty) {
      try {
        final match = roles.firstWhere((r) => r.id == persistedId);
        selectedRole.value = match;
        return;
      } catch (_) {}
    }

    // Roles list is empty (app restart) — rebuild from stored name + scope
    final name = await _localStorage.getString(
      LocalStorageKeys.zoovanaRoleName,
    );
    final scope = await _localStorage.getString(
      LocalStorageKeys.zoovanaRoleScope,
    );
    if (name != null && name.isNotEmpty) {
      selectedRole.value = RoleEntity(
        id: persistedId,
        name: name,
        scope: scope ?? 'tenant',
      );
    }
  }
}
