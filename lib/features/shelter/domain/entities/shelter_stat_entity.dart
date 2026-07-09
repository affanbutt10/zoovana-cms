class ShelterStatEntity {
  const ShelterStatEntity({
    required this.label,
    required this.value,
    this.trend,
  });

  final String label;
  final String value;
  final String? trend;
}
