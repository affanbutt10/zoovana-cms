import '../../domain/entities/volunteer_shift_entity.dart';

class VolunteerShiftModel {
  const VolunteerShiftModel({
    required this.id,
    required this.role,
    required this.status,
    this.shelterName,
    this.startsAt,
    this.endsAt,
    this.notes,
    this.hoursWorked,
  });

  final String id;
  final String role;
  final String status;
  final String? shelterName;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? notes;
  final double? hoursWorked;

  factory VolunteerShiftModel.fromJson(Map<String, dynamic> json) {
    final shelter = json['shelter'] is Map<String, dynamic>
        ? json['shelter'] as Map<String, dynamic>
        : null;
    return VolunteerShiftModel(
      id: _string(json['id'] ?? json['shift_id']),
      role: _string(json['role'], fallback: 'Volunteer'),
      status: _string(json['status'], fallback: 'scheduled'),
      shelterName: _nullableString(shelter?['name'] ?? json['shelter_name']),
      startsAt: _date(json['starts_at'] ?? json['start_time']),
      endsAt: _date(json['ends_at'] ?? json['end_time']),
      notes: _nullableString(json['notes']),
      hoursWorked: _double(json['hours_worked']),
    );
  }

  VolunteerShiftEntity toEntity() => VolunteerShiftEntity(
    id: id,
    role: role,
    status: status,
    shelterName: shelterName,
    startsAt: startsAt,
    endsAt: endsAt,
    notes: notes,
    hoursWorked: hoursWorked,
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

  static double? _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
