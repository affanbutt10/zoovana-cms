import '../../domain/entities/pet_service_entity.dart';

class PetServiceModel {
  const PetServiceModel({
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

  factory PetServiceModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map<String, dynamic>
        ? json['provider'] as Map<String, dynamic>
        : json['provider_profile'] is Map<String, dynamic>
        ? json['provider_profile'] as Map<String, dynamic>
        : null;

    final price = json['price'] ?? json['hourly_rate'] ?? json['amount'];
    final unit = json['price_unit'] ?? json['unit'];
    final photos = json['photos'];
    final firstPhoto = photos is List && photos.isNotEmpty
        ? photos.whereType<Map<String, dynamic>>().firstOrNull
        : null;
    final reviews = json['reviews'] is Map<String, dynamic>
        ? json['reviews'] as Map<String, dynamic>
        : null;
    final serviceTypes = json['service_types'];
    final mapPin = json['map_pin'] is Map<String, dynamic>
        ? json['map_pin'] as Map<String, dynamic>
        : null;

    return PetServiceModel(
      id: _string(
        json['listing_id'] ??
            json['id'] ??
            json['service_id'] ??
            json['provider_id'] ??
            provider?['id'],
      ),
      providerName: _string(
        provider?['business_name'] ??
            provider?['name'] ??
            provider?['full_name'] ??
            json['provider_name'] ??
            json['provider_display_name'],
        fallback: 'Provider',
      ),
      title: _string(
        json['title'] ?? json['name'] ?? json['service_name'],
        fallback: 'Pet care service',
      ),
      description: _nullableString(json['description']),
      serviceType:
          _serviceTypeLabel(serviceTypes) ??
          _nullableString(json['service_type'] ?? json['type']),
      priceLabel: price == null
          ? null
          : 'SAR $price${unit == null ? '' : ' / $unit'}',
      rating: _double(
        json['rating'] ?? json['average_rating'] ?? reviews?['average_rating'],
      ),
      photoUrl: _nullableString(
        json['photo_url'] ?? json['image_url'] ?? firstPhoto?['photo_url'],
      ),
      locationLabel: _nullableString(
        json['city'] ??
            json['location'] ??
            provider?['city'] ??
            _coordinatesLabel(mapPin),
      ),
    );
  }

  PetServiceEntity toEntity() => PetServiceEntity(
    id: id,
    providerName: providerName,
    title: title,
    description: description,
    serviceType: serviceType,
    priceLabel: priceLabel,
    rating: rating,
    photoUrl: photoUrl,
    locationLabel: locationLabel,
  );

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static double? _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static String? _serviceTypeLabel(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    final labels = value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .map((item) => item.replaceAll('_', ' '))
        .toList();
    if (labels.isEmpty) return null;
    return labels.join(', ');
  }

  static String? _coordinatesLabel(Map<String, dynamic>? mapPin) {
    if (mapPin == null) return null;
    final latitude = mapPin['latitude'];
    final longitude = mapPin['longitude'];
    if (latitude == null || longitude == null) return null;
    return '$latitude, $longitude';
  }
}
