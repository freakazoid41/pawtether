import 'package:flutter/material.dart';

import '../data/care_templates.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../storage/app_database.dart';

class AppProvider extends ChangeNotifier {
  final AppDatabase _db;
  List<Pet> _pets = [];
  String? _currentPetId;

  // cached maps petId -> list
  final Map<String, List<Vaccine>> _vaccines = {};
  final Map<String, List<Medication>> _medications = {};
  final Map<String, List<VetVisit>> _visits = {};
  final Map<String, List<WeightEntry>> _weights = {};
  final Map<String, List<SymptomEntry>> _symptoms = {};
  final Map<String, List<CareLogEntry>> _logs = {};
  final Map<String, List<Reminder>> _reminders = {};
  final Map<String, List<MedicalDocument>> _docs = {};
  final Map<String, List<Expense>> _expenses = {};
  final Map<String, List<CareRoutine>> _routines = {};
  Map<String, dynamic> _qrKnowledge = {};

  bool initialized = false;

  AppProvider(this._db);

  AppDatabase get db => _db;
  List<Pet> get pets => List.unmodifiable(_pets);
  String? get currentPetId => _currentPetId;

  Pet? get currentPet {
    if (_currentPetId == null) return null;
    for (final p in _pets) {
      if (p.id == _currentPetId) return p;
    }
    return null;
  }

  List<Pet> get favorites => _pets.where((p) => p.isFavorite).toList();

  List<T> _listFor<T>(Map<String, List<T>> map, String petId) =>
      map[petId] ?? const [];

  List<Vaccine> vaccines(Pet pet) => _listFor(_vaccines, pet.id);
  List<Medication> medications(Pet pet) => _listFor(_medications, pet.id);
  List<VetVisit> visits(Pet pet) => _listFor(_visits, pet.id);
  List<WeightEntry> weights(Pet pet) => _listFor(_weights, pet.id);
  List<SymptomEntry> symptoms(Pet pet) => _listFor(_symptoms, pet.id);
  List<CareLogEntry> logs(Pet pet) => _listFor(_logs, pet.id);
  List<Reminder> reminders(Pet pet) => _listFor(_reminders, pet.id);
  List<MedicalDocument> documents(Pet pet) => _listFor(_docs, pet.id);
  List<Expense> expenses(Pet pet) => _listFor(_expenses, pet.id);
  List<CareRoutine> routines(Pet pet) => _listFor(_routines, pet.id);

