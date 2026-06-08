import 'package:intl/intl.dart';

/// Provides static date and time formatting helpers using the `intl` package.
class DateTimeUtils {
  DateTimeUtils._();

  /// Formats [dateTime] as a human-readable date string.
  ///
  /// Example output: `"Jan 15, 2024"`
  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }

  /// Formats [dateTime] as a time string in 12-hour format with AM/PM.
  ///
  /// Example output: `"03:45 PM"`
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Formats [dateTime] as a full date and time string.
  ///
  /// Example output: `"Jan 15, 2024 03:45 PM"`
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy hh:mm a').format(dateTime);
  }

  /// Formats [dateTime] as an ISO 8601 date string (date portion only).
  ///
  /// Example output: `"2024-01-15"`
  static String formatIso8601Date(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Formats [dateTime] as a full ISO 8601 string.
  ///
  /// Example output: `"2024-01-15T15:45:00.000"`
  static String formatIso8601(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Returns a relative time description for [dateTime] compared to now.
  ///
  /// Examples: `"just now"`, `"5 minutes ago"`, `"2 hours ago"`, `"3 days ago"`.
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Parses an ISO 8601 string and returns a [DateTime], or `null` if parsing fails.
  static DateTime? tryParseIso8601(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
