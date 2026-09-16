import 'package:flutter_test/flutter_test.dart';
import 'package:pawtether/models/models.dart';
import 'package:pawtether/utils/i18n_helpers.dart';

Reminder _r({
  required RepeatRule repeat,
  required DateTime date,
  bool enabled = true,
}) =>
    Reminder(
      petId: 'p1',
      title: 't',
      type: ReminderType.feeding,
      date: date,
      repeat: repeat,
      enabled: enabled,
    );

void main() {
  group('Reminder occurrences', () {
    test('one-time future returns its date, past returns null', () {
      final now = DateTime(2026, 5, 10, 12, 0);
      expect(
          _r(repeat: RepeatRule.none, date: DateTime(2026, 5, 11, 9, 0))
              .nextOccurrence(from: now),
          DateTime(2026, 5, 11, 9, 0));
      expect(
          _r(repeat: RepeatRule.none, date: DateTime(2026, 5, 9, 9, 0))
              .nextOccurrence(from: now),
          isNull);
    });

    test('daily rolls forward to the next future slot', () {
      final now = DateTime(2026, 5, 10, 12, 0);
      final next = _r(repeat: RepeatRule.daily, date: DateTime(2026, 4, 1, 9, 0))
          .nextOccurrence(from: now)!;
      expect(next.isAfter(now), isTrue);
      expect(next.hour, 9);
      // 9am today already passed → tomorrow 9am.
      expect(next, DateTime(2026, 5, 11, 9, 0));
    });

    test('weekly rolls forward by whole weeks', () {
      // Friday 2026-05-01 9:00, now Sunday 2026-05-10 → next Friday 05-15.
      final now = DateTime(2026, 5, 10, 12, 0);
      final next = _r(repeat: RepeatRule.weekly, date: DateTime(2026, 5, 1, 9, 0))
          .nextOccurrence(from: now)!;
      expect(next, DateTime(2026, 5, 15, 9, 0));
    });

    test('monthly clamps day-31 in short months', () {
      final now = DateTime(2026, 2, 10, 12, 0);
      final next = _r(
              repeat: RepeatRule.monthly,
              date: DateTime(2026, 1, 31, 9, 0))
          .nextOccurrence(from: now)!;
      // 2026 is not a leap year → Feb 28.
      expect(next, DateTime(2026, 2, 28, 9, 0));
      expect(
          _r(repeat: RepeatRule.monthly, date: DateTime(2026, 1, 31, 9, 0))
              .occursOn(DateTime(2026, 2, 28)),
          isTrue);
    });

    test('occursOn respects start date and weekday', () {
      final monday = DateTime(2026, 5, 11); // a Monday
      final weekly = _r(
          repeat: RepeatRule.weekly, date: DateTime(2026, 5, 11, 9, 0));
      expect(weekly.occursOn(monday), isTrue);
      expect(weekly.occursOn(DateTime(2026, 5, 12)), isFalse);
      expect(weekly.occursOn(DateTime(2026, 5, 4)), isFalse); // before start
      final daily =
          _r(repeat: RepeatRule.daily, date: DateTime(2026, 5, 11, 9, 0));
      expect(daily.occursOn(DateTime(2026, 5, 10)), isFalse);
      expect(daily.occursOn(DateTime(2026, 5, 12)), isTrue);
    });

    test('isDueToday is repeat-aware, disabled never due', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 9, 0);
      expect(_r(repeat: RepeatRule.none, date: today).isDueToday, isTrue);
      expect(
          _r(
              repeat: RepeatRule.none,
              date: today.subtract(const Duration(days: 1)))
              .isDueToday,
          isFalse);
      expect(
          _r(
              repeat: RepeatRule.daily,
              date: today.subtract(const Duration(days: 30)),
              enabled: false)
              .isDueToday,
          isFalse);
    });

    test('unknown species strings fall back to other, not dog', () {
      expect(speciesFromString('dragon'), Species.other);
      expect(speciesFromString(null), Species.other);
      expect(speciesFromString('rabbit'), Species.rabbit);
      expect(speciesFromString('fish'), Species.fish);
    });

    test('copyWith keeps identity while moving the date', () {
      final r = _r(repeat: RepeatRule.daily, date: DateTime(2026, 5, 1, 9, 0));
      final moved = r.copyWith(date: DateTime(2026, 5, 2, 9, 0));
      expect(moved.id, r.id);
      expect(moved.petId, r.petId);
      expect(moved.date, DateTime(2026, 5, 2, 9, 0));
    });

    test('seedTr maps known seeds to keys, passes custom through', () {
      // No locale loaded in unit tests → .tr() returns the key itself.
      expect(seedTr('Daily dog care'), 'seed_routine_dog');
      expect(seedTr('Flea treatment'), 'seed_flea_treat');
      expect(seedTr('Breakfast'), 'ql_opt_breakfast');
      expect(seedTr('My custom reminder'), 'My custom reminder');
      expect(seedTr(''), '');
    });
  });
}
