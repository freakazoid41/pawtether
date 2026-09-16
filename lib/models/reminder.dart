import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum RepeatRule { none, daily, weekly, monthly }

RepeatRule repeatFromString(String? v) => RepeatRule.values.firstWhere(
      (e) => e.name == v,
      orElse: () => RepeatRule.none,
    );

enum ReminderType { medication, vaccine, feeding, walking, grooming, vet, other }

ReminderType reminderTypeFrom(String? v) {
  return ReminderType.values.firstWhere(
    (e) => e.name == v,
    orElse: () => ReminderType.other,
  );
}

class Reminder {
  final String id;
  final String petId;
  final String title;
  final ReminderType type;
  final DateTime date;
  final RepeatRule repeat;
  final bool enabled;
  final String note;

  Reminder({
    String? id,
    required this.petId,
    required this.title,
    required this.type,
    required this.date,
    this.repeat = RepeatRule.none,
    this.enabled = true,
    this.note = '',
  }) : id = id ?? _uuid.v4();

  Reminder copyWith({DateTime? date, bool? enabled}) => Reminder(
        id: id,
        petId: petId,
        title: title,
        type: type,
        date: date ?? this.date,
        repeat: repeat,
        enabled: enabled ?? this.enabled,
        note: note,
      );

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// True when this reminder fires on [day] (repeat-aware).
  bool occursOn(DateTime day) {
    final start = _dayOf(date);
    final d = _dayOf(day);
    if (d.isBefore(start)) return false;
    switch (repeat) {
      case RepeatRule.none:
        return d == start;
      case RepeatRule.daily:
        return true;
      case RepeatRule.weekly:
        return d.weekday == start.weekday;
      case RepeatRule.monthly:
        final want =
            date.day > _daysInMonth(d.year, d.month) ? _daysInMonth(d.year, d.month) : date.day;
        return d.day == want;
    }
  }

  /// Next firing strictly after now (null = one-time already past).
  DateTime? nextOccurrence({DateTime? from}) {
    final now = from ?? DateTime.now();
    if (repeat == RepeatRule.none) {
      return date.isAfter(now) ? date : null;
    }
    if (repeat == RepeatRule.daily) {
      var d = DateTime(date.year, date.month, date.day, date.hour, date.minute);
      var guard = 0;
      while (!d.isAfter(now) && guard++ < 800) {
        d = d.add(const Duration(days: 1));
      }
      return d;
    }
    if (repeat == RepeatRule.weekly) {
      var d = DateTime(date.year, date.month, date.day, date.hour, date.minute);
      var guard = 0;
      while (!d.isAfter(now) && guard++ < 120) {
        d = d.add(const Duration(days: 7));
      }
      return d;
    }
    var y = date.year;
    var m = date.month;
    DateTime occ(int y, int m) {
      final dim = _daysInMonth(y, m);
      return DateTime(
          y, m, date.day > dim ? dim : date.day, date.hour, date.minute);
    }

    var d = occ(y, m);
    var guard = 0;
    while (!d.isAfter(now) && guard++ < 40) {
      m++;
      if (m > 12) {
        m = 1;
        y++;
      }
      d = occ(y, m);
    }
    return d;
  }

  bool get isDueToday {
    if (!enabled) return false;
    return occursOn(DateTime.now());
  }

  bool get isOverdue {
    if (!enabled) return false;
    if (repeat != RepeatRule.none) return false;
    // Same-day past counts too — a missed time today still shouts on the
    // next refresh instead of sitting in silent limbo.
    return date.isBefore(DateTime.now());
  }

  bool get isDueNow => isDueToday || isOverdue;

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'title': title,
        'type': type.name,
        'date': date.toIso8601String(),
        'repeat': repeat.name,
        'enabled': enabled,
        'note': note,
      };

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
        id: m['id'] as String,
        petId: m['petId'] as String,
        title: (m['title'] as String?) ?? '',
        type: reminderTypeFrom(m['type'] as String?),
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        repeat: repeatFromString(m['repeat'] as String?),
        enabled: (m['enabled'] as bool?) ?? true,
        note: (m['note'] as String?) ?? '',
      );
}