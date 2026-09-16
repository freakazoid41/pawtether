import '../models/models.dart';

/// Hand-drawn species portraits (rounded, transparent corners).
/// Sources: `icons/animals/Image*.png` → `assets/species/sp_*.png`.
/// Returns null for [Species.other] — callers fall back to the 🐾 emoji.
class SpeciesArt {
  SpeciesArt._();

  static String? of(Species s) => switch (s) {
        Species.dog => 'assets/species/sp_dog.png',
        Species.cat => 'assets/species/sp_cat.png',
        Species.budgie => 'assets/species/sp_budgie.png',
        Species.parrot => 'assets/species/sp_parrot.png',
        Species.rabbit => 'assets/species/sp_rabbit.png',
        Species.fish => 'assets/species/sp_fish.png',
        Species.other => null,
      };
}
