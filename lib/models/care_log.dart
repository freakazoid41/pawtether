import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum CareType {
  feeding,
  walking,
  potty,
  medication,
  grooming,
  water,
  sleep,
  other;

  String get icon {
    switch (this) {
      case CareType.feeding:
        return '🍖';
      case CareType.walking:
        return '🦮';
      case CareType.potty:
        return '💩';
      case CareType.medication:
        return '💊';
      case CareType.grooming:
        return '✂️';
      case CareType.water:
        return '💧';
      case CareType.sleep:
        return '😴';
      case CareType.other:
        return '📌';
    }
  }
}

CareType careTypeFrom(String? v) {
  return CareType.values.firstWhere(
    (e) => e.name == v,
    orElse: () => CareType.other,
  );
}

class CareLogEntry {
  final String id;
  final String petId;
  final DateTime dateTime;
  final CareType type;
  final String detail;
  final String note;

  CareLogEntry({
    String? id,
    required this.petId,
    required this.dateTime,
    required this.type,
    this.detail = '',
    this.note = '',
  }) : id = id ?? _uuid.v4();

  bool isToday() {
    final now = DateTime.now();
    return now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'dateTime': dateTime.toIso8601String(),
        'type': type.name,
        'detail': detail,
        'note': note,
      };

  factory CareLogEntry.fromMap(Map<String, dynamic> m) => CareLogEntry(
        id: m['id'] as String,
        petId: m['petId'] as String,
        dateTime:
            DateTime.tryParse(m['dateTime'] as String? ?? '') ?? DateTime.now(),
        type: careTypeFrom(m['type'] as String?),
        detail: (m['detail'] as String?) ?? '',
        note: (m['note'] as String?) ?? '',
      );
}