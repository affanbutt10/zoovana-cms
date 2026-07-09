class ProviderBookingEntity {
  const ProviderBookingEntity({
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
}
