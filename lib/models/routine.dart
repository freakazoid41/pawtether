import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class RoutineItem {
  final String id;
  String title;

  RoutineItem({String? id, required this.title}) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory RoutineItem.fromMap(Map<String, dynamic> m) => RoutineItem(
        id: m['id'] as String,
        title: (m['title'] as String?) ?? '',
      );
}

/// A custom care routine with a checklist of items.
/// Progress is tracked per calendar day (resets each day).
class CareRoutine {
  final String id;
  final String petId;
  String name;
  String emoji;
  List<RoutineItem> items;
  String doneDate; // yyyy-MM-dd that the tracked state applies to
  List<String> doneIds;

  CareRoutine({
    String? id,
    required this.petId,
    required this.name,
    this.emoji = '📋',
    List<RoutineItem>? items,
    String? doneDate,
    List<String>? doneIds,
  })  : id = id ?? _uuid.v4(),
        items = items ?? [],
        doneDate = doneDate ?? _todayKey(),
        doneIds = doneIds ?? [];

  static String todayKey() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  static String _todayKey() => todayKey();

  /// True when [doneDate] matches today, at which point [doneIds] is valid.
  bool get isCurrent => doneDate == _todayKey();

  bool isDone(String itemId) => isCurrent && doneIds.contains(itemId);

  int get completedCount =>
      isCurrent ? items.where((i) => doneIds.contains(i.id)).length : 0;

  int get itemCount => items.length;

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'name': name,
        'emoji': emoji,
        'items': items.map((i) => i.toMap()).toList(),
        'doneDate': doneDate,
        'doneIds': doneIds,
      };

  factory CareRoutine.fromMap(Map<String, dynamic> m) => CareRoutine(
        id: m['id'] as String,
        petId: m['petId'] as String,
        name: (m['name'] as String?) ?? '',
        emoji: (m['emoji'] as String?) ?? '📋',
        items: ((m['items'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => RoutineItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        doneDate: (m['doneDate'] as String?) ?? _todayKey(),
        doneIds: ((m['doneIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}