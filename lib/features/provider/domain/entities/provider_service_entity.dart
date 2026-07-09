class ProviderServiceEntity {
  const ProviderServiceEntity({
    required this.id,
    required this.title,
    required this.serviceType,
    this.description,
    this.priceLabel,
    this.isActive = true,
    this.rating,
    this.serviceTypes = const [],
    this.photoUrl,
    this.totalReviews = 0,
  });

  final String id;
  final String title;
  final String serviceType;
  final String? description;
  final String? priceLabel;
  final bool isActive;
  final double? rating;
  final List<String> serviceTypes;
  final String? photoUrl;
  final int totalReviews;
}
