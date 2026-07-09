class VolunteerApplicationEntity {
  const VolunteerApplicationEntity({
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

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending' || status == 'pending_review';
  bool get isRejected => status == 'rejected';
}
