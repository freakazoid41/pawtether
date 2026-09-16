import 'package:hive_flutter/hive_flutter.dart';

/// AppDatabase holds all Hive boxes.
/// Lists of records are keyed by petId inside each box.
class AppDatabase {
  static const _petBox = 'pets';
  static const _recordBox = 'records';
  static const _logBox = 'care_logs';
  static const _reminderBox = 'reminders';
  static const _docBox = 'documents';
  static const _expenseBox = 'expenses';
  static const _routineBox = 'routines';
  static const _qrBox = 'qr_codes';
  static const _settingsBox = 'settings';

  late final Box<dynamic> pets;
  late final Box<dynamic> records;
  late final Box<dynamic> logs;
  late final Box<dynamic> reminders;
  late final Box<dynamic> docs;
  late final Box<dynamic> expenses;
  late final Box<dynamic> routines;
  late final Box<dynamic> qrCodes;
  late final Box<dynamic> settings;

  Future<void> init() async {
    await Hive.initFlutter('pawtether');
    pets = await Hive.openBox<dynamic>(_petBox);
    records = await Hive.openBox<dynamic>(_recordBox);
    logs = await Hive.openBox<dynamic>(_logBox);
    reminders = await Hive.openBox<dynamic>(_reminderBox);
    docs = await Hive.openBox<dynamic>(_docBox);
    expenses = await Hive.openBox<dynamic>(_expenseBox);
    routines = await Hive.openBox<dynamic>(_routineBox);
    qrCodes = await Hive.openBox<dynamic>(_qrBox);
    settings = await Hive.openBox<dynamic>(_settingsBox);
  }

  /* ---------- Pets ---------- */
  List<Map<String, dynamic>> allPets() {
    final list = <Map<String, dynamic>>[];
    for (final v in pets.values) {
      if (v is Map) list.add(Map<String, dynamic>.from(v));
    }
    return list;
  }

  void putPet(Map<String, dynamic> pet) => pets.put(pet['id'] as String, pet);
  void deletePet(String id) {
    pets.delete(id);
    // Per-pet lists are keyed by petId — drop them too, no orphans.
    records.delete(id);
    logs.delete(id);
    reminders.delete(id);
    docs.delete(id);
    expenses.delete(id);
    routines.delete(id);
  }

  /* ---------- Record lists (vaccines, meds, visits, weight, symptoms) ---------- */
  List<Map<String, dynamic>> recordsFor(String petId, String kind) {
    final raw = records.get(petId);
    final all = (raw as List?) ?? const [];
    return all
        .where((e) => e is Map && e['kind'] == kind)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  void addRecord(String petId, String kind, Map<String, dynamic> record) {
    final all = List<dynamic>.from((records.get(petId) as List?) ?? []);
    record['kind'] = kind;
    all.add(record);
    records.put(petId, all);
  }

  void deleteRecord(String petId, String kind, String id) {
    final all = ((records.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    all.removeWhere((e) => e['kind'] == kind && e['id'] == id);
    records.put(petId, all);
  }

  void putRecord(String petId, String kind, Map<String, dynamic> record) {
    final all = ((records.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    record['kind'] = kind;
    final idx = all.indexWhere((e) => e['kind'] == kind && e['id'] == record['id']);
    if (idx >= 0) {
      all[idx] = record;
    } else {
      all.add(record);
    }
    records.put(petId, all);
  }

  /* ---------- Care logs ---------- */
  List<Map<String, dynamic>> logsFor(String petId) {
    final list = (logs.get(petId) as List?) ?? const [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  void addLog(String petId, Map<String, dynamic> log) {
    final all = List<dynamic>.from((logs.get(petId) as List?) ?? []);
    all.add(log);
    logs.put(petId, all);
  }

  void deleteLog(String petId, String id) {
    final all = ((logs.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    all.removeWhere((e) => e['id'] == id);
    logs.put(petId, all);
  }

  /* ---------- Reminders ---------- */
  List<Map<String, dynamic>> remindersFor(String petId) {
    final r = reminders.get(petId);
    if (r is List) {
      return r.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  void addReminder(String petId, Map<String, dynamic> r) {
    final all = List<dynamic>.from((reminders.get(petId) as List?) ?? []);
    all.add(r);
    reminders.put(petId, all);
  }

  void putReminder(String petId, Map<String, dynamic> r) {
    final all = ((reminders.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final idx = all.indexWhere((e) => e['id'] == r['id']);
    if (idx >= 0) {
      all[idx] = r;
    } else {
      all.add(r);
    }
    reminders.put(petId, all);
  }

  void deleteReminder(String petId, String id) {
    final all = ((reminders.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    all.removeWhere((e) => e['id'] == id);
    reminders.put(petId, all);
  }

  /* ---------- Documents ---------- */
  List<Map<String, dynamic>> docsFor(String petId) {
    final all = ((docs.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    return all;
  }

  void addDoc(String petId, Map<String, dynamic> doc) {
    final all = List<dynamic>.from((docs.get(petId) as List?) ?? []);
    all.add(doc);
    docs.put(petId, all);
  }

  void deleteDoc(String petId, String id) {
    final all = ((docs.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    all.removeWhere((e) => e['id'] == id);
    docs.put(petId, all);
  }

  /* ---------- Settings ---------- */
  String? getString(String key) => settings.get(key) as String?;
  void setString(String key, String value) => settings.put(key, value);
  Object? getObject(String key) => settings.get(key);
  void setObject(String key, Object value) => settings.put(key, value);

  /* ---------- Expenses ---------- */
  List<Map<String, dynamic>> expensesFor(String petId) {
    return ((expenses.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void addExpense(String petId, Map<String, dynamic> e) {
    final all = List<dynamic>.from((expenses.get(petId) as List?) ?? []);
    all.add(e);
    expenses.put(petId, all);
  }

  void deleteExpense(String petId, String id) {
    final all = ((expenses.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    all.removeWhere((e) => e['id'] == id);
    expenses.put(petId, all);
  }

  /* ---------- Routines ---------- */
  List<Map<String, dynamic>> routinesFor(String petId) {
    return ((routines.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void addRoutine(String petId, Map<String, dynamic> r) {
    final all = List<dynamic>.from((routines.get(petId) as List?) ?? []);
    all.add(r);
    routines.put(petId, all);
  }

  void putRoutine(String petId, Map<String, dynamic> r) {
    final all = ((routines.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final idx = all.indexWhere((e) => e['id'] == r['id']);
    if (idx >= 0) {
      all[idx] = r;
    } else {
      all.add(r);
    }
    routines.put(petId, all);
  }

  void deleteRoutine(String petId, String id) {
    final all = ((routines.get(petId) as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    all.removeWhere((e) => e['id'] == id);
    routines.put(petId, all);
  }

  /* ---------- QR code knowledge (code -> product name) ---------- */
  Map<String, dynamic> qrKnowledge() {
    final out = <String, dynamic>{};
    for (final k in qrCodes.keys) {
      out[k as String] = qrCodes.get(k);
    }
    return out;
  }

  void rememberQrCode(String code, String name) {
    qrCodes.put(code, name);
  }
}