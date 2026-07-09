class PetServiceEntity {
  const PetServiceEntity({
    required this.id,
    required this.providerName,
    required this.title,
    this.description,
    this.serviceType,
    this.priceLabel,
    this.rating,
    this.photoUrl,
    this.locationLabel,
  });

  final String id;
  final String providerName;
  final String title;
  final String? description;
  final String? serviceType;
  final String? priceLabel;
  final double? rating;
  final String? photoUrl;
  final String? locationLabel;
}