  List<Reminder> remindersForAll() {
    final out = <Reminder>[];
    for (final pet in _pets) {
      out.addAll(_reminders[pet.id] ?? const []);
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  CareLogEntry? todayDone(Pet pet, CareType type) {
    for (final log in _logs[pet.id] ?? const <CareLogEntry>[]) {
      if (log.type == type && log.isToday()) return log;
    }
    return null;
  }

  bool get hasPets => _pets.isNotEmpty;

  // ---------- Loading ----------
  void loadAll() {
    _pets = _db.allPets().map(Pet.fromMap).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (_pets.isNotEmpty && (_currentPetId == null ||
        !pets.any((p) => p.id == _currentPetId))) {
      _currentPetId = favorites.isNotEmpty ? favorites.first.id : _pets.first.id;
    }
    for (final pet in _pets) {
      _loadFor(pet.id);
    }
    _qrKnowledge = _db.qrKnowledge();
    notifyListeners();
  }

  void _loadFor(String petId) {
    _vaccines[petId] = _db
        .recordsFor(petId, 'vaccine')
        .map(Vaccine.fromMap)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _medications[petId] =
        _db.recordsFor(petId, 'medication').map(Medication.fromMap).toList();
    _visits[petId] = _db
        .recordsFor(petId, 'visit')
        .map(VetVisit.fromMap)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _weights[petId] = _db
        .recordsFor(petId, 'weight')
        .map(WeightEntry.fromMap)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _symptoms[petId] = _db
        .recordsFor(petId, 'symptom')
        .map(SymptomEntry.fromMap)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _logs[petId] = _db.logsFor(petId).map(CareLogEntry.fromMap).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    _reminders[petId] =
        _db.remindersFor(petId).map(Reminder.fromMap).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    _docs[petId] =
        _db.docsFor(petId).map(MedicalDocument.fromMap).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _expenses[petId] = _db.expensesFor(petId).map(Expense.fromMap).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _routines[petId] =
        _db.routinesFor(petId).map(CareRoutine.fromMap).toList();
  }

  // ---------- Pet CRUD ----------
  void addPet(Pet pet, {bool seedDefaults = true}) {
    _db.putPet(pet.toMap());
    _pets.add(pet);
    _currentPetId = pet.id;
    if (seedDefaults) seedDefaultsFor(pet);
    notifyListeners();
  }

  /// Auto-creates 1 daily CareRoutine + 3-5 Reminders per species template.
  /// Skips seeding if the pet already has routines/reminders (e.g. re-import).
  void seedDefaultsFor(Pet pet) {
    final hasRoutines = (_routines[pet.id] ?? const []).isNotEmpty;
    final hasReminders = (_reminders[pet.id] ?? const []).isNotEmpty;
    if (hasRoutines || hasReminders) return;
    final seed = buildSeedFor(pet.id, pet.species);
    addRoutine(pet, seed.routine);
    for (final r in seed.reminders) {
      addReminder(pet, r);
    }
  }

  void updatePet(Pet pet) {
    _db.putPet(pet.toMap());
    final i = _pets.indexWhere((p) => p.id == pet.id);
    if (i >= 0) _pets[i] = pet;
    notifyListeners();
  }

  void deletePet(Pet pet) {
    _db.deletePet(pet.id);
    _pets.removeWhere((p) => p.id == pet.id);
    for (final box in [
      _vaccines, _medications, _visits, _weights, _symptoms,
      _logs, _reminders, _docs, _expenses, _routines,
    ]) {
      box.remove(pet.id);
    }
    if (_currentPetId == pet.id) {
      _currentPetId = _pets.isEmpty ? null : _pets.first.id;
    }
    notifyListeners();
    refreshNotifications();
  }

  void setCurrentPet(String? id) {
    _currentPetId = id;
    notifyListeners();
  }

  // ---------- Records ----------
  void addVaccine(Pet pet, Vaccine v) {
    _db.addRecord(pet.id, 'vaccine', v.toMap());
    (_vaccines[pet.id] ??= []).insert(0, v);
    notifyListeners();
    refreshNotifications();
  }

  void updateVaccine(Pet pet, Vaccine v) {
    _db.putRecord(pet.id, 'vaccine', v.toMap());
    final list = _vaccines[pet.id] ??= [];
    final i = list.indexWhere((x) => x.id == v.id);
    if (i >= 0) list[i] = v;
    notifyListeners();
  }

  void deleteVaccine(Pet pet, Vaccine v) {
    _db.deleteRecord(pet.id, 'vaccine', v.id);
    _vaccines[pet.id]?.removeWhere((list) => list.id == v.id);
    notifyListeners();
  }

  void addMedication(Pet pet, Medication m) {
    _db.addRecord(pet.id, 'medication', m.toMap());
    (_medications[pet.id] ??= []).add(m);
    notifyListeners();
  }

  void updateMedication(Pet pet, Medication m) {
    _db.putRecord(pet.id, 'medication', m.toMap());
    final list = _medications[pet.id] ??= [];
    final i = list.indexWhere((x) => x.id == m.id);
    if (i >= 0) list[i] = m;
    notifyListeners();
  }

  void deleteMedication(Pet pet, Medication m) {
    _db.deleteRecord(pet.id, 'medication', m.id);
    _medications[pet.id]?.removeWhere((x) => x.id == m.id);
    notifyListeners();
  }

  void addVisit(Pet pet, VetVisit v) {
    _db.addRecord(pet.id, 'visit', v.toMap());
    (_visits[pet.id] ??= []).insert(0, v);
    notifyListeners();
  }

  void updateVisit(Pet pet, VetVisit v) {
    _db.putRecord(pet.id, 'visit', v.toMap());
    final list = _visits[pet.id] ??= [];
    final i = list.indexWhere((x) => x.id == v.id);
    if (i >= 0) {
      list[i] = v;
    } else {
      list.insert(0, v);
    }
    notifyListeners();
  }

  void deleteVisit(Pet pet, VetVisit v) {
    _db.deleteRecord(pet.id, 'visit', v.id);
    _visits[pet.id]?.removeWhere((x) => x.id == v.id);
    notifyListeners();
  }

  void addWeight(Pet pet, WeightEntry w) {
    _db.addRecord(pet.id, 'weight', w.toMap());
    (_weights[pet.id] ??= []).insert(0, w);
    pet.weightKg = w.weight;
    updatePet(pet);
  }

  void deleteWeight(Pet pet, WeightEntry w) {
    _db.deleteRecord(pet.id, 'weight', w.id);
    _weights[pet.id]?.removeWhere((x) => x.id == w.id);
    notifyListeners();
  }

  void addSymptom(Pet pet, SymptomEntry s) {
    _db.addRecord(pet.id, 'symptom', s.toMap());
    (_symptoms[pet.id] ??= []).insert(0, s);
    notifyListeners();
  }

  void deleteSymptom(Pet pet, SymptomEntry s) {
    _db.deleteRecord(pet.id, 'symptom', s.id);
    _symptoms[pet.id]?.removeWhere((x) => x.id == s.id);
    notifyListeners();
  }

  // ---------- Care logs ----------
  void addLog(Pet pet, CareLogEntry log) {
    _db.addLog(pet.id, log.toMap());
    (_logs[pet.id] ??= []).insert(0, log);
    notifyListeners();
  }

  void deleteLog(Pet pet, CareLogEntry log) {
    _db.deleteLog(pet.id, log.id);
    _logs[pet.id]?.removeWhere((x) => x.id == log.id);
    notifyListeners();
  }

  // ---------- Reminders ----------
  void addReminder(Pet pet, Reminder r) {
    _db.addReminder(pet.id, r.toMap());
    (_reminders[pet.id] ??= []).add(r);
    notifyListeners();
    refreshNotifications();
  }

  void updateReminder(Pet pet, Reminder r) {
    _db.putReminder(pet.id, r.toMap());
    final list = _reminders[pet.id] ??= [];
    final i = list.indexWhere((x) => x.id == r.id);
    if (i >= 0) list[i] = r;
    notifyListeners();
    refreshNotifications();
  }

  void deleteReminder(Pet pet, Reminder r) {
    _db.deleteReminder(pet.id, r.id);
    _reminders[pet.id]?.removeWhere((x) => x.id == r.id);
    notifyListeners();
    refreshNotifications();
  }

  /// Marks a reminder done: one-time reminders are removed, repeating ones
  /// jump to their next occurrence.
  void completeReminder(Pet pet, Reminder r) {
    if (r.repeat == RepeatRule.none) {
      deleteReminder(pet, r);
      return;
    }
    final next = r.nextOccurrence();
    if (next == null) {
      deleteReminder(pet, r);
    } else {
      updateReminder(pet, r.copyWith(date: next));
    }
  }

  // ---------- Documents ----------
  void addDoc(Pet pet, MedicalDocument doc) {
    _db.addDoc(pet.id, doc.toMap());
    (_docs[pet.id] ??= []).insert(0, doc);
    notifyListeners();
  }

  void deleteDoc(Pet pet, MedicalDocument doc) {
    _db.deleteDoc(pet.id, doc.id);
    _docs[pet.id]?.removeWhere((x) => x.id == doc.id);
    notifyListeners();
  }

  // ---------- Expenses ----------
  void addExpense(Pet pet, Expense e) {
    _db.addExpense(pet.id, e.toMap());
    (_expenses[pet.id] ??= []).insert(0, e);
    notifyListeners();
  }

  void deleteExpense(Pet pet, Expense e) {
    _db.deleteExpense(pet.id, e.id);
    _expenses[pet.id]?.removeWhere((x) => x.id == e.id);
    notifyListeners();
  }

  // ---------- Routines ----------
  void addRoutine(Pet pet, CareRoutine r) {
    _db.addRoutine(pet.id, r.toMap());
    (_routines[pet.id] ??= []).add(r);
    notifyListeners();
  }

  void updateRoutine(Pet pet, CareRoutine r) {
    _db.putRoutine(pet.id, r.toMap());
    final list = _routines[pet.id] ??= [];
    final i = list.indexWhere((x) => x.id == r.id);
    if (i >= 0) list[i] = r;
    notifyListeners();
  }

  void deleteRoutine(Pet pet, CareRoutine r) {
    _db.deleteRoutine(pet.id, r.id);
    _routines[pet.id]?.removeWhere((x) => x.id == r.id);
    notifyListeners();
  }

  void toggleRoutineItem(Pet pet, CareRoutine r, RoutineItem item) {
    final today = CareRoutine.todayKey();
    if (r.doneDate != today) {
      r.doneDate = today;
      r.doneIds = [];
    }
    if (r.doneIds.contains(item.id)) {
      r.doneIds.remove(item.id);
    } else {
      r.doneIds.add(item.id);
    }
    updateRoutine(pet, r);
  }

  // ---------- QR knowledge ----------
  String? qrNameFor(String code) => _qrKnowledge[code] as String?;

  void rememberQrCode(String code, String name) {
    _db.rememberQrCode(code, name);
    _qrKnowledge[code] = name;
    notifyListeners();
  }

  // ---------- Notifications ----------
  bool? _notificationsCache;

  bool get notificationsEnabled => _notificationsCache ??=
      (_db.getObject('notify_enabled') as bool?) ?? true;

  Future<void> setNotificationsEnabled(bool v) async {
    _db.setObject('notify_enabled', v);
    _notificationsCache = v;
    notifyListeners();
    await refreshNotifications();
  }

  Future<void> refreshNotifications() async {
    if (!notificationsEnabled) {
      try {
        await NotificationService.instance.cancelAll();
      } catch (e) {
        debugPrint('Notifications cancel failed: $e');
      }
      return;
    }
    try {
      final all = remindersForAll();
      final names = {for (final p in _pets) p.id: p.name};
      await NotificationService.instance.scheduleDailyFeedNudges(_pets);
      await NotificationService.instance
          .scheduleReminderOccurrences(all, names);
      await NotificationService.instance.scheduleOverdueNudge(all);
    } catch (e) {
      debugPrint('Notifications refresh failed: $e');
    }
  }
}