class PetBookingEntity {
  const PetBookingEntity({
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
}
