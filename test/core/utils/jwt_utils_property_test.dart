// Feature: zoovana-auth-rbac-shop-init, Property 10: Proactive token refresh threshold
//
// Validates: Requirements 9.1
//
// Property 10: Proactive token refresh threshold — for any JWT whose decoded
// `exp` is within 600 seconds of now, `JwtUtils.isTokenExpiringSoon` returns
// `true`; for any token with `exp` more than 600 seconds away, it returns
// `false`.

import 'dart:convert';

import 'package:glados/glados.dart';
import 'package:zoovana_cms/core/utils/jwt_utils.dart';

// ---------------------------------------------------------------------------
// Helper: build a minimal JWT with a given exp Unix timestamp.
//
// A real JWT has three base64url-encoded segments separated by dots:
//   header.payload.signature
//
// `isTokenExpiringSoon` only reads the payload segment and does not verify
// the signature, so we use a dummy signature value.
// ---------------------------------------------------------------------------

/// Encodes [bytes] using base64url without padding (as required by JWT spec).
String _base64UrlEncode(List<int> bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Builds a minimal JWT string whose payload contains `{"exp": <expTimestamp>}`.
String _buildJwt(int expTimestamp) {
  final header = _base64UrlEncode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload =
      _base64UrlEncode(utf8.encode('{"exp":$expTimestamp}'));
  const signature = 'dummy_signature';
  return '$header.$payload.$signature';
}

// ---------------------------------------------------------------------------
// Generators
// ---------------------------------------------------------------------------

extension JwtOffsetAny on Any {
  /// Generates a positive offset in seconds (1..599) — token expires within
  /// the 600-second threshold window (but has not yet expired).
  Generator<int> get soonPositiveOffset => simple(
        generate: (random, size) {
          // Range: 1 to 599 seconds from now (expiring soon, not yet expired)
          return 1 + random.nextInt(599);
        },
        shrink: (value) => value > 1 ? [value - 1] : [],
      );

  /// Generates a positive offset in seconds (601..3600) — token expires well
  /// beyond the 600-second threshold.
  Generator<int> get farFutureOffset => simple(
        generate: (random, size) {
          // Range: 601 to 3600 seconds from now (not expiring soon)
          return 601 + random.nextInt(3000);
        },
        shrink: (value) => value > 601 ? [value - 1] : [],
      );

  /// Generates a negative offset in seconds (1..3600) — token is already
  /// expired (exp is in the past).
  Generator<int> get pastOffset => simple(
        generate: (random, size) {
          // Range: 1 to 3600 seconds ago (already expired)
          return 1 + random.nextInt(3600);
        },
        shrink: (value) => value > 1 ? [value - 1] : [],
      );
}

// ---------------------------------------------------------------------------
// Property 10 tests
// ---------------------------------------------------------------------------

void main() {
  group('Property 10 — Proactive token refresh threshold', () {
    // -----------------------------------------------------------------------
    // Sub-property A: tokens expiring within 600 seconds → true
    //
    // For any exp in (now, now + 600], isTokenExpiringSoon returns true.
    // -----------------------------------------------------------------------
    Glados(any.soonPositiveOffset).test(
      'tokens expiring within 600 seconds of now return true',
      (offsetSeconds) {
        final nowSeconds =
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // exp is offsetSeconds seconds from now (1..599), within threshold
        final expTimestamp = nowSeconds + offsetSeconds;
        final token = _buildJwt(expTimestamp);

        expect(
          JwtUtils.isTokenExpiringSoon(token),
          isTrue,
          reason:
              'Token expiring in $offsetSeconds seconds (≤ 600) should be '
              'considered expiring soon',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Sub-property B: tokens expiring more than 600 seconds away → false
    //
    // For any exp > now + 600, isTokenExpiringSoon returns false.
    // -----------------------------------------------------------------------
    Glados(any.farFutureOffset).test(
      'tokens expiring more than 600 seconds away return false',
      (offsetSeconds) {
        final nowSeconds =
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // exp is offsetSeconds seconds from now (601..3600), beyond threshold
        final expTimestamp = nowSeconds + offsetSeconds;
        final token = _buildJwt(expTimestamp);

        expect(
          JwtUtils.isTokenExpiringSoon(token),
          isFalse,
          reason:
              'Token expiring in $offsetSeconds seconds (> 600) should NOT be '
              'considered expiring soon',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Sub-property C: already-expired tokens → true
    //
    // For any exp < now, isTokenExpiringSoon returns true (expired tokens
    // must trigger a refresh).
    // -----------------------------------------------------------------------
    Glados(any.pastOffset).test(
      'already-expired tokens (exp in the past) return true',
      (pastSeconds) {
        final nowSeconds =
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // exp is pastSeconds seconds ago (already expired)
        final expTimestamp = nowSeconds - pastSeconds;
        final token = _buildJwt(expTimestamp);

        expect(
          JwtUtils.isTokenExpiringSoon(token),
          isTrue,
          reason:
              'Token that expired $pastSeconds seconds ago should be '
              'considered expiring soon',
        );
      },
    );

    // -----------------------------------------------------------------------
    // Sub-property D: malformed tokens → false
    //
    // Tokens that are not valid JWTs (wrong segment count, invalid base64,
    // missing exp claim) must return false.
    // -----------------------------------------------------------------------
    test('malformed token with wrong segment count returns false', () {
      expect(JwtUtils.isTokenExpiringSoon('not.a.valid.jwt.token'), isFalse);
      expect(JwtUtils.isTokenExpiringSoon('onlyone'), isFalse);
      expect(JwtUtils.isTokenExpiringSoon('two.parts'), isFalse);
    });

    test('token with invalid base64 payload returns false', () {
      // header and signature are valid base64url, but payload is garbage
      final header =
          _base64UrlEncode(utf8.encode('{"alg":"none","typ":"JWT"}'));
      const badPayload = '!!!not_base64!!!';
      const signature = 'dummy';
      expect(
        JwtUtils.isTokenExpiringSoon('$header.$badPayload.$signature'),
        isFalse,
      );
    });

    test('token with payload missing exp claim returns false', () {
      final header =
          _base64UrlEncode(utf8.encode('{"alg":"none","typ":"JWT"}'));
      final payload =
          _base64UrlEncode(utf8.encode('{"sub":"user123","iat":1000000}'));
      const signature = 'dummy';
      expect(
        JwtUtils.isTokenExpiringSoon('$header.$payload.$signature'),
        isFalse,
      );
    });

    test('empty string returns false', () {
      expect(JwtUtils.isTokenExpiringSoon(''), isFalse);
    });
  });
}
