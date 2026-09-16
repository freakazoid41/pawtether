import '../models/models.dart';

/// Default care templates auto-seeded on pet create.
/// Each species gets 1 daily CareRoutine + 3-5 Reminders.
/// See idea.md §6.
class CareTemplate {
  final String routineName;
  final String routineEmoji;
  final List<String> routineItems;
  final List<ReminderSeed> reminders;

  const CareTemplate({
    required this.routineName,
    required this.routineEmoji,
    required this.routineItems,
    required this.reminders,
  });
}

class ReminderSeed {
  final String title;
  final ReminderType type;
  final RepeatRule repeat;
  final int daysFromNow;

  const ReminderSeed(this.title, this.type, this.repeat, this.daysFromNow);
}

CareTemplate templateFor(Species species) {
  switch (species) {
    case Species.dog:
      return const CareTemplate(
        routineName: 'Daily dog care',
        routineEmoji: '🐶',
        routineItems: [
          'Fresh water x2',
          'Feed 2x',
          'Walk 2x',
          'Poop pick + paw wipe',
          '10min play / training',
        ],
        reminders: [
          ReminderSeed('Bath / brush', ReminderType.grooming, RepeatRule.weekly, 7),
          ReminderSeed('Bedding wash + toy clean', ReminderType.other, RepeatRule.weekly, 7),
          ReminderSeed('Flea / tick check', ReminderType.medication, RepeatRule.monthly, 30),
          ReminderSeed('Weight check + nail trim', ReminderType.vet, RepeatRule.monthly, 30),
          ReminderSeed('Vet checkup', ReminderType.vet, RepeatRule.none, 180),
        ],
      );
    case Species.cat:
      return const CareTemplate(
        routineName: 'Daily cat care',
        routineEmoji: '🐱',
        routineItems: [
          'Fresh water',
          'Feed 2x',
          'Litter scoop',
          '15min play',
        ],
        reminders: [
          ReminderSeed('Full litter change + box wash', ReminderType.other, RepeatRule.weekly, 7),
          ReminderSeed('Brush + scratcher check', ReminderType.grooming, RepeatRule.weekly, 7),
          ReminderSeed('Flea treatment', ReminderType.medication, RepeatRule.monthly, 30),
          ReminderSeed('Weight + nail trim', ReminderType.vet, RepeatRule.monthly, 30),
          ReminderSeed('Annual vet visit', ReminderType.vet, RepeatRule.none, 365),
        ],
      );
    case Species.budgie:
      return const CareTemplate(
        routineName: 'Daily budgie care',
        routineEmoji: '🐦',
        routineItems: [
          'Water change',
          'Seed + veg',
          'Cage paper check',
          'Droppings glance',
          '30min out / social',
        ],
        reminders: [
          ReminderSeed('Full cage clean', ReminderType.other, RepeatRule.weekly, 7),
          ReminderSeed('Perches / toys disinfect + bath water', ReminderType.grooming, RepeatRule.weekly, 7),
          ReminderSeed('Beak / nail / weight check', ReminderType.vet, RepeatRule.monthly, 30),
          ReminderSeed('Daylight 10-12h audit', ReminderType.other, RepeatRule.monthly, 30),
          ReminderSeed('Avian vet visit', ReminderType.vet, RepeatRule.none, 365),
        ],
      );
    case Species.parrot:
      return const CareTemplate(
        routineName: 'Daily parrot care',
        routineEmoji: '🦜',
        routineItems: [
          'Fresh water',
          'Pellets + fruit / veg',
          'Cage spot-clean shit trays',
          '1-2h social / out',
          'Mental toy rotate',
        ],
        reminders: [
          ReminderSeed('Deep cage clean', ReminderType.other, RepeatRule.weekly, 7),
          ReminderSeed('Shower / mist + toy safety check', ReminderType.grooming, RepeatRule.weekly, 7),
          ReminderSeed('Weight + beak / feather check', ReminderType.vet, RepeatRule.monthly, 30),
          ReminderSeed('Avian vet checkup', ReminderType.vet, RepeatRule.none, 180),
        ],
      );
    case Species.rabbit:
      return const CareTemplate(
        routineName: 'Daily rabbit care',
        routineEmoji: '🐰',
        routineItems: [
          'Hay refill + pellets',
          'Fresh water',
          'Litter scoop',
          'Greens + forage',
          'Free-roam / binkies',
        ],
        reminders: [
          ReminderSeed('Full hutch clean', ReminderType.other, RepeatRule.weekly, 7),
          ReminderSeed('Brush + nail check', ReminderType.grooming, RepeatRule.weekly, 7),
          ReminderSeed('Weight + teeth check', ReminderType.vet, RepeatRule.monthly, 30),
          ReminderSeed('Rabbit vet checkup', ReminderType.vet, RepeatRule.none, 180),
        ],
      );
    case Species.fish:
      return const CareTemplate(
        routineName: 'Daily fish care',
        routineEmoji: '🐟',
        routineItems: [
          'Feed (pinch, no leftovers)',
          'Water glance: clear + filter on',
          'Light 8-10h check',
          'Behavior watch',
        ],
        reminders: [
          ReminderSeed('Partial water change', ReminderType.other, RepeatRule.weekly, 7),
          ReminderSeed('Filter rinse + glass wipe', ReminderType.grooming, RepeatRule.weekly, 7),
          ReminderSeed('Water test (ammonia/nitrite)', ReminderType.vet, RepeatRule.monthly, 30),
          ReminderSeed('Aquatic vet / shop check', ReminderType.vet, RepeatRule.none, 365),
        ],
      );
    case Species.other:
      return const CareTemplate(
        routineName: 'Daily care',
        routineEmoji: '🐾',
        routineItems: [
          'Fresh water',
          'Feed',
          'Clean habitat',
          'Play / social time',
        ],
        reminders: [
          ReminderSeed('Deep clean habitat', ReminderType.other, RepeatRule.weekly, 7),
          ReminderSeed('Weight check', ReminderType.vet, RepeatRule.monthly, 30),
          ReminderSeed('Vet checkup', ReminderType.vet, RepeatRule.none, 180),
        ],
      );
  }
}

/// Builds a CareRoutine + Reminders for [petId]. Caller persists via AppProvider.
({CareRoutine routine, List<Reminder> reminders}) buildSeedFor(
  String petId,
  Species species,
) {
  final t = templateFor(species);
  final now = DateTime.now();
  final routine = CareRoutine(
    petId: petId,
    name: t.routineName,
    emoji: t.routineEmoji,
    items: [for (final title in t.routineItems) RoutineItem(title: title)],
  );
  final reminders = [
    for (final s in t.reminders)
      Reminder(
        petId: petId,
        title: s.title,
        type: s.type,
        date: DateTime(now.year, now.month, now.day, 9, 0)
            .add(Duration(days: s.daysFromNow)),
        repeat: s.repeat,
      ),
  ];
  return (routine: routine, reminders: reminders);
}
