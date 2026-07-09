import '../../domain/entities/pet_booking_entity.dart';

class PetBookingModel {
  const PetBookingModel({
    required this.id,
    required this.serviceTitle,
    required this.providerName,
    required this.status,
    this.petName,
    this.scheduledAt,
    this.totalLabel,
  });

  final String id;
  final String serviceTitle;
  final String providerName;
  final String status;
  final String? petName;
  final DateTime? scheduledAt;
  final String? totalLabel;

  factory PetBookingModel.fromJson(Map<String, dynamic> json) {
    final service = json['service'] is Map<String, dynamic>
        ? json['service'] as Map<String, dynamic>
        : null;
    final provider = json['provider'] is Map<String, dynamic>
        ? json['provider'] as Map<String, dynamic>
        : null;
    final pet = json['pet'] is Map<String, dynamic>
        ? json['pet'] as Map<String, dynamic>
        : null;
    final animals = json['animals'];
    final firstAnimal = animals is List && animals.isNotEmpty
        ? animals.whereType<Map<String, dynamic>>().firstOrNull
        : null;
    final total =
        json['total'] ??
        json['amount'] ??
        json['price'] ??
        json['total_amount'];
    final serviceId = _nullableString(json['service_id']);

    return PetBookingModel(
      id: _string(json['id'] ?? json['booking_id']),
      serviceTitle: _string(
        service?['title'] ??
            service?['name'] ??
            json['service_name'] ??
            json['service_title'],
        fallback: serviceId == null ? 'Service booking' : 'Service $serviceId',
      ),
      providerName: _string(
        provider?['business_name'] ??
            provider?['name'] ??
            provider?['full_name'] ??
            json['provider_display_name'] ??
            json['provider_name'],
        fallback: 'Provider',
      ),
      status: _string(json['status'], fallback: 'pending'),
      petName: _nullableString(
        pet?['name'] ?? firstAnimal?['name'] ?? json['pet_name'],
      ),
      scheduledAt: _date(
        json['scheduled_at'] ??
            json['starts_at'] ??
            json['booking_date'] ??
            json['start_date'],
      ),
      totalLabel: total == null ? null : 'SAR $total',
    );
  }

  PetBookingEntity toEntity() => PetBookingEntity(
    id: id,
    serviceTitle: serviceTitle,
    providerName: providerName,
    status: status,
    petName: petName,
    scheduledAt: scheduledAt,
    totalLabel: totalLabel,
  );

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class BookingRequest {
  const BookingRequest({
    required this.serviceId,
    required this.petId,
    required this.requestedAt,
    this.notes,
  });

  final String serviceId;
  final String petId;
  final DateTime requestedAt;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'service_id': serviceId,
    'pet_id': petId,
    'requested_at': requestedAt.toIso8601String(),
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
