import 'package:flutter_test/flutter_test.dart';
import 'package:pawtether/models/models.dart';

void main() {
  group('Pet', () {
    test('round-trips through toMap/fromMap', () {
      final pet = Pet(
        name: 'Luna',
        species: Species.cat,
        breed: 'Maine Coon',
        birthday: DateTime(2022, 4, 10),
        gender: 'Female',
        weightKg: 4.5,
        microchip: '981020123456789',
        allergies: ['fish', 'wool'],
        personalityNotes: 'Queen of the house',
        isFavorite: true,
      );
      final restored = Pet.fromMap(pet.toMap());
      expect(restored.name, 'Luna');
      expect(restored.species, Species.cat);
      expect(restored.weightKg, 4.5);
      expect(restored.allergies, ['fish', 'wool']);
      expect(restored.microchip, '981020123456789');
      expect(restored.isFavorite, true);
      expect(restored.id, pet.id);
    });
  });

  group('CareLogEntry', () {
    test('today flag works', () {
      final log = CareLogEntry(
        petId: 'p1',
        dateTime: DateTime.now(),
        type: CareType.feeding,
      );
      expect(log.isToday(), isTrue);
    });

    test('round-trips via from/toMap', () {
      final log = CareLogEntry(
        petId: 'p1',
        dateTime: DateTime(2026, 8, 8, 9, 30),
        type: CareType.walking,
        detail: 'Long walk',
      );
      final restored = CareLogEntry.fromMap(log.toMap());
      expect(restored.type, CareType.walking);
      expect(restored.detail, 'Long walk');
      expect(restored.id, log.id);
    });
  });

  group('Reminder', () {
    test('one-off overdue detection', () {
      final past = Reminder(
        petId: 'p1',
        title: 'Booster',
        type: ReminderType.vaccine,
        date: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(past.isOverdue, isTrue);
      expect(past.isDueToday, isFalse);
    });

    test('daily reminder due today after start', () {
      final daily = Reminder(
        petId: 'p1',
        title: 'Meds',
        type: ReminderType.medication,
        date: DateTime.now().subtract(const Duration(days: 3)),
        repeat: RepeatRule.daily,
      );
      expect(daily.isDueToday, isTrue);
    });
  });

  group('Weight & health records', () {
    test('weight entry round trip', () {
      final w = WeightEntry(
        petId: 'p1',
        date: DateTime(2026, 7, 1),
        weight: 5.2,
      );
      expect(WeightEntry.fromMap(w.toMap()).weight, 5.2);
    });

    test('medication active state', () {
      final active = Medication(
        petId: 'p1',
        name: 'Antibiotic',
        frequency: 'Twice daily',
        startDate: DateTime.now(),
      );
      expect(active.isActive, isTrue);
      final ended = Medication(
        petId: 'p1',
        name: 'Done',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(ended.isActive, isFalse);
    });

    test('vet visit round-trips and preserves id on edit', () {
      final v = VetVisit(
        petId: 'p1',
        date: DateTime(2026, 6, 1),
        reason: 'Checkup',
        vetName: 'Dr. A',
        diagnosis: 'Healthy',
        cost: 50,
        notes: 'Good',
      );
      final restored = VetVisit.fromMap(v.toMap());
      expect(restored.reason, 'Checkup');
      expect(restored.cost, 50);
      // Simulate updateVisit replace-by-id semantics.
      final edited = VetVisit(
        id: v.id,
        petId: v.petId,
        date: v.date,
        reason: 'Follow-up',
        vetName: 'Dr. A',
        diagnosis: 'Healthy',
        cost: 60,
        notes: 'Recheck',
      );
      expect(edited.id, v.id);
      final list = [v];
      final i = list.indexWhere((x) => x.id == edited.id);
      list[i] = edited;
      expect(list.single.reason, 'Follow-up');
      expect(list.single.cost, 60);
    });

    group('Expense', () {
    test('round-trips and sums up', () {
      final e = Expense(
        petId: 'p1',
        title: 'Kibble',
        category: ExpenseCategory.food,
        amount: 24.99,
        date: DateTime(2026, 8, 1),
      );
      final restored = Expense.fromMap(e.toMap());
      expect(restored.title, 'Kibble');
      expect(restored.category, ExpenseCategory.food);
      expect(restored.amount, 24.99);
      expect(restored.id, e.id);
    });
  });

  group('CareRoutine', () {
    test('completion resets per day', () {
      final routine = CareRoutine(
        petId: 'p1',
        name: 'Morning care',
        items: [
          RoutineItem(title: 'Brush'),
          RoutineItem(title: 'Ear drops'),
        ],
      );
      expect(routine.completedCount, 0);
      routine.doneIds = [routine.items.first.id];
      routine.doneDate = CareRoutine.todayKey();
      expect(routine.isDone(routine.items.first.id), isTrue);
      expect(routine.completedCount, 1);

      routine.doneDate = '2020-01-01'; // stale day -> state invalid
      expect(routine.isDone(routine.items.first.id), isFalse);
      expect(routine.completedCount, 0);
    });

    test('round-trips through from/toMap', () {
      final routine = CareRoutine(
        petId: 'p1',
        name: 'Walkies',
        emoji: '🐾',
        items: [RoutineItem(title: 'Poop bag')],
      );
      final restored = CareRoutine.fromMap(routine.toMap());
      expect(restored.name, 'Walkies');
      expect(restored.items.length, 1);
      expect(restored.items.first.title, 'Poop bag');
    });
  });
  });
}