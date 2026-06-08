import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract contract for secure token storage.
/// Auth tokens MUST be stored via this service — never via [LocalStorageService].
abstract class SecureStorageService {
  // ---------------------------------------------------------------------------
  // Legacy single-token API (kept for backward compatibility)
  // ---------------------------------------------------------------------------

  Future<void> writeToken(String token);
  Future<String?> readToken();
  Future<void> deleteToken();

  // ---------------------------------------------------------------------------
  // Dual-token API (access + refresh)
  // ---------------------------------------------------------------------------

  /// Reads the stored access token. Returns `null` if not present.
  Future<String?> readAccessToken();

  /// Persists [token] as the access token under key `access_token`.
  Future<void> writeAccessToken(String token);

  /// Reads the stored refresh token. Returns `null` if not present.
  Future<String?> readRefreshToken();

  /// Persists [token] as the refresh token under key `refresh_token`.
  Future<void> writeRefreshToken(String token);

  /// Deletes both `access_token` and `refresh_token` from secure storage.
  Future<void> deleteAllTokens();
}

/// Concrete implementation backed by [FlutterSecureStorage].
class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // Legacy key — used by the old single-token API.
  static const _legacyTokenKey = 'auth_token';

  // Keys required by Requirements 4.1 and 4.2.
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  // ---------------------------------------------------------------------------
  // Legacy single-token API
  // ---------------------------------------------------------------------------

  @override
  Future<void> writeToken(String token) async {
    await _storage.write(key: _legacyTokenKey, value: token);
  }

  @override
  Future<String?> readToken() async {
    return _storage.read(key: _legacyTokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _legacyTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Dual-token API
  // ---------------------------------------------------------------------------

  @override
  Future<String?> readAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> writeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> readRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> writeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> deleteAllTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
