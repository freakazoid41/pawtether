import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// How often a special need recurs.
enum NeedFrequency { daily, weekly, monthly, periodic }

/// A species-specific special need (guide content, English base like seeds).
/// Now actionable: each need knows which QuickLog type it maps to and
/// which ReminderType a "Remind me" tap should create.
class SpeciesNeed {
  final String icon;
  final String title;
  final String detail;
  final NeedFrequency frequency;
  final CareType quickLog;
  final ReminderType remindAs;

  const SpeciesNeed({
    required this.icon,
    required this.title,
    required this.detail,
    required this.frequency,
    this.quickLog = CareType.other,
    this.remindAs = ReminderType.other,
  });
}

/// A commonly used medicine / preventive for the species.
/// Guide only — always confirm with a vet (see disclaimer in UI).
class SpeciesMedicine {
  final String name;
  final String use;
  final String doseHint;
  final String warning;
  final NeedFrequency frequency;
  final ReminderType remindAs;

  const SpeciesMedicine({
    required this.name,
    required this.use,
    required this.doseHint,
    required this.warning,
    this.frequency = NeedFrequency.monthly,
    this.remindAs = ReminderType.medication,
  });
}

class SpeciesVaccine {
  final String name;
  final String schedule;
  final int remindInDays;
  final bool loggable;

  const SpeciesVaccine({
    required this.name,
    required this.schedule,
    this.remindInDays = 30,
    this.loggable = true,
  });
}

/// Full care profile per species.
class SpeciesCare {
  final Species species;
  final String emoji;
  final Color tint;
  final String tagline;
  final List<SpeciesNeed> needs;
  final List<SpeciesMedicine> medicines;
  final List<SpeciesVaccine> vaccines;
  final List<String> toxicFoods;

  const SpeciesCare({
    required this.species,
    required this.emoji,
    required this.tint,
    required this.tagline,
    required this.needs,
    required this.medicines,
    required this.vaccines,
    required this.toxicFoods,
  });
}

