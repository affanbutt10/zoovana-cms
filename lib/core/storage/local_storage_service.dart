import 'package:shared_preferences/shared_preferences.dart';

/// Abstract contract for non-sensitive local preference storage.
/// Auth tokens MUST NOT be stored via this service — use [SecureStorageService] instead.
abstract class LocalStorageService {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);

  /// Removes all session-related keys from local storage.
  /// Clears: user_id, full_name, email, is_superuser, default_tenant_id,
  /// zoovana_role_storage, active_branch_id.
  Future<void> clearSession();
}

/// Keys used for session data in local storage.
class LocalStorageKeys {
  LocalStorageKeys._();

  static const String userId = 'user_id';
  static const String fullName = 'full_name';
  static const String email = 'email';
  static const String isSuperuser = 'is_superuser';
  static const String isEmailVerified = 'is_email_verified';
  static const String defaultTenantId = 'default_tenant_id';
  static const String zoovanaRoleStorage = 'zoovana_role_storage';
  static const String zoovanaRoleName = 'zoovana_role_name';
  static const String zoovanaRoleScope = 'zoovana_role_scope';
  static const String activeBranchId = 'active_branch_id';
}

/// Concrete implementation backed by [SharedPreferences].
class LocalStorageServiceImpl implements LocalStorageService {
  LocalStorageServiceImpl({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  /// Lazily initialises [SharedPreferences] if not injected via constructor.
  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  @override
  Future<void> clearSession() async {
    final prefs = await _instance;
    await Future.wait([
      prefs.remove(LocalStorageKeys.userId),
      prefs.remove(LocalStorageKeys.fullName),
      prefs.remove(LocalStorageKeys.email),
      prefs.remove(LocalStorageKeys.isSuperuser),
      prefs.remove(LocalStorageKeys.isEmailVerified),
      prefs.remove(LocalStorageKeys.defaultTenantId),
      prefs.remove(LocalStorageKeys.zoovanaRoleStorage),
      prefs.remove(LocalStorageKeys.zoovanaRoleName),
      prefs.remove(LocalStorageKeys.zoovanaRoleScope),
      prefs.remove(LocalStorageKeys.activeBranchId),
    ]);
  }
}
