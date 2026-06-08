import 'dart:convert';

/// Utility helpers for working with JSON Web Tokens (JWTs).
///
/// These utilities operate on the raw token string without performing
/// signature verification — they are intended only for client-side
/// expiry checks, not for security-critical validation.
class JwtUtils {
  JwtUtils._();

  /// Returns `true` when the JWT [token] will expire within
  /// [thresholdSeconds] seconds from now.
  ///
  /// The method decodes the payload segment of the JWT (the middle
  /// dot-separated part) using base64url decoding and reads the `exp`
  /// claim (Unix timestamp in seconds).
  ///
  /// Returns `false` for any of the following conditions:
  /// - The token is malformed (wrong number of segments, invalid base64, etc.)
  /// - The payload does not contain an `exp` claim
  /// - The `exp` claim is not a number
  /// - The token has already expired (exp ≤ now) — callers should treat an
  ///   already-expired token as "expiring soon" and trigger a refresh
  ///
  /// Example:
  /// ```dart
  /// if (JwtUtils.isTokenExpiringSoon(accessToken)) {
  ///   await refreshToken();
  /// }
  /// ```
  static bool isTokenExpiringSoon(String token, {int thresholdSeconds = 600}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Decode the payload (second segment) with base64url padding
      final payload = _decodeBase64Url(parts[1]);
      final Map<String, dynamic> claims =
          json.decode(payload) as Map<String, dynamic>;

      final dynamic expClaim = claims['exp'];
      if (expClaim == null) return false;

      final int expSeconds = (expClaim as num).toInt();
      final int nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Token is expiring soon if it expires within the threshold window
      return expSeconds - nowSeconds <= thresholdSeconds;
    } catch (_) {
      // Malformed token — treat as not expiring soon to avoid false positives
      return false;
    }
  }

  /// Decodes a base64url-encoded string, adding padding as needed.
  static String _decodeBase64Url(String input) {
    // Normalise base64url → base64 by replacing URL-safe chars
    String normalized = input.replaceAll('-', '+').replaceAll('_', '/');

    // Add padding to make the length a multiple of 4
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
      case 3:
        normalized += '=';
    }

    return utf8.decode(base64.decode(normalized));
  }
}
