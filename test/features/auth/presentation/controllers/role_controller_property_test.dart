// Feature: zoovana-auth-rbac-shop-init, Property 11: Role persistence round-trip
//
// Validates: Requirements 10.4
//
// Property 11: Role persistence round-trip — for any RoleEntity, calling
// setSelectedRole persists the role's id to LocalStorageService under
// zoovana_role_storage, and reading that key returns the same id.

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:glados/glados.dart';
import 'package:zoovana_cms/core/storage/local_storage_service.dart';
import 'package:zoovana_cms/features/auth/domain/entities/role_entity.dart';
import 'package:zoovana_cms/features/auth/presentation/controllers/role_controller.dart';

// ---------------------------------------------------------------------------
// Custom generator: non-empty strings
// (glados 1.1.7 does not expose any.nonEmptyString out of the box; we define
// it as an extension on Any — same pattern used in role_model_property_test.dart)
// ---------------------------------------------------------------------------

extension NonEmptyStringAny on Any {
  Generator<String> get nonEmptyString => simple(
        generate: (random, size) {
          final length = 1 + random.nextInt(size < 1 ? 1 : size);
          const chars =
              'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
              '._-+/=';
          return List.generate(
            length,
            (_) => chars[random.nextInt(chars.length)],
          ).join();
        },
        shrink: (s) {
          if (s.length <= 1) return [];
          return [s.substring(0, s.length - 1)];
        },
      );
}

// ---------------------------------------------------------------------------
// In-memory fake LocalStorageService
// (shared_preferences requires platform channels; this fake stores values in
// a plain Dart map — same pattern as the InMemorySecureStorageService used in
// auth_controller_property_test.dart)
// ---------------------------------------------------------------------------

class InMemoryLocalStorageService implements LocalStorageService {
  final Map<String, String> _strings = {};
  final Map<String, bool> _bools = {};

  @override
  Future<String?> getString(String key) async => _strings[key];

  @override
  Future<void> setString(String key, String value) async {
    _strings[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => _bools[key];

  @override
  Future<void> setBool(String key, bool value) async {
    _bools[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _strings.remove(key);
    _bools.remove(key);
  }

  @override
  Future<void> clearSession() async {
    for (final key in [
      LocalStorageKeys.userId,
      LocalStorageKeys.fullName,
      LocalStorageKeys.email,
      LocalStorageKeys.isSuperuser,
      LocalStorageKeys.defaultTenantId,
      LocalStorageKeys.zoovanaRoleStorage,
      LocalStorageKeys.activeBranchId,
    ]) {
      _strings.remove(key);
      _bools.remove(key);
    }
  }
}

// ---------------------------------------------------------------------------
// Helper: build a fresh RoleController with a clean in-memory storage
// ---------------------------------------------------------------------------

RoleController _buildController(InMemoryLocalStorageService localStorage) {
  return RoleController(localStorage: localStorage);
}

// ---------------------------------------------------------------------------
// Property 11 tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    // Clean up any registered GetX controllers between tests.
    Get.reset();
  });

  group('Property 11 — Role persistence round-trip', () {
    // -----------------------------------------------------------------------
    // 11a: setSelectedRole persists role.id under zoovana_role_storage
    // -----------------------------------------------------------------------
    Glados3<String, String, String>(
      any.nonEmptyString,
      any.nonEmptyString,
      any.nonEmptyString,
    ).test(
      'setSelectedRole persists role.id to LocalStorageService under zoovana_role_storage',
      (id, name, scope) async {
        final localStorage = InMemoryLocalStorageService();
        final controller = _buildController(localStorage);

        final role = RoleEntity(id: id, name: name, scope: scope);
        await controller.setSelectedRole(role);

        final persisted = await localStorage.getString(
          LocalStorageKeys.zoovanaRoleStorage,
        );

        expect(
          persisted,
          equals(id),
          reason:
              'setSelectedRole(role) must persist role.id="$id" under '
              '"${LocalStorageKeys.zoovanaRoleStorage}", got "$persisted"',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 11b: reading zoovana_role_storage returns the same id that was set
    // -----------------------------------------------------------------------
    Glados3<String, String, String>(
      any.nonEmptyString,
      any.nonEmptyString,
      any.nonEmptyString,
    ).test(
      'reading zoovana_role_storage after setSelectedRole returns the same id',
      (id, name, scope) async {
        final localStorage = InMemoryLocalStorageService();
        final controller = _buildController(localStorage);

        final role = RoleEntity(id: id, name: name, scope: scope);
        await controller.setSelectedRole(role);

        // Read back via the service directly (simulates what the app does on
        // restart to restore the selected role).
        final readBack = await localStorage.getString(
          LocalStorageKeys.zoovanaRoleStorage,
        );

        expect(
          readBack,
          equals(role.id),
          reason:
              'Reading "${LocalStorageKeys.zoovanaRoleStorage}" must return '
              'the same id that was persisted (expected "${role.id}", got "$readBack")',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 11c: clearSelectedRole removes zoovana_role_storage (returns null)
    // -----------------------------------------------------------------------
    Glados3<String, String, String>(
      any.nonEmptyString,
      any.nonEmptyString,
      any.nonEmptyString,
    ).test(
      'clearSelectedRole removes zoovana_role_storage so reading it returns null',
      (id, name, scope) async {
        final localStorage = InMemoryLocalStorageService();
        final controller = _buildController(localStorage);

        // First persist a role.
        final role = RoleEntity(id: id, name: name, scope: scope);
        await controller.setSelectedRole(role);

        // Confirm it was persisted.
        final beforeClear = await localStorage.getString(
          LocalStorageKeys.zoovanaRoleStorage,
        );
        expect(beforeClear, equals(id));

        // Now clear.
        await controller.clearSelectedRole();

        final afterClear = await localStorage.getString(
          LocalStorageKeys.zoovanaRoleStorage,
        );

        expect(
          afterClear,
          isNull,
          reason:
              'After clearSelectedRole(), "${LocalStorageKeys.zoovanaRoleStorage}" '
              'must be null, but got "$afterClear"',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 11d: round-trip — set then read via controller getter matches original id
    // -----------------------------------------------------------------------
    Glados3<String, String, String>(
      any.nonEmptyString,
      any.nonEmptyString,
      any.nonEmptyString,
    ).test(
      'selectedRole.value.id matches the id of the role passed to setSelectedRole',
      (id, name, scope) async {
        final localStorage = InMemoryLocalStorageService();
        final controller = _buildController(localStorage);

        final role = RoleEntity(id: id, name: name, scope: scope);
        await controller.setSelectedRole(role);

        expect(
          controller.selectedRole.value?.id,
          equals(id),
          reason:
              'controller.selectedRole.value.id must equal the id passed to '
              'setSelectedRole (expected "$id", got "${controller.selectedRole.value?.id}")',
        );
      },
    );
  });
}
