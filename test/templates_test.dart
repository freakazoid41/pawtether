import 'package:flutter_test/flutter_test.dart';
import 'package:pawtether/data/care_templates.dart';
import 'package:pawtether/models/models.dart';

void main() {
  group('Care templates', () {
    test('dog template has daily routine + 5 reminders', () {
      final seed = buildSeedFor('p1', Species.dog);
      expect(seed.routine.items.length, 5);
      expect(seed.routine.emoji, '🐶');
      expect(seed.reminders.length, 5);
      expect(seed.reminders.every((r) => r.petId == 'p1'), isTrue);
    });

    test('cat template has 4 daily items', () {
      final seed = buildSeedFor('p1', Species.cat);
      expect(seed.routine.items.length, 4);
      expect(seed.reminders.length, 5);
    });

    test('budgie template has 5 daily items + 5 reminders', () {
      final seed = buildSeedFor('p1', Species.budgie);
      expect(seed.routine.items.length, 5);
      expect(seed.reminders.length, 5);
    });

    test('parrot template has 5 daily items + 4 reminders', () {
      final seed = buildSeedFor('p1', Species.parrot);
      expect(seed.routine.items.length, 5);
      expect(seed.reminders.length, 4);
    });

    test('rabbit template has 5 daily items + 4 reminders', () {
      final seed = buildSeedFor('p1', Species.rabbit);
      expect(seed.routine.items.length, 5);
      expect(seed.routine.emoji, '🐰');
      expect(seed.reminders.length, 4);
      expect(seed.reminders.every((r) => r.petId == 'p1'), isTrue);
    });

    test('fish template has 4 daily items + 4 reminders', () {
      final seed = buildSeedFor('p1', Species.fish);
      expect(seed.routine.items.length, 4);
      expect(seed.routine.emoji, '🐟');
      expect(seed.reminders.length, 4);
      expect(seed.reminders.every((r) => r.petId == 'p1'), isTrue);
    });

    test('species round-trips incl. new birds', () {
      for (final s in Species.values) {
        final pet = Pet(name: 'X', species: s);
        expect(Pet.fromMap(pet.toMap()).species, s);
      }
    });
  });
}
