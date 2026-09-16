import 'package:uuid/uuid.dart';

enum Species { dog, cat, budgie, parrot, rabbit, fish, other }

Species speciesFromString(String? v) {
  switch (v) {
    case 'cat':
      return Species.cat;
    case 'budgie':
      return Species.budgie;
    case 'parrot':
      return Species.parrot;
    case 'rabbit':
      return Species.rabbit;
    case 'fish':
      return Species.fish;
    case 'other':
      return Species.other;
    case 'dog':
      return Species.dog;
    default:
      return Species.other;
  }
}

class Pet {
  final String id;
  String name;
  Species species;
  String breed;
  DateTime? birthday;
  String gender;
  double weightKg;
  String microchip;
  String imagePath;
  String personalityNotes;
  List<String> allergies;
  bool isFavorite;
  DateTime createdAt;

  Pet({
    String? id,
    required this.name,
    required this.species,
    this.breed = '',
    this.birthday,
    this.gender = 'Unknown',
    this.weightKg = 0,
    this.microchip = '',
    this.imagePath = '',
    this.personalityNotes = '',
    List<String>? allergies,
    this.isFavorite = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        allergies = allergies ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get speciesEmoji => switch (species) {
        Species.cat => '🐱',
        Species.dog => '🐶',
        Species.budgie => '🐦',
        Species.parrot => '🦜',
        Species.rabbit => '🐰',
        Species.fish => '🐟',
        Species.other => '🐾',
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'species': species.name,
        'breed': breed,
        'birthday': birthday?.toIso8601String(),
        'gender': gender,
        'weightKg': weightKg,
        'microchip': microchip,
        'imagePath': imagePath,
        'personalityNotes': personalityNotes,
        'allergies': allergies,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Pet.fromMap(Map<String, dynamic> m) => Pet(
        id: m['id'] as String,
        name: m['name'] as String,
        species: speciesFromString(m['species'] as String?),
        breed: (m['breed'] as String?) ?? '',
        birthday: m['birthday'] != null
            ? DateTime.tryParse(m['birthday'] as String)
            : null,
        gender: (m['gender'] as String?) ?? 'Unknown',
        weightKg: ((m['weightKg'] as num?) ?? 0).toDouble(),
        microchip: (m['microchip'] as String?) ?? '',
        imagePath: (m['imagePath'] as String?) ?? '',
        personalityNotes: (m['personalityNotes'] as String?) ?? '',
        allergies: ((m['allergies'] as List?) ?? [])
            .map((e) => e.toString())
            .toList(),
        isFavorite: (m['isFavorite'] as bool?) ?? false,
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
