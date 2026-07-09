class VolunteerShiftEntity {
  const VolunteerShiftEntity({
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

  bool get canSignIn => status == 'scheduled' || status == 'upcoming';
  bool get canSignOut => status == 'in_progress' || status == 'signed_in';
}
