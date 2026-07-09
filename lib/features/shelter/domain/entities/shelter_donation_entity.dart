class ShelterDonationEntity {
  const ShelterDonationEntity({
    required this.id,
    required this.donorName,
    required this.amountLabel,
    required this.status,
    this.shelterName,
    this.donatedAt,
  });

  final String id;
  final String donorName;
  final String amountLabel;
  final String status;
  final String? shelterName;
  final DateTime? donatedAt;
}
