import 'package:flutter_test/flutter_test.dart';
import 'package:pawtether/data/species_care.dart';
import 'package:pawtether/models/models.dart';

void main() {
  group('Species care guide', () {
    test('every species has needs + meds + vaccines + toxic list', () {
      for (final s in Species.values) {
        final c = careFor(s);
        expect(c.needs.length, greaterThanOrEqualTo(4),
            reason: '$s needs');
        expect(c.medicines.length, greaterThanOrEqualTo(2),
            reason: '$s meds');
        expect(c.vaccines.length, greaterThanOrEqualTo(1),
            reason: '$s vaccines');
        expect(c.toxicFoods.length, greaterThanOrEqualTo(3),
            reason: '$s toxic');
        expect(c.tagline.isNotEmpty, isTrue);
      }
    });

    test('dogs get walks, birds get cage + light needs', () {
      final dogTitles =
          careFor(Species.dog).needs.map((n) => n.title).join(' ');
      expect(dogTitles.toLowerCase(), contains('walk'));
      final budgieTitles =
          careFor(Species.budgie).needs.map((n) => n.title).join(' ');
      expect(budgieTitles.toLowerCase(), contains('cage'));
      final parrotTitles =
          careFor(Species.parrot).needs.map((n) => n.title).join(' ');
      expect(parrotTitles.toLowerCase(), contains('sleep'));
    });

    test('cat flea warning calls out permethrin danger', () {
      final meds = careFor(Species.cat).medicines;
      expect(
          meds.any((m) =>
              m.warning.toLowerCase().contains('permethrin') ||
              m.warning.toLowerCase().contains('kill')),
          isTrue);
    });

    test('need frequencies use known buckets', () {
      for (final s in Species.values) {
        for (final n in careFor(s).needs) {
          expect(NeedFrequency.values, contains(n.frequency));
        }
      }
    });

    test('every need is actionable (quickLog + remind type)', () {
      for (final s in Species.values) {
        for (final n in careFor(s).needs) {
          expect(CareType.values, contains(n.quickLog), reason: '$s ${n.title}');
          expect(ReminderType.values, contains(n.remindAs),
              reason: '$s ${n.title}');
          expect(repeatForNeed(n.frequency), isA<RepeatRule>());
        }
      }
    });

    test('medicines carry frequency + reminder mapping', () {
      for (final s in Species.values) {
        for (final m in careFor(s).medicines) {
          expect(NeedFrequency.values, contains(m.frequency),
              reason: '$s ${m.name}');
          expect(m.warning.isNotEmpty, isTrue, reason: m.name);
          expect(m.doseHint.isNotEmpty, isTrue, reason: m.name);
        }
      }
    });

    test('vaccines carry reminder lead time', () {
      for (final s in Species.values) {
        for (final v in careFor(s).vaccines) {
          expect(v.remindInDays, greaterThan(0), reason: v.name);
        }
      }
    });
  });
}
