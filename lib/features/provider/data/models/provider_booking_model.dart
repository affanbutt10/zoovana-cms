import '../../domain/entities/provider_booking_entity.dart';

class ProviderBookingModel {
  const ProviderBookingModel({
    required this.id,
    required this.petOwnerName,
    required this.serviceTitle,
    required this.status,
    this.petName,
    this.scheduledAt,
    this.totalLabel,
  });

  final String id;
  final String petOwnerName;
  final String serviceTitle;
  final String status;
  final String? petName;
  final DateTime? scheduledAt;
  final String? totalLabel;

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    final owner = json['pet_owner'] is Map<String, dynamic>
        ? json['pet_owner'] as Map<String, dynamic>
        : json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : null;
    final service = json['service'] is Map<String, dynamic>
        ? json['service'] as Map<String, dynamic>
        : null;
    final pet = json['pet'] is Map<String, dynamic>
        ? json['pet'] as Map<String, dynamic>
        : null;
    final total = json['total'] ?? json['amount'] ?? json['price'];

    return ProviderBookingModel(
      id: _string(json['id'] ?? json['booking_id']),
      petOwnerName: _string(
        owner?['name'] ?? owner?['full_name'] ?? json['pet_owner_name'],
        fallback: 'Pet owner',
      ),
      serviceTitle: _string(
        service?['title'] ?? service?['name'] ?? json['service_name'],
        fallback: 'Service booking',
      ),
      status: _string(json['status'], fallback: 'pending'),
      petName: _nullableString(pet?['name'] ?? json['pet_name']),
      scheduledAt: _date(json['scheduled_at'] ?? json['starts_at']),
      totalLabel: total == null ? null : 'SAR $total',
    );
  }

  ProviderBookingEntity toEntity() => ProviderBookingEntity(
    id: id,
    petOwnerName: petOwnerName,
    serviceTitle: serviceTitle,
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
