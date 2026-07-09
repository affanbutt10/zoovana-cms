import '../../domain/entities/shelter_lost_found_entity.dart';

class ShelterLostFoundModel {
  const ShelterLostFoundModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.animalName,
    this.location,
    this.reporterName,
    this.reportedAt,
  });

  final String id;
  final String title;
  final String type;
  final String status;
  final String? animalName;
  final String? location;
  final String? reporterName;
  final DateTime? reportedAt;

  factory ShelterLostFoundModel.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] is Map<String, dynamic>
        ? json['animal'] as Map<String, dynamic>
        : null;
    final reporter = json['reporter'] is Map<String, dynamic>
        ? json['reporter'] as Map<String, dynamic>
        : null;
    return ShelterLostFoundModel(
      id: _string(json['id']),
      title: _string(json['title'], fallback: 'Lost & found report'),
      type: _string(json['type'] ?? json['report_type'], fallback: 'lost'),
      status: _string(json['status'], fallback: 'open'),
      animalName: _nullableString(
        json['animal_name'] ?? json['pet_name'] ?? animal?['name'],
      ),
      location: _nullableString(json['location'] ?? json['last_seen_location']),
      reporterName: _nullableString(
        json['reporter_name'] ?? json['contact_name'] ?? reporter?['name'],
      ),
      reportedAt: _date(json['reported_at'] ?? json['created_at']),
    );
  }

  ShelterLostFoundEntity toEntity() => ShelterLostFoundEntity(
    id: id,
    title: title,
    type: type,
    status: status,
    animalName: animalName,
    location: location,
    reporterName: reporterName,
    reportedAt: reportedAt,
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
