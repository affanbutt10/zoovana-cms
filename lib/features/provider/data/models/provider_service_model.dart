import '../../domain/entities/provider_service_entity.dart';

class ProviderServiceModel {
  const ProviderServiceModel({
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

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    final price = json['price'] ?? json['hourly_rate'];
    final unit = json['price_unit'] ?? json['unit'];
    final types = json['service_types'];
    final photos = json['photos'];
    final reviews = json['reviews'];
    final serviceTypes = types is List
        ? types.map((item) => item.toString()).toList()
        : <String>[];
    return ProviderServiceModel(
      id: _string(json['id'] ?? json['service_id']),
      title: _string(json['title'] ?? json['name'], fallback: 'Service'),
      serviceType: _string(
        serviceTypes.isEmpty
            ? json['service_type'] ?? json['type']
            : serviceTypes.first,
        fallback: 'care',
      ),
      description: _nullableString(json['description']),
      priceLabel: price == null
          ? null
          : 'SAR $price${unit == null ? '' : ' / $unit'}',
      isActive: json['is_active'] != false && json['status'] != 'inactive',
      rating: _double(
        json['rating'] ??
            json['average_rating'] ??
            (reviews is Map ? reviews['average_rating'] : null),
      ),
      serviceTypes: serviceTypes,
      photoUrl: photos is List && photos.isNotEmpty && photos.first is Map
          ? (photos.first as Map)['photo_url']?.toString()
          : null,
      totalReviews: reviews is Map
          ? int.tryParse('${reviews['total_reviews']}') ?? 0
          : 0,
    );
  }

  ProviderServiceEntity toEntity() => ProviderServiceEntity(
    id: id,
    title: title,
    serviceType: serviceType,
    description: description,
    priceLabel: priceLabel,
    isActive: isActive,
    rating: rating,
    serviceTypes: serviceTypes,
    photoUrl: photoUrl,
    totalReviews: totalReviews,
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
}

class ProviderServiceRequest {
  const ProviderServiceRequest({
    required this.title,
    required this.serviceType,
    required this.price,
    this.description,
    this.priceUnit = 'session',
    this.serviceTypes = const [],
    this.minDuration = 1,
    this.maxDuration = 24,
    this.maxPets = 1,
    this.petSize = 'medium',
    this.propertyType = 'house',
    this.yardSizeSqm = 0,
    this.responseTimeMinutes = 60,
    this.bookingCutoffHours = 24,
    this.isActive = true,
  });

  final String title;
  final String serviceType;
  final double price;
  final String? description;
  final String priceUnit;
  final List<String> serviceTypes;
  final int minDuration;
  final int maxDuration;
  final int maxPets;
  final String petSize;
  final String propertyType;
  final double yardSizeSqm;
  final int responseTimeMinutes;
  final int bookingCutoffHours;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'title': title,
    'service_types': serviceTypes.isEmpty ? [serviceType] : serviceTypes,
    'price': price,
    'price_unit': priceUnit,
    'min_duration': minDuration,
    'max_duration': maxDuration,
    'max_pets': maxPets,
    'pet_size': petSize,
    'property_type': propertyType,
    'yard_size_sqm': yardSizeSqm,
    'response_time_minutes': responseTimeMinutes,
    'booking_cutoff_hours': bookingCutoffHours,
    'is_active': isActive ? 1 : 0,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}
