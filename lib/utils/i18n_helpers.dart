import 'package:easy_localization/easy_localization.dart';

import '../models/models.dart';

String speciesLabelTr(Species s) => switch (s) {
      Species.dog => 'species_dog'.tr(),
      Species.cat => 'species_cat'.tr(),
      Species.budgie => 'species_budgie'.tr(),
      Species.parrot => 'species_parrot'.tr(),
      Species.rabbit => 'species_rabbit'.tr(),
      Species.fish => 'species_fish'.tr(),
      Species.other => 'species_other'.tr(),
    };

/// Display-time translation of canonical English seed strings.
/// Seeds (routines, reminders, quick-log details) are stored in English so
/// rows stay stable across locale switches; this renders known strings in
/// the active locale. Custom/unknown text passes through untouched.
String seedTr(String s) {
  final key = _seedKeys[s];
  if (key == null) return s;
  return key.tr();
}

const Map<String, String> _seedKeys = {
  // Daily routine names.
  'Daily dog care': 'seed_routine_dog',
  'Daily cat care': 'seed_routine_cat',
  'Daily budgie care': 'seed_routine_budgie',
  'Daily parrot care': 'seed_routine_parrot',
  'Daily rabbit care': 'seed_routine_rabbit',
  'Daily fish care': 'seed_routine_fish',
  'Daily care': 'seed_routine_other',
  // Routine items.
  'Fresh water x2': 'seed_water_x2',
  'Feed 2x': 'seed_feed_2x',
  'Walk 2x': 'seed_walk_2x',
  'Poop pick + paw wipe': 'seed_poop_pick',
  '10min play / training': 'seed_play_train',
  'Fresh water': 'seed_fresh_water',
  'Litter scoop': 'seed_litter_scoop',
  '15min play': 'seed_play_15',
  'Water change': 'seed_water_change',
  'Seed + veg': 'seed_seed_veg',
  'Cage paper check': 'seed_cage_paper',
  'Droppings glance': 'seed_droppings',
  '30min out / social': 'seed_out_30',
  'Pellets + fruit / veg': 'seed_pellets',
  'Cage spot-clean shit trays': 'seed_spot_clean',
  '1-2h social / out': 'seed_social_12',
  'Mental toy rotate': 'seed_toy_rotate',
  'Hay refill + pellets': 'seed_hay',
  'Greens + forage': 'seed_greens',
  'Free-roam / binkies': 'seed_freeroam',
  'Feed (pinch, no leftovers)': 'seed_feed_pinch',
  'Water glance: clear + filter on': 'seed_water_glance',
  'Light 8-10h check': 'seed_light',
  'Behavior watch': 'seed_behavior',
  'Feed': 'seed_feed',
  'Clean habitat': 'seed_clean_habitat',
  'Play / social time': 'seed_play_social',
  // Seeded reminder titles.
  'Bath / brush': 'seed_bath_brush',
  'Bedding wash + toy clean': 'seed_bedding',
  'Flea / tick check': 'seed_flea_check',
  'Weight check + nail trim': 'seed_weight_nails',
  'Vet checkup': 'seed_vet_checkup',
  'Full litter change + box wash': 'seed_litter_full',
  'Brush + scratcher check': 'seed_brush_scratcher',
  'Flea treatment': 'seed_flea_treat',
  'Weight + nail trim': 'seed_weight_nail',
  'Annual vet visit': 'seed_vet_annual',
  'Full cage clean': 'seed_cage_full',
  'Perches / toys disinfect + bath water': 'seed_perch_disinfect',
  'Beak / nail / weight check': 'seed_beak_check',
  'Daylight 10-12h audit': 'seed_daylight',
  'Avian vet visit': 'seed_vet_avian',
  'Deep cage clean': 'seed_cage_deep',
  'Shower / mist + toy safety check': 'seed_shower_mist',
  'Weight + beak / feather check': 'seed_weight_beak',
  'Avian vet checkup': 'seed_vet_avian_check',
  'Full hutch clean': 'seed_hutch_full',
  'Brush + nail check': 'seed_brush_nails',
  'Weight + teeth check': 'seed_weight_teeth',
  'Rabbit vet checkup': 'seed_vet_rabbit',
  'Partial water change': 'seed_water_partial',
  'Filter rinse + glass wipe': 'seed_filter_rinse',
  'Water test (ammonia/nitrite)': 'seed_water_test',
  'Aquatic vet / shop check': 'seed_vet_aquatic',
  'Deep clean habitat': 'seed_habitat_deep',
  'Weight check': 'seed_weight_check',
  // Quick-log detail picks (canonical storage, localized display).
  'Breakfast': 'ql_opt_breakfast',
  'Lunch': 'ql_opt_lunch',
  'Dinner': 'ql_opt_dinner',
  'Treat': 'ql_opt_treat',
  'Snack': 'ql_opt_snack',
  'Short walk': 'ql_opt_short',
  'Long walk': 'ql_opt_long',
  'Off-leash': 'ql_opt_offleash',
  'Bathroom': 'ql_opt_bathroom',
  'Pee': 'ql_opt_pee',
  'Poo': 'ql_opt_poo',
  'Both': 'ql_opt_both',
  'Pill': 'ql_opt_pill',
  'Liquid': 'ql_opt_liquid',
  'Injection': 'ql_opt_injection',
  'Topical': 'ql_opt_topical',
  'Filled bowl': 'ql_opt_filled',
  'Refilled': 'ql_opt_refilled',
  'Brush': 'ql_opt_brush',
  'Bath': 'ql_opt_bath',
  'Nail trim': 'ql_opt_nails',
  'Ears': 'ql_opt_ears',
  'Nap': 'ql_opt_nap',
  'Night sleep': 'ql_opt_night',
  'Other': 'ql_opt_other',
};

