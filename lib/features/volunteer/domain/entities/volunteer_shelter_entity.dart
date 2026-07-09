class VolunteerShelterEntity {
  const VolunteerShelterEntity({
    required this.id,
    required this.name,
    this.location,
    this.acceptingVolunteers = true,
  });

  final String id;
  final String name;
  final String? location;
  final bool acceptingVolunteers;
}
