import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pawtether/models/models.dart';
import 'package:pawtether/providers/app_provider.dart';
import 'package:pawtether/storage/app_database.dart';
import 'package:pawtether/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pawtether/screens/add_pet.dart';
import 'package:pawtether/screens/calendar_screen.dart';
import 'package:pawtether/screens/home_shell.dart';
import 'package:pawtether/screens/pet_detail.dart';
import 'package:pawtether/screens/routines_screen.dart';

/// Store screenshot studio: seeds demo data, pumps real screens in
/// tr/en/ru, saves shots via takeScreenshot.
/// Run per device: `flutter test integration_test/screenshots_test.dart`
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store shots', (tester) async {
    await EasyLocalization.ensureInitialized();
    final db = AppDatabase();
    await db.init();
    final app = AppProvider(db)..loadAll();
    if (app.pets.isEmpty) _seed(app);
    final dog = app.pets.firstWhere((p) => p.species == Species.dog);

    Future<void> pump(Widget home, String code) async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
            Locale('ru'),
            Locale('hi')
          ],
          path: 'assets/lang',
          fallbackLocale: const Locale('en'),
          startLocale: Locale(code),
          useOnlyLangCode: true,
          child: Builder(builder: (context) {
            return ChangeNotifierProvider.value(
              value: app,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: home,
              ),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();
    }

    var converted = false;
    // App-external dir: readable via run-as, pulled by host mid-run
    // (the runner uninstalls the app when the test ends).
    final ext = await getExternalStorageDirectory();
    final shotsDir = Directory('${ext!.path}/shots');
    if (!await shotsDir.exists()) await shotsDir.create(recursive: true);
    Future<void> shot(String name) async {
      if (!converted) {
        await binding.convertFlutterSurfaceToImage();
        converted = true;
      }
      await tester.pump();
      final bytes = await binding.takeScreenshot(name);
      await File('${shotsDir.path}/$name.png').writeAsBytes(bytes);
    }

    for (final code in ['tr', 'en', 'ru']) {
      await pump(const HomeShell(), code);
      await shot('01-home-$code');

      await pump(PetDetailScreen(pet: dog), code);
      await shot('02-overview-$code');

      await pump(const CalendarScreen(), code);
      await shot('03-calendar-$code');
    }
    debugPrint('PAWSHOTS_DONE:${shotsDir.path}');
    // Stay alive so the host can pull the shots before uninstall.
    await Future.delayed(const Duration(minutes: 4));
  });
}

void _seed(AppProvider app) {
  final now = DateTime.now();
  final dog = Pet(
    name: 'Max',
    species: Species.dog,
    breed: 'Labrador',
    birthday: DateTime(now.year - 3, 4, 12),
    gender: 'Male',
    weightKg: 24.5,
    personalityNotes: 'Loves swimming.',
  );
  app.addPet(dog);
  final cat = Pet(
    name: 'Mia',
    species: Species.cat,
    breed: 'British Shorthair',
    birthday: DateTime(now.year - 2, 8, 3),
    gender: 'Female',
    weightKg: 4.2,
  );
  app.addPet(cat);
  app.setCurrentPet(dog.id);

  app.addVaccine(
      dog,
      Vaccine(
          petId: dog.id,
          name: 'Rabies',
          date: now.subtract(const Duration(days: 300)),
          nextDue: now.add(const Duration(days: 65)),
          vet: 'Happy Paws Clinic'));
  app.addMedication(
      dog,
      Medication(
          petId: dog.id,
          name: 'Flea Drops',
          dosage: '1 pipette',
          startDate: now.subtract(const Duration(days: 20))));
  app.addVisit(
      dog,
      VetVisit(
          petId: dog.id,
          date: now.subtract(const Duration(days: 10)),
          reason: 'Annual checkup',
          vetName: 'Dr. Yılmaz',
          cost: 850));
  for (final e in [(30, 23.8), (18, 24.1), (6, 24.5)]) {
    app.addWeight(
        dog,
        WeightEntry(
            petId: dog.id,
            date: now.subtract(Duration(days: e.$1)),
            weight: e.$2));
  }
  app.addLog(
      dog,
      CareLogEntry(
          petId: dog.id,
          dateTime: now.subtract(const Duration(hours: 2)),
          type: CareType.feeding,
          detail: 'Breakfast'));
  app.addLog(
      dog,
      CareLogEntry(
          petId: dog.id,
          dateTime: now.subtract(const Duration(hours: 1)),
          type: CareType.walking,
          detail: 'Long walk'));
  app.addReminder(
      dog,
      Reminder(
          petId: dog.id,
          title: 'Nail trim',
          type: ReminderType.grooming,
          date: DateTime(now.year, now.month, now.day, 18, 0)
              .add(const Duration(days: 1)),
          repeat: RepeatRule.none));
  app.addExpense(
      dog,
      Expense(
          petId: dog.id,
          title: 'cat:food',
          category: ExpenseCategory.food,
          amount: 450,
          date: now.subtract(const Duration(days: 3))));
  app.addExpense(
      dog,
      Expense(
          petId: dog.id,
          title: 'Checkup',
          category: ExpenseCategory.vet,
          amount: 850,
          date: now.subtract(const Duration(days: 10))));
}
