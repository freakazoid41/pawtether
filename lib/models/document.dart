import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum DocCategory {
  vetRecord,
  insurance,
  microchip,
  adoption,
  prescription,
  other;
}

DocCategory docCategoryFrom(String? v) {
  return DocCategory.values.firstWhere(
    (e) => e.name == v,
    orElse: () => DocCategory.other,
  );
}

class MedicalDocument {
  final String id;
  final String petId;
  final String title;
  final DocCategory category;
  final String filePath;
  final String thumb;
  final DateTime createdAt;
  final String notes;

  MedicalDocument({
    String? id,
    required this.petId,
    required this.title,
    required this.category,
    required this.filePath,
    this.thumb = '',
    DateTime? createdAt,
    this.notes = '',
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'title': title,
        'category': category.name,
        'filePath': filePath,
        'thumb': thumb,
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
      };

  factory MedicalDocument.fromMap(Map<String, dynamic> m) => MedicalDocument(
        id: m['id'] as String,
        petId: m['petId'] as String,
        title: (m['title'] as String?) ?? '',
        category: docCategoryFrom(m['category'] as String?),
        filePath: (m['filePath'] as String?) ?? '',
        thumb: (m['thumb'] as String?) ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
        notes: (m['notes'] as String?) ?? '',
      );
}