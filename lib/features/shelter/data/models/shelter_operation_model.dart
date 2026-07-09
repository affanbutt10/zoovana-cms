import '../../domain/entities/shelter_operation_entity.dart';
import '../../domain/entities/shelter_stat_entity.dart';

class ShelterOperationModel {
  const ShelterOperationModel({
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

  factory ShelterOperationModel.fromJson(Map<String, dynamic> json) {
    return ShelterOperationModel(
      id: _string(json['id'] ?? json['code']),
      title: _string(
        json['name'] ??
            json['title'] ??
            json['animal_name'] ??
            json['donor_name'] ??
            json['applicant_name'],
        fallback: 'Item',
      ),
      subtitle: _string(
        json['description'] ??
            json['type'] ??
            json['breed'] ??
            json['shelter_name'] ??
            json['notes'],
        fallback: 'Shelter record',
      ),
      status: _string(json['status'], fallback: 'active'),
      meta: _nullableString(
        json['created_at'] ?? json['date'] ?? json['amount'] ?? json['role'],
      ),
    );
  }

  ShelterOperationEntity toEntity() => ShelterOperationEntity(
    id: id,
    title: title,
    subtitle: subtitle,
    status: status,
    meta: meta,
  );

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}

class ShelterStatModel {
  const ShelterStatModel({
    required this.label,
    required this.value,
    this.trend,
  });

  final String label;
  final String value;
  final String? trend;

  factory ShelterStatModel.fromJson(String label, dynamic value) {
    if (value is Map) {
      final count = value['count'] ?? value['value'] ?? value['total'] ?? 0;
      final rawChange = value['change'];
      final change = rawChange == null
          ? null
          : rawChange is num
          ? '${rawChange > 0 ? '+' : ''}${rawChange.toStringAsFixed(rawChange % 1 == 0 ? 0 : 1)}%'
          : rawChange.toString();
      return ShelterStatModel(
        label: (value['label']?.toString().trim().isNotEmpty ?? false)
            ? value['label'].toString()
            : label,
        value: count.toString(),
        trend: change,
      );
    }
    return ShelterStatModel(label: label, value: value?.toString() ?? '0');
  }

  ShelterStatEntity toEntity() =>
      ShelterStatEntity(label: label, value: value, trend: trend);
}
