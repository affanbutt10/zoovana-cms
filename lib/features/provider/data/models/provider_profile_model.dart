import '../../domain/entities/provider_profile_entity.dart';

class ProviderProfileModel {
  const ProviderProfileModel({
    required this.id,
    required this.status,
    this.businessName,
    this.rejectionReason,
  });

  final String id;
  final String status;
  final String? businessName;
  final String? rejectionReason;

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ProviderProfileModel(
      id: _string(json['id'] ?? json['profile_id']),
      status: _string(
        json['verification_status'] ?? json['status'],
        fallback: 'not_started',
      ),
      businessName: _nullableString(json['business_name'] ?? json['name']),
      rejectionReason: _nullableString(json['rejection_reason']),
    );
  }

  ProviderProfileEntity toEntity() => ProviderProfileEntity(
    id: id,
    status: status,
    businessName: businessName,
    rejectionReason: rejectionReason,
  );

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}

class ProviderApplicationRequest {
  const ProviderApplicationRequest({
    required this.businessName,
    required this.serviceTypes,
    this.experienceYears,
    this.notes,
  });

  final String businessName;
  final List<String> serviceTypes;
  final int? experienceYears;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'business_name': businessName,
    'service_types': serviceTypes,
    if (experienceYears != null) 'experience_years': experienceYears,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
