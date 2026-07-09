class ProviderProfileEntity {
  const ProviderProfileEntity({
    required this.id,
    required this.status,
    this.businessName,
    this.rejectionReason,
  });

  final String id;
  final String status;
  final String? businessName;
  final String? rejectionReason;

  bool get isApproved => status == 'approved' || status == 'verified';
  bool get isPending => status == 'pending_review' || status == 'pending';
  bool get isRejected => status == 'rejected';
}
