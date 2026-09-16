import 'package:uuid/uuid.dart';

const _uuid = Uuid();

DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse(v as String);

String? _encode(DateTime? v) => v?.toIso8601String();

/* ============================ Vaccine ============================ */
class Vaccine {
  final String id;
  final String petId;
  final String name;
  final DateTime date;
  final DateTime? nextDue;
  final String vet;
  final String notes;

  Vaccine({
    String? id,
    required this.petId,
    required this.name,
    required this.date,
    this.nextDue,
    this.vet = '',
    this.notes = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'name': name,
        'date': _encode(date),
        'nextDue': _encode(nextDue),
        'vet': vet,
        'notes': notes,
      };

  factory Vaccine._fromMap(Map<String, dynamic> m) => Vaccine(
        id: m['id'] as String,
        petId: m['petId'] as String,
        name: m['name'] as String,
        date: _date(m['date']) ?? DateTime.now(),
        nextDue: _date(m['nextDue']),
        vet: (m['vet'] as String?) ?? '',
        notes: (m['notes'] as String?) ?? '',
      );

  static Vaccine fromMap(Map<String, dynamic> m) => Vaccine._fromMap(m);
}

/* ============================ Medication ============================ */
class Medication {
  final String id;
  final String petId;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String notes;

  Medication({
    String? id,
    required this.petId,
    required this.name,
    this.dosage = '',
    this.frequency = 'Daily',
    required this.startDate,
    this.endDate,
    this.notes = '',
  }) : id = id ?? _uuid.v4();

  bool get isActive {
    final now = DateTime.now();
    if (endDate != null && endDate!.isBefore(now)) return false;
    return true;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'startDate': _encode(startDate),
        'endDate': _encode(endDate),
        'notes': notes,
      };

  factory Medication.fromMap(Map<String, dynamic> m) => Medication(
        id: m['id'] as String,
        petId: m['petId'] as String,
        name: m['name'] as String,
        dosage: (m['dosage'] as String?) ?? '',
        frequency: (m['frequency'] as String?) ?? 'Daily',
        startDate: _date(m['startDate']) ?? DateTime.now(),
        endDate: _date(m['endDate']),
        notes: (m['notes'] as String?) ?? '',
      );
}

/* ============================ Vet Visit ============================ */
class VetVisit {
  final String id;
  final String petId;
  final DateTime date;
  final String reason;
  final String vetName;
  final String diagnosis;
  final double cost;
  final String notes;

  VetVisit({
    String? id,
    required this.petId,
    required this.date,
    required this.reason,
    this.vetName = '',
    this.diagnosis = '',
    this.cost = 0,
    this.notes = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'date': _encode(date),
        'reason': reason,
        'vetName': vetName,
        'diagnosis': diagnosis,
        'cost': cost,
        'notes': notes,
      };

  factory VetVisit.fromMap(Map<String, dynamic> m) => VetVisit(
        id: m['id'] as String,
        petId: m['petId'] as String,
        date: _date(m['date']) ?? DateTime.now(),
        reason: (m['reason'] as String?) ?? '',
        vetName: (m['vetName'] as String?) ?? '',
        diagnosis: (m['diagnosis'] as String?) ?? '',
        cost: ((m['cost'] as num?) ?? 0).toDouble(),
        notes: (m['notes'] as String?) ?? '',
      );
}

/* ============================ Weight Entry ============================ */
class WeightEntry {
  final String id;
  final String petId;
  final DateTime date;
  final double weight;
  final String notes;

  WeightEntry({
    String? id,
    required this.petId,
    required this.date,
    required this.weight,
    this.notes = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'date': _encode(date),
        'weight': weight,
        'notes': notes,
      };

  factory WeightEntry.fromMap(Map<String, dynamic> m) => WeightEntry(
        id: m['id'] as String,
        petId: m['petId'] as String,
        date: _date(m['date']) ?? DateTime.now(),
        weight: ((m['weight'] as num?) ?? 0).toDouble(),
        notes: (m['notes'] as String?) ?? '',
      );
}

/* ============================ Symptom Entry ============================ */
class SymptomEntry {
  final String id;
  final String petId;
  final DateTime date;
  final String symptom;
  final int severity; // 1-5
  final String notes;

  SymptomEntry({
    String? id,
    required this.petId,
    required this.date,
    required this.symptom,
    this.severity = 1,
    this.notes = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'petId': petId,
        'date': _encode(date),
        'symptom': symptom,
        'severity': severity,
        'notes': notes,
      };

  factory SymptomEntry.fromMap(Map<String, dynamic> m) => SymptomEntry(
        id: m['id'] as String,
        petId: m['petId'] as String,
        date: _date(m['date']) ?? DateTime.now(),
        symptom: (m['symptom'] as String?) ?? '',
        severity: ((m['severity'] as num?) ?? 1).toInt(),
        notes: (m['notes'] as String?) ?? '',
      );
}