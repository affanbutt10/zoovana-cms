class ShelterProfileEntity {
  const ShelterProfileEntity({
    required this.id,
    required this.name,
    required this.status,
    this.location,
    this.contact,
    this.acceptingVolunteers = false,
    this.donationsEnabled = false,
  });

  final String id;
  final String name;
  final String status;
  final String? location;
  final String? contact;
  final bool acceptingVolunteers;
  final bool donationsEnabled;
}
