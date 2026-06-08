/// Provides reusable form field validators for use with Flutter's [Form] widget.
///
/// Each method follows the Flutter validator contract:
/// - Returns `null` when the value is valid.
/// - Returns a non-null error [String] when the value is invalid.
class Validators {
  Validators._();

  /// Validates that [value] is not null, empty, or whitespace-only.
  ///
  /// Returns an error message if the value is blank, otherwise `null`.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  /// Validates that [value] is a properly formatted email address.
  ///
  /// Returns an error message if the format is invalid, otherwise `null`.
  /// Also returns an error message if the value is null or empty.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    // RFC 5322-inspired pattern covering the most common valid email formats.
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates that [value] is a valid phone number.
  ///
  /// Accepts optional leading `+` for international format, followed by
  /// 7–15 digits (spaces, dashes, and parentheses are allowed as separators).
  ///
  /// Returns an error message if the format is invalid, otherwise `null`.
  /// Also returns an error message if the value is null or empty.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    // Allows formats like: +1 (555) 123-4567, 0712345678, +447911123456
    final phoneRegex = RegExp(r'^\+?[\d\s\-().]{7,20}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }
}
