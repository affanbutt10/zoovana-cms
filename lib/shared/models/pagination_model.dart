/// Shared model representing a paginated API list response.
///
/// Parses the standard pagination envelope returned by the Zoovana CMS API:
/// ```json
/// {
///   "current_page": 1,
///   "last_page": 5,
///   "total": 48,
///   "per_page": 10
/// }
/// ```
class PaginationModel {
  const PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  /// The current page number (1-based).
  final int currentPage;

  /// The last available page number.
  final int lastPage;

  /// Total number of items across all pages.
  final int total;

  /// Number of items per page.
  final int perPage;

  /// Whether there is a next page available.
  bool get hasNextPage => currentPage < lastPage;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: (json['current_page'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'total': total,
    'per_page': perPage,
  };

  @override
  String toString() =>
      'PaginationModel(currentPage: $currentPage, lastPage: $lastPage, '
      'total: $total, perPage: $perPage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationModel &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          lastPage == other.lastPage &&
          total == other.total &&
          perPage == other.perPage;

  @override
  int get hashCode =>
      currentPage.hashCode ^
      lastPage.hashCode ^
      total.hashCode ^
      perPage.hashCode;
}