SpeciesCare careFor(Species s) {
  switch (s) {
    case Species.dog:
      return const SpeciesCare(
        species: Species.dog,
        emoji: '🐶',
        tint: AppColors.dog,
        tagline: 'Loyal runner — walks, training and nose work keep them happy.',
        needs: [
          SpeciesNeed(
              icon: '🚶',
              title: 'Walk 2x + sniff time',
              detail:
                  'At least 2 walks a day with 10 min of free sniffing. Sniffing tires them more than distance.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.walking,
              remindAs: ReminderType.walking),
          SpeciesNeed(
              icon: '🦷',
              title: 'Dental care',
              detail:
                  'Brush teeth 3x a week or give dental chews. Bad breath + red gums = vet visit.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.grooming),
          SpeciesNeed(
              icon: '🧸',
              title: 'Mental training',
              detail:
                  '10 min of sit/stay/recall games. Bored dogs chew furniture — tired brains behave.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.other,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🛁',
              title: 'Coat + paws',
              detail:
                  'Brush weekly, wipe paws after walks (salt/dirt). Trim nails when you hear clicking.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.grooming),
          SpeciesNeed(
              icon: '🦟',
              title: 'Parasite shield',
              detail:
                  'Monthly flea/tick spot-on + deworm every 3 months. Check ears for scratching.',
              frequency: NeedFrequency.monthly,
              quickLog: CareType.medication,
              remindAs: ReminderType.medication),
          SpeciesNeed(
              icon: '⚖️',
              title: 'Weight + nail audit',
              detail:
                  'Weigh monthly, log it in PawTether. Nails clicking on floor = trim week. Sudden gain/loss = vet.',
              frequency: NeedFrequency.monthly,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
        ],
        medicines: [
          SpeciesMedicine(
              name: 'Flea/tick spot-on (fipronil)',
              use: 'Monthly external parasites',
              doseHint: 'By weight pipette, on neck skin',
              warning: 'Never use cat products on dogs and vice versa.',
              frequency: NeedFrequency.monthly),
          SpeciesMedicine(
              name: 'Dewormer (milbemycin/praziquantel)',
              use: 'Intestinal worms, every 3 months',
              doseHint: 'Tablet by weight, with food',
              warning: 'Repeat after 2 weeks on first puppy dose.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Joint support (glucosamine)',
              use: 'Big/older dogs, stiff mornings',
              doseHint: 'Daily chew per label',
              warning: 'Not a painkiller — limping needs a vet.',
              frequency: NeedFrequency.daily),
          SpeciesMedicine(
              name: 'Ear cleaner',
              use: 'Floppy ears, head shaking',
              doseHint: 'Weekly flush + dry',
              warning: 'Stop if discharge smells bad — see vet.',
              frequency: NeedFrequency.weekly),
          SpeciesMedicine(
              name: 'Probiotic paste (canine)',
              use: 'Soft stool after stress / diet change',
              doseHint: 'Syringe by weight, 2–3 days',
              warning: 'Bloody diarrhea or lethargy = vet now, not probiotics.',
              frequency: NeedFrequency.periodic),
        ],
        vaccines: [
          SpeciesVaccine(name: 'DHPP (distemper/parvo)', schedule: 'Puppy series + yearly booster', remindInDays: 30),
          SpeciesVaccine(name: 'Rabies', schedule: 'From 12 weeks, per law', remindInDays: 30),
          SpeciesVaccine(name: 'Leptospirosis', schedule: 'Yearly, if outdoors/water', remindInDays: 30),
          SpeciesVaccine(name: 'Kennel cough', schedule: 'Before boarding/daycare', remindInDays: 14),
        ],
        toxicFoods: ['Chocolate', 'Grapes & raisins', 'Onion & garlic', 'Xylitol gum', 'Macadamia', 'Cooked bones'],
      );
    case Species.cat:
      return const SpeciesCare(
        species: Species.cat,
        emoji: '🐱',
        tint: AppColors.cat,
        tagline: 'Independent queen — clean litter, high perches and night zoomies.',
        needs: [
          SpeciesNeed(
              icon: '🧹',
              title: 'Litter ritual',
              detail:
                  'Scoop daily, full change weekly. One box per cat + one extra. Smelly box = pee outside it.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.potty,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '💧',
              title: 'Water flow',
              detail:
                  'Cats prefer running water. Fountain + wet food protect kidneys. Wash bowl daily.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.water,
              remindAs: ReminderType.feeding),
          SpeciesNeed(
              icon: '🐾',
              title: 'Scratch + climb',
              detail:
                  'Tall scratcher near the sofa saves furniture. High shelf = confident cat.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.other,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🎣',
              title: 'Hunt play',
              detail:
                  '2x 10 min wand-toy hunts, best before dinner. No hands as toys — ever.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.other,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '😬',
              title: 'Teeth + hairballs',
              detail:
                  'Brush short-haired weekly, long-haired daily. Frequent vomiting of hairballs = vet.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.grooming),
          SpeciesNeed(
              icon: '⚖️',
              title: 'Weight + litterbox watch',
              detail:
                  'Weigh monthly — cats hide illness. Peeing outside, straining or tiny pees = vet within 24h.',
              frequency: NeedFrequency.monthly,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
        ],
        medicines: [
          SpeciesMedicine(
              name: 'Flea spot-on (selamectin)',
              use: 'Monthly fleas + ear mites',
              doseHint: 'Cat-only pipette, neck skin',
              warning: 'Dog flea products with permethrin KILL cats.',
              frequency: NeedFrequency.monthly),
          SpeciesMedicine(
              name: 'Dewormer (praziquantel/pyrantel)',
              use: 'Worms, every 3–6 months',
              doseHint: 'Tablet/paste by weight',
              warning: 'Outdoor hunters need it more often.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Hairball paste (malt)',
              use: 'Hairballs, dry food cats',
              doseHint: 'Pea-sized, 2–3x a week',
              warning: 'Coughing fits ≠ hairball — check asthma.',
              frequency: NeedFrequency.weekly),
          SpeciesMedicine(
              name: 'Urinary support diet',
              use: 'Straining, frequent peeing',
              doseHint: 'Vet diet + more water',
              warning: 'Male cat unable to pee = EMERGENCY.',
              frequency: NeedFrequency.daily),
          SpeciesMedicine(
              name: 'Ear mite drops (feline)',
              use: 'Head shaking, coffee-ground ears',
              doseHint: 'Vet-confirmed course, both ears',
              warning: 'Never probe deep — ruptured eardrum risk.',
              frequency: NeedFrequency.periodic),
        ],
        vaccines: [
          SpeciesVaccine(name: 'FVRCP (cat flu complex)', schedule: 'Kitten series + yearly/3-yearly', remindInDays: 30),
          SpeciesVaccine(name: 'Rabies', schedule: 'From 12 weeks, per law', remindInDays: 30),
          SpeciesVaccine(name: 'FeLV (leukemia)', schedule: 'Outdoor cats, yearly', remindInDays: 30),
        ],
        toxicFoods: ['Onion & garlic', 'Grapes', 'Alcohol', 'Raw dough', 'Lilies (deadly)', 'Paracetamol (deadly)'],
      );
    case Species.budgie:
      return const SpeciesCare(
        species: Species.budgie,
        emoji: '🐦',
        tint: AppColors.budgie,
        tagline: 'Chatty flock bird — daylight rhythm, millet and mirrors in moderation.',
        needs: [
          SpeciesNeed(
              icon: '☀️',
              title: '10–12h daylight rhythm',
              detail:
                  'Cover the cage at night. Irregular light triggers hormonal plucking and night frights.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.sleep,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🥬',
              title: 'Seed + greens',
              detail:
                  'Quality seed mix + daily leafy veg (spinach, broccoli). Avocado and chocolate kill.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.feeding,
              remindAs: ReminderType.feeding),
          SpeciesNeed(
              icon: '🪶',
              title: 'Droppings glance',
              detail:
                  'Morning check: firm green coil + white. Puffed-up + sleeping all day = avian vet fast.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.potty,
              remindAs: ReminderType.vet),
          SpeciesNeed(
              icon: '🧼',
              title: 'Cage deep clean',
              detail:
                  'Paper change 2–3x a week, full disinfect weekly. No scented sprays near birds.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.potty,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🪞',
              title: 'Social + flight',
              detail:
                  '30+ min talking/out time. Rotate 2–3 toys; mirrors only briefly (obsession risk).',
              frequency: NeedFrequency.daily,
              quickLog: CareType.other,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '⚖️',
              title: 'Weight + beak check',
              detail:
                  'Weigh weekly on kitchen scale (grams). Flaky beak, overgrowth or tail-bob breathing = vet.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
        ],
        medicines: [
          SpeciesMedicine(
              name: 'Mite treatment (ivermectin spot-on)',
              use: 'Scaly face/feet, itching',
              doseHint: 'Avian vet dosed drop',
              warning: 'Never dose from dog/cat products yourself.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Cuttlebone + mineral block',
              use: 'Beak + calcium, always available',
              doseHint: 'Clip to bars, replace worn',
              warning: 'Soft overgrown beak = diet/vet issue.',
              frequency: NeedFrequency.monthly),
          SpeciesMedicine(
              name: 'Probiotic (avian)',
              use: 'After antibiotics / stress',
              doseHint: 'In water per label, fresh daily',
              warning: 'Change treated water every 24h.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Iodine block / supplement',
              use: 'Thyroid health in budgies',
              doseHint: 'As directed, tiny amounts',
              warning: 'Overdosing iodine harms — vet dose only.',
              frequency: NeedFrequency.monthly),
          SpeciesMedicine(
              name: 'Electrolyte (avian)',
              use: 'Heat, travel, loose droppings',
              doseHint: 'Short course in water per label',
              warning: 'Puffed + fluffed over 24h = vet, not just electrolytes.',
              frequency: NeedFrequency.periodic),
        ],
        vaccines: [
          SpeciesVaccine(name: 'No routine vaccines', schedule: 'Quarantine new birds 30 days', remindInDays: 30, loggable: false),
          SpeciesVaccine(name: 'Psittacosis screen', schedule: 'New bird / sneezing / vet advice', remindInDays: 14),
          SpeciesVaccine(name: 'Annual avian wellness', schedule: 'Weight, beak, droppings + nails yearly', remindInDays: 30),
        ],
        toxicFoods: ['Avocado', 'Chocolate', 'Caffeine', 'Onion & garlic', 'Teflon fumes (air!)', 'Scented sprays'],
      );
    case Species.parrot:
      return const SpeciesCare(
        species: Species.parrot,
        emoji: '🦜',
        tint: AppColors.parrot,
        tagline: 'Toddler with feathers — 1–2h company and puzzles or screams.',
        needs: [
          SpeciesNeed(
              icon: '🧠',
              title: 'Forage puzzles',
              detail:
                  'Hide food in paper/toys. A bored parrot plucks — 15 min of foraging beats an hour of sitting.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.feeding,
              remindAs: ReminderType.feeding),
          SpeciesNeed(
              icon: '🚿',
              title: 'Shower / mist',
              detail:
                  'Lukewarm mist 2–3x a week. Dusty species (cockatoo/grey) need it most.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.grooming),
          SpeciesNeed(
              icon: '🌙',
              title: '12h quiet sleep',
              detail:
                  'Separate sleep cage or cover in a quiet room. Sleep-deprived parrots bite and scream.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.sleep,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🌳',
              title: 'Out-of-cage time',
              detail:
                  '1–2h supervised on stand. Ceiling fans off, windows closed, no kitchen (fumes).',
              frequency: NeedFrequency.daily,
              quickLog: CareType.other,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🪵',
              title: 'Beak + nail wear',
              detail:
                  'Natural wood perches + cuttlebone. Overgrown beak/nails = vet trim, not DIY.',
              frequency: NeedFrequency.monthly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.grooming),
          SpeciesNeed(
              icon: '⚖️',
              title: 'Weight + feather check',
              detail:
                  'Weigh weekly in grams and log it. Broken blood feather, tail bob or plucked chest = vet fast.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
        ],
        medicines: [
          SpeciesMedicine(
              name: 'Calcium + vitamin D3 (avian)',
              use: 'African greys / egg-laying hens',
              doseHint: 'Vet-dosed powder on soft food',
              warning: 'Wrong D3 dose damages kidneys — vet only.',
              frequency: NeedFrequency.daily),
          SpeciesMedicine(
              name: 'Aloe mist (bird-safe)',
              use: 'Dry itchy skin, plucking support',
              doseHint: 'Light mist, no perfume',
              warning: 'Plucking is medical + behavioral — vet first.',
              frequency: NeedFrequency.weekly),
          SpeciesMedicine(
              name: 'Probiotic (avian)',
              use: 'After illness / new home stress',
              doseHint: 'Fresh treated water daily',
              warning: 'Teflon/PTFE fumes kill birds — ventilate.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Worming (avian, vet-dosed)',
              use: 'Outdoor aviary birds',
              doseHint: 'Vet schedule, weighed dose',
              warning: 'Never guess parrot doses from mammal meds.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Nail/beak trim (vet)',
              use: 'Overgrowth, snagging perches',
              doseHint: 'Avian vet trim, styptic ready',
              warning: 'Bleeding nail = cornstarch pressure + vet call.',
              frequency: NeedFrequency.periodic),
        ],
        vaccines: [
          SpeciesVaccine(name: 'Polyomavirus', schedule: 'Young birds, vet advice', remindInDays: 30),
          SpeciesVaccine(name: 'Psittacosis / PBFD screen', schedule: 'New bird + annual if flock', remindInDays: 14),
          SpeciesVaccine(name: 'Avian vet check', schedule: 'Every 6–12 months', remindInDays: 30),
        ],
        toxicFoods: ['Avocado', 'Chocolate', 'Caffeine', 'Alcohol', 'Salt & Teflon fumes', 'Lead / zinc toys'],
      );
    case Species.rabbit:
      return const SpeciesCare(
        species: Species.rabbit,
        emoji: '🐰',
        tint: AppColors.rabbit,
        tagline: 'Gentle grazer — endless hay, clean litter and calm floors first.',
        needs: [
          SpeciesNeed(
              icon: '🌾',
              title: 'Hay always + pellets',
              detail: 'Timothy hay unlimited, measured pellets daily. Hay keeps teeth worn and gut moving.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.feeding,
              remindAs: ReminderType.feeding),
          SpeciesNeed(
              icon: '🧹',
              title: 'Litter scoop daily',
              detail: 'Scoop soiled litter daily, full change weekly. Dirty boxes cause sore hocks fast.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.potty,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🦷',
              title: 'Teeth + nail watch',
              detail: 'Front teeth should meet evenly; nails click-free. Drooling or head tilt = rabbit vet now.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.vet),
          SpeciesNeed(
              icon: '🏃',
              title: 'Free-roam + binkies',
              detail: 'Hours of safe floor time daily. Binkies mean joy — cage-only rabbits go stiff and sad.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.walking,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🪮',
              title: 'Brush + shed control',
              detail: 'Brush weekly, daily in molt. Swallowed fur + low hay = deadly GI slowdown.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.grooming),
          SpeciesNeed(
              icon: '🚨',
              title: 'Gut + appetite watch',
              detail: 'No poop or no eating 12h = emergency. Keep critical-care feed + vet number handy.',
              frequency: NeedFrequency.periodic,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
        ],
        medicines: [
          SpeciesMedicine(
              name: 'Critical-care feed',
              use: 'Not eating / GI slowdown (vet-directed)',
              doseHint: 'Syringe tiny + often per vet',
              warning: 'Not eating 12h+ is an emergency — never wait it out.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Saline wound rinse',
              use: 'Minor scratches (vet-approved)',
              doseHint: 'Gentle flush, pat dry',
              warning: 'Bite wounds always need a vet — abscesses hide deep.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Probiotic (rabbit-safe)',
              use: 'After tummy upset/stress',
              doseHint: 'Vet product + dose only',
              warning: 'No human meds — rabbit dosing is species-specific.',
              frequency: NeedFrequency.periodic),
        ],
        vaccines: [
          SpeciesVaccine(name: 'RHDV check', schedule: 'Ask vet: region-dependent', remindInDays: 30),
          SpeciesVaccine(name: 'Rabbit vet check', schedule: 'Yearly + teeth check', remindInDays: 30),
        ],
        toxicFoods: ['Iceberg lettuce', 'Chocolate', 'Yogurt drops', 'Cedar/pine shavings', 'Lead paint / cables'],
      );
    case Species.fish:
      return const SpeciesCare(
        species: Species.fish,
        emoji: '🐟',
        tint: AppColors.fish,
        tagline: 'Quiet water soul — stable water beats fancy gear every time.',
        needs: [
          SpeciesNeed(
              icon: '🐠',
              title: 'Pinch feed, no leftovers',
              detail: 'Feed what vanishes in 2 minutes, 1-2x daily. Leftover food rots into ammonia.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.feeding,
              remindAs: ReminderType.feeding),
          SpeciesNeed(
              icon: '🧪',
              title: 'Water params glance',
              detail: 'Ammonia + nitrite must read zero; nitrate low. Test weekly, daily in new tanks.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.water,
              remindAs: ReminderType.vet),
          SpeciesNeed(
              icon: '💧',
              title: 'Partial water change',
              detail: 'Change 20-30% weekly with dechlorinated, temp-matched water. Never full swaps.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.water,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '🔧',
              title: 'Filter + glass care',
              detail: 'Rinse media in tank water (never tap), wipe glass. A silent filter kills fast.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.grooming,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '💡',
              title: 'Light 8-10h rhythm',
              detail: 'Timer the light 8-10h. More grows algae soup, less melts live plants.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.sleep,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '👀',
              title: 'Behavior + fin watch',
              detail: 'Gasping, clamped fins or white spots = act today: test water, then treat per guide.',
              frequency: NeedFrequency.periodic,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
        ],
        medicines: [
          SpeciesMedicine(
              name: 'Dechlorinator',
              use: 'Every water change',
              doseHint: 'Dose to new water volume',
              warning: 'Untreated tap water burns gills — never skip.',
              frequency: NeedFrequency.weekly),
          SpeciesMedicine(
              name: 'Aquarium salt (freshwater)',
              use: 'Mild stress / nitrite guard (species-safe only)',
              doseHint: 'Label dose, dissolve first',
              warning: 'Scaleless fish + plants hate salt — check before dosing.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Anti-spot treatment',
              use: 'White-spot outbreaks (vet/shop-directed)',
              doseHint: 'Full course, remove carbon',
              warning: 'Half courses breed resistant parasites.',
              frequency: NeedFrequency.periodic),
        ],
        vaccines: [
          SpeciesVaccine(name: 'New-fish quarantine', schedule: '2-4 weeks separate tank', remindInDays: 14),
          SpeciesVaccine(name: 'Aquatic vet / shop review', schedule: 'Yearly or at first symptoms', remindInDays: 30),
        ],
        toxicFoods: ['Soap residue', 'Untreated tap water', 'Overfeeding', 'Copper meds (shrimp/snails)', 'Spray near tank'],
      );
    case Species.other:
      return const SpeciesCare(
        species: Species.other,
        emoji: '🐾',
        tint: AppColors.other,
        tagline: 'Little mystery — stable habitat, clean water and routine first.',
        needs: [
          SpeciesNeed(
              icon: '🏠',
              title: 'Stable habitat',
              detail: 'Same temperature, light and feeding spot. Sudden moves stress small pets most.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.other,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '💧',
              title: 'Fresh water + food',
              detail: 'Change water daily, remove uneaten fresh food after hours.',
              frequency: NeedFrequency.daily,
              quickLog: CareType.feeding,
              remindAs: ReminderType.feeding),
          SpeciesNeed(
              icon: '🧼',
              title: 'Deep clean',
              detail: 'Full habitat clean weekly with pet-safe products, rinse well.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.potty,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '⚖️',
              title: 'Weight watch',
              detail: 'Weigh monthly — silent weight loss is the first sick signal.',
              frequency: NeedFrequency.monthly,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
          SpeciesNeed(
              icon: '🧩',
              title: 'Enrichment rotate',
              detail: 'Swap hides, chews or toys weekly. Bored small pets bar-chew and over-groom.',
              frequency: NeedFrequency.weekly,
              quickLog: CareType.other,
              remindAs: ReminderType.other),
          SpeciesNeed(
              icon: '👀',
              title: 'Appetite + vet watch',
              detail: 'No eating 12–24h, labored breathing or hunched sitting = exotic vet fast.',
              frequency: NeedFrequency.periodic,
              quickLog: CareType.other,
              remindAs: ReminderType.vet),
        ],
        medicines: [
          SpeciesMedicine(
              name: 'Saline wound rinse',
              use: 'Minor scratches (vet-approved)',
              doseHint: 'Gentle flush, pat dry',
              warning: 'Bite wounds always need a vet — infections hide.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Probiotic (species-safe)',
              use: 'After tummy upset/stress',
              doseHint: 'Vet product + dose only',
              warning: 'No human meds without exotic-vet dosing.',
              frequency: NeedFrequency.periodic),
          SpeciesMedicine(
              name: 'Critical-care feed (herbivores)',
              use: 'Not eating, post-illness (rabbits/guinea pigs)',
              doseHint: 'Syringe per vet, tiny + often',
              warning: 'Not eating 12h+ = emergency, not wait-and-see.',
              frequency: NeedFrequency.periodic),
        ],
        vaccines: [
          SpeciesVaccine(name: 'Exotic vet check', schedule: 'Yearly, or sooner if appetite drops', remindInDays: 30),
          SpeciesVaccine(name: 'Parasite screen', schedule: 'New pet + yearly if outdoors/bedding', remindInDays: 30),
        ],
        toxicFoods: ['Human sweets', 'Scented cleaners', 'Smoke & strong perfume', 'Cedar/pine dust (small pets)'],
      );
  }
}

/// Maps a need frequency to the reminder repeat it should create.
RepeatRule repeatForNeed(NeedFrequency f) => switch (f) {
      NeedFrequency.daily => RepeatRule.daily,
      NeedFrequency.weekly => RepeatRule.weekly,
      NeedFrequency.monthly => RepeatRule.monthly,
      NeedFrequency.periodic => RepeatRule.none,
    };
