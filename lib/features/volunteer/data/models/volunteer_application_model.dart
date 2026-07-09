import '../../domain/entities/volunteer_application_entity.dart';

class VolunteerApplicationModel {
  const VolunteerApplicationModel({
    required this.id,
    required this.status,
    this.shelterName,
    this.submittedAt,
    this.rejectionReason,
  });

  final String id;
  final String status;
  final String? shelterName;
  final DateTime? submittedAt;
  final String? rejectionReason;

  factory VolunteerApplicationModel.fromJson(Map<String, dynamic> json) {
    final shelter = json['shelter'] is Map<String, dynamic>
        ? json['shelter'] as Map<String, dynamic>
        : null;
    return VolunteerApplicationModel(
      id: _string(json['id'] ?? json['application_id']),
      status: _string(json['status'], fallback: 'pending'),
      shelterName: _nullableString(shelter?['name'] ?? json['shelter_name']),
      submittedAt: _date(json['submitted_at'] ?? json['created_at']),
      rejectionReason: _nullableString(json['rejection_reason']),
    );
  }

  VolunteerApplicationEntity toEntity() => VolunteerApplicationEntity(
    id: id,
    status: status,
    shelterName: shelterName,
    submittedAt: submittedAt,
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

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class VolunteerApplicationRequest {
  const VolunteerApplicationRequest({
    required this.shelterId,
    required this.skills,
    required this.availability,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.notes,
  });

  final String shelterId;
  final List<String> skills;
  final List<String> availability;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'shelter_id': shelterId,
    'skills': skills,
    'availability': availability,
    'emergency_contact_name': emergencyContactName,
    'emergency_contact_phone': emergencyContactPhone,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
