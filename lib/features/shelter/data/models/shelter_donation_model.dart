import '../../domain/entities/shelter_donation_entity.dart';

class ShelterDonationModel {
  const ShelterDonationModel({
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

  factory ShelterDonationModel.fromJson(Map<String, dynamic> json) {
    final shelter = json['shelter'] is Map<String, dynamic>
        ? json['shelter'] as Map<String, dynamic>
        : null;
    final amount = json['amount'] ?? json['total'] ?? json['value'];
    final currency = json['currency']?.toString() ?? 'SAR';
    return ShelterDonationModel(
      id: json['id']?.toString() ?? '',
      donorName:
          json['donor_name']?.toString() ??
          json['name']?.toString() ??
          'Anonymous donor',
      amountLabel: amount == null ? currency : '$currency $amount',
      status: json['status']?.toString() ?? 'pending',
      shelterName:
          shelter?['name']?.toString() ?? json['shelter_name']?.toString(),
      donatedAt: _date(json['donated_at'] ?? json['created_at']),
    );
  }

  ShelterDonationEntity toEntity() => ShelterDonationEntity(
    id: id,
    donorName: donorName,
    amountLabel: amountLabel,
    status: status,
    shelterName: shelterName,
    donatedAt: donatedAt,
  );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
