// Feature: zoovana-auth-rbac-shop-init, Property 4: Token storage round-trip
//
// Validates: Requirements 4.1, 4.2, 9.2
//
// Property 4: Token storage round-trip — for any non-empty token string,
// writeAccessToken then readAccessToken returns the original string
// (and same for refresh token).

import 'package:glados/glados.dart';
import 'package:zoovana_cms/core/storage/secure_storage_service.dart';

// ---------------------------------------------------------------------------
// In-memory fake implementation of SecureStorageService
// (flutter_secure_storage requires platform channels and cannot be used in
// unit tests; this fake stores tokens in a plain Dart map)
// ---------------------------------------------------------------------------

class InMemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _store = {};

  static const _legacyTokenKey = 'auth_token';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // ---------------------------------------------------------------------------
  // Legacy single-token API
  // ---------------------------------------------------------------------------

  @override
  Future<void> writeToken(String token) async {
    _store[_legacyTokenKey] = token;
  }

  @override
  Future<String?> readToken() async {
    return _store[_legacyTokenKey];
  }

  @override
  Future<void> deleteToken() async {
    _store.remove(_legacyTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Dual-token API
  // ---------------------------------------------------------------------------

  @override
  Future<String?> readAccessToken() async {
    return _store[_accessTokenKey];
  }

  @override
  Future<void> writeAccessToken(String token) async {
    _store[_accessTokenKey] = token;
  }

  @override
  Future<String?> readRefreshToken() async {
    return _store[_refreshTokenKey];
  }

  @override
  Future<void> writeRefreshToken(String token) async {
    _store[_refreshTokenKey] = token;
  }

  @override
  Future<void> deleteAllTokens() async {
    _store.remove(_accessTokenKey);
    _store.remove(_refreshTokenKey);
  }
}

// ---------------------------------------------------------------------------
// Custom generator: non-empty strings
// ---------------------------------------------------------------------------

extension NonEmptyStringAny on Any {
  Generator<String> get nonEmptyString => simple(
        generate: (random, size) {
          // Generate a string of length 1..max(1, size)
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
          // Shrink by removing one character at a time, keeping non-empty
          if (s.length <= 1) return [];
          return [s.substring(0, s.length - 1)];
        },
      );
}

void main() {
  // ---------------------------------------------------------------------------
  // Property 4: Token storage round-trip
  // ---------------------------------------------------------------------------

  group('Property 4 — Token storage round-trip', () {
    // -------------------------------------------------------------------------
    // 4a: access token round-trip
    // -------------------------------------------------------------------------
    Glados(any.nonEmptyString).test(
      'writeAccessToken then readAccessToken returns the original token',
      (token) async {
        final storage = InMemorySecureStorageService();

        await storage.writeAccessToken(token);
        final retrieved = await storage.readAccessToken();

        expect(
          retrieved,
          equals(token),
          reason:
              'readAccessToken() must return the exact token passed to writeAccessToken()',
        );
      },
    );

    // -------------------------------------------------------------------------
    // 4b: refresh token round-trip
    // -------------------------------------------------------------------------
    Glados(any.nonEmptyString).test(
      'writeRefreshToken then readRefreshToken returns the original token',
      (token) async {
        final storage = InMemorySecureStorageService();

        await storage.writeRefreshToken(token);
        final retrieved = await storage.readRefreshToken();

        expect(
          retrieved,
          equals(token),
          reason:
              'readRefreshToken() must return the exact token passed to writeRefreshToken()',
        );
      },
    );

    // -------------------------------------------------------------------------
    // 4c: deleteAllTokens clears both tokens
    // -------------------------------------------------------------------------
    Glados2(any.nonEmptyString, any.nonEmptyString).test(
      'deleteAllTokens causes both readAccessToken and readRefreshToken to return null',
      (accessToken, refreshToken) async {
        final storage = InMemorySecureStorageService();

        await storage.writeAccessToken(accessToken);
        await storage.writeRefreshToken(refreshToken);

        await storage.deleteAllTokens();

        final retrievedAccess = await storage.readAccessToken();
        final retrievedRefresh = await storage.readRefreshToken();

        expect(
          retrievedAccess,
          isNull,
          reason: 'readAccessToken() must return null after deleteAllTokens()',
        );
        expect(
          retrievedRefresh,
          isNull,
          reason: 'readRefreshToken() must return null after deleteAllTokens()',
        );
      },
    );

    // -------------------------------------------------------------------------
    // 4d: access and refresh tokens are stored independently
    // -------------------------------------------------------------------------
    Glados2(any.nonEmptyString, any.nonEmptyString).test(
      'access token and refresh token are stored independently',
      (accessToken, refreshToken) async {
        final storage = InMemorySecureStorageService();

        await storage.writeAccessToken(accessToken);
        await storage.writeRefreshToken(refreshToken);

        final retrievedAccess = await storage.readAccessToken();
        final retrievedRefresh = await storage.readRefreshToken();

        expect(
          retrievedAccess,
          equals(accessToken),
          reason: 'readAccessToken() must return the access token',
        );
        expect(
          retrievedRefresh,
          equals(refreshToken),
          reason: 'readRefreshToken() must return the refresh token',
        );
      },
    );
  });
}
