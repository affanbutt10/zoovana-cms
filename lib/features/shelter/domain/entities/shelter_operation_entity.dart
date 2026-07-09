class ShelterOperationEntity {
  const ShelterOperationEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    this.meta,
  });

  final String id;
  final String title;
  final String subtitle;
  final String status;
  final String? meta;
}
