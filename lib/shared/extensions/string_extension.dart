/// Extension on [String] providing common string helpers.
///
/// Usage:
/// ```dart
/// 'hello world'.capitalize;   // 'Hello world'
/// ''.isNullOrEmpty;           // true
/// '  '.isNullOrEmpty;         // true (whitespace-only)
/// 'hello'.isNullOrEmpty;      // false
/// ```
extension StringExtension on String {
  /// Returns a copy of this string with the first character uppercased.
  ///
  /// Returns an empty string if this string is empty.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns `true` if this string is empty or contains only whitespace.
  bool get isNullOrEmpty => trim().isEmpty;

  /// Returns `true` if this string is not empty and not whitespace-only.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Capitalizes the first letter of every word in the string.
  ///
  /// Example: `'hello world'` → `'Hello World'`
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncates the string to [maxLength] characters, appending [ellipsis]
  /// if the string was longer than [maxLength].
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}

/// Extension on nullable [String] providing null-safe helpers.
extension NullableStringExtension on String? {
  /// Returns `true` if this string is `null`, empty, or whitespace-only.
  bool get isNullOrEmpty {
    if (this == null) return true;
    return this!.trim().isEmpty;
  }

  /// Returns `true` if this string is non-null and not whitespace-only.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns this string or [fallback] if this string is null or empty.
  String orDefault(String fallback) {
    return isNullOrEmpty ? fallback : this!;
  }
}