String careTypeLabelTr(CareType t) => switch (t) {
      CareType.feeding => 'qa_feed'.tr(),
      CareType.water => 'qa_water'.tr(),
      CareType.walking => 'qa_walk'.tr(),
      CareType.potty => 'qa_clean'.tr(),
      CareType.medication => 'qa_meds'.tr(),
      CareType.grooming => 'qa_groom'.tr(),
      CareType.sleep => 'qa_sleep'.tr(),
      CareType.other => 'qa_other'.tr(),
    };

String reminderTypeTr(ReminderType t) {
  final emoji = switch (t) {
    ReminderType.medication => '💊',
    ReminderType.vaccine => '💉',
    ReminderType.feeding => '🍖',
    ReminderType.walking => '🦮',
    ReminderType.grooming => '✂️',
    ReminderType.vet => '🏥',
    ReminderType.other => '📌',
  };
  final label = switch (t) {
    ReminderType.medication => 'remtype_medication'.tr(),
    ReminderType.vaccine => 'remtype_vaccine'.tr(),
    ReminderType.feeding => 'remtype_feeding'.tr(),
    ReminderType.walking => 'remtype_walking'.tr(),
    ReminderType.grooming => 'remtype_grooming'.tr(),
    ReminderType.vet => 'remtype_vet'.tr(),
    ReminderType.other => 'remtype_other'.tr(),
  };
  return '$emoji $label';
}

String repeatRuleTr(RepeatRule r) => switch (r) {
      RepeatRule.none => 'remrep_once'.tr(),
      RepeatRule.daily => 'remrep_daily'.tr(),
      RepeatRule.weekly => 'remrep_weekly'.tr(),
      RepeatRule.monthly => 'remrep_monthly'.tr(),
    };

String expenseCatTr(ExpenseCategory c) => switch (c) {
      ExpenseCategory.food => 'exp_food'.tr(),
      ExpenseCategory.vet => 'exp_vet'.tr(),
      ExpenseCategory.grooming => 'exp_grooming'.tr(),
      ExpenseCategory.supplies => 'exp_supplies'.tr(),
      ExpenseCategory.medication => 'exp_medication'.tr(),
      ExpenseCategory.other => 'exp_other'.tr(),
    };

/// Localized age string.
String petAgeTr(Pet pet) {
  final b = pet.birthday;
  if (b == null) return 'age_unknown'.tr();
  final now = DateTime.now();
  var years = now.year - b.year;
  if (now.month < b.month || (now.month == b.month && now.day < b.day)) {
    years--;
  }
  if (years < 1) {
    final months = (now.year - b.year) * 12 + (now.month - b.month);
    return 'age_months'.tr(namedArgs: {'count': '$months'});
  }
  return 'age_years'.tr(namedArgs: {'count': '$years'});
}
