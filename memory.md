# PawTether — Project Memory (updated 2026-09-16, store-ready p49)

App: Flutter pet management app (idea.md) · project dir: `animalManagement`
Flutter 3.41.2 stable · Dart 3.11.0 · org `com.pawtether`
See STATUS.md for latest session resume + image-budget rule (0 generated / 50; user screenshots reviewed, never generated).

## Status (last verified p31)

- `flutter analyze` → 0 errors, 0 warnings, 16 info lints only
- `flutter test` → 34/34 passing (`test/models_test.dart` 11 + `test/templates_test.dart` 7 + `test/species_care_test.dart` 7 + `test/reminders_test.dart` 9)
- Builds: debug APK on PixelPlay (pid 18957) + RELEASE AAB 69MB
  (`build/app/outputs/bundle/release/app-release.aab`, upload-key signed,
  `jarsigner verified`, CN=PawTether to 2056). Keystore:
  `android/upload-keystore.jks` + `android/key.properties` — BACK UP,
  never commit, never lose. macOS/iOS targets generated, not yet rebuilt.
- Splash (p39-46): `flutter_native_splash` (dev) generates legacy + Android 12+ API + iOS from `assets/icon/splash_master.png` on cream (config in pubspec; Android 12 system icon is square-cropped `splash_system.png` since p46 so the circle shows max art) AND `SplashGate` shows the tall portrait (768x1376, p44) full-bleed in-app 1.4s over a blurred cover-fill.
- App icon (p33-34, p38): bg-removed paw master `assets/icon/app_icon_1024.png` (RGBA); Android ADAPTIVE (`mipmap-anydpi-v26`, cream bg + 72dp-safe foreground, legacy PNG fallback), iOS flattened white, macOS/web/Windows transparent; all installed.
- MVP holes closed: seed templates ✓, i18n TR/EN/RU/HI ✓ (live switch FIXED 2026-09-14), local notifications ✓, onboarding polish ✓
- Animal-friendly pass p1 (2026-09-15): species palette (dog/cat/budgie/parrot washes in AppColors) + pill buttons + MascotHeader w/ SpeciesPill + PawDivider + CozyBanner; species needs/meds/vaccines now ACTIONABLE (Log via QuickLogSheet + Remind with repeatForNeed/remindInDays); detail header is species-wash banner
- Animal-friendly pass p2 (2026-09-15): home switcher + NeedsAttention are species-wash banners; onboarding uses MascotHeader + species pills; visits CRUD complete (added updateVisit + edit sheet + tap-to-edit); fixed home_screen null-aware warning
- Custom icons p14/p18/p19: UIcons font everywhere + new `icons/Image*.png` rounded to transparent + cozy quick-grid art-wells (see below)
- i18n coverage: 317 keys/lang, 0 missing, 0 unused, ALL screens translated (guide bodies stay canonical English by design; seeds render via `seedTr()` display-time map; notifications localized; currency/dates follow app locale since p49)
- Theme: LIGHT-ONLY (dark mode deleted p20 — no themeMode/darkTheme/toggle; `AppTheme.light()` only)
- Species (7): dog/cat/budgie/parrot/rabbit/fish/other — portraits in `assets/species/sp_*.png` via `SpeciesArt.of()` (null for other); rabbit rose + fish deep-sea tints/washes

## Architecture

- **State**: `ChangeNotifier` + `provider` (single `AppProvider`, no codegen)
- **Local storage**: Hive boxes (no adapters — models serialize to Maps via `toMap`/`fromMap`), stored under `pawtether` named box dir. All offline-first.
- **Storage**: `lib/storage/app_database.dart` — boxes: `pets` (petId→pet map), and per-pet list boxes for records (vaccine/medication/visit/weight/symptom under `kind` key), `care_logs`, `reminders`, `documents`, `expenses`, `routines`, `qr_codes` (code→product name), `settings`. `deletePet` wipes all per-pet keys (no orphans since p27). No sharing (deleted p24; p28 fresh wipe cleared the legacy on-device `shares` box too).
- **Images**: picked photos/files copied into app documents dir (`media/`), path stored (`lib/storage/image_helper.dart`)

## Dependency list (pubspec)
`provider`, `hive`, `hive_flutter`, `intl` (0.20.2 pinned for easy_localization), `image_picker`, `file_picker` (v11: use static `FilePicker.pickFiles()`, no `.platform`), `path_provider`, `uuid`, `fl_chart`, `mobile_scanner` (v7.4), `easy_localization` (^3.0.8, assets/lang/{en,tr,ru,hi}.json), `flutter_local_notifications` (v22, named-param API) + `timezone`, `google_mobile_ads` (^9.1.0, TEST ids — swap before release)

## Layout (lib/)
- `main.dart` — boots Hive + EasyLocalization (en/tr/ru/hi, fallback en, saveLocale) + NotificationService (best-effort, never blocks boot), creates `AppProvider`, `MaterialApp` (LIGHT-ONLY `AppTheme.light()`; shell subscribes via `context.locale/delegates/supportedLocales` + `key: ValueKey(locale)` remount so language switch rebuilds everything) → `HomeShell` or `OnboardingScreen`
- `theme/app_theme.dart` — warm palette in `AppColors` (primary tangerine `#FF8A4C`, sage green, cream/ink), Material 3 LIGHT-ONLY; species palette + washes; 28r cards, pill buttons
- `theme/app_icons.dart` — 70-glyph `AppIcons` map over `assets/fonts/uicons-regular-rounded.ttf` (Flaticon UIcons 3.3.1, attribution in pubspec + class doc); all 15 icon files Material→AppIcons, outline-only
- `assets/quick_actions/qa_*.png` — 8 wired + 2 parked; sources `icons/Image.png + Image 2-10.png` (RGB opaque ~225px) rounded to RGBA 22% radius + 4x supersample AA (corners A=0); mapping: Image→feeding, 2→walking, 3→potty, 5→medication, 6→water, 7→grooming, 8→sleep, 9→other, 4→activity_parked, 10→medicine_parked (swapped p18b per user "both")
- `models/` → barrel `models.dart`; `storage/` → `app_database.dart`, `image_helper.dart`; `providers/app_provider.dart` (incl. `seedDefaultsFor`, `notificationsEnabled`/`refreshNotifications`); `data/care_templates.dart`; `services/notification_service.dart`
- `assets/lang/{en,tr,ru,hi}.json` — 317 keys each. Includes 63 `seed_*` (rendered via `seedTr()`), notif/unit/cal_today/date keys. Zero missing, zero unused (p49 audit).
- `lib/utils/i18n_helpers.dart` — speciesLabelTr(), careTypeLabelTr(), petAgeTr(), reminderTypeTr() (with emoji), repeatRuleTr(), expenseCatTr() (model getters stay English-only, UI uses helpers)
- `widgets/` → `common.dart` (`PetAvatar` w/o sync IO, `confirmDelete()`, `SectionHeader(title,{trailing})` — positional title, `EmptyState`, `MascotHeader`, `SpeciesPill`, `PawDivider`, `CozyBanner`; dead SectionCard/PawPrint/pickDate/overrideName removed p27), `charts.dart` (`WeightChart` plots logged entries only, `ActivityChart`)
- `test/` → `models_test.dart` (11: 10 + VetVisit round-trip/id-replace for updateVisit) + `templates_test.dart` (7: dog/cat/budgie/parrot + rabbit/fish + species round-trip) + `species_care_test.dart` (7) + `reminders_test.dart` (9: occurrences/overdue/copyWith/species-fallback/seedTr)
- `screens/`:
  - `home_shell.dart` — bottom nav: Home · Care · Files · More (outlined-only AppIcons, tangerine pill; bar in ClipRRect top-28r, cream light-only theme)
  - `home_screen.dart` — pet switcher (species gradient banner + SpeciesPill), NeedsAttention (species-wash done/due), Quick Actions 4× cozy grid (24r cards + species-wash 18r art-wells 68px contain, 0.78 aspect, 12px w700 labels, done = sage ring + white-disc badge; species order: birds float cleaning/meds up), Today's checklist (routines, 16px gap to Upcoming), Upcoming care, Today log. Header has add-pet + QR scan buttons
  - `scan_screen.dart` — mobile_scanner; result panel → "Remember" product name, "Log feeding"/"Log meds" (prefills QuickLogSheet)
  - `pet_detail.dart` — 4 tabs: Overview / Health / Stats / Timeline; Stats = WeightChart, ActivityChart, Expenses card (monthly + all-time totals); visits tap-to-edit via updateVisit; appbar delete (confirm + pop)
  - `calendar_screen.dart` — custom month grid (repeat-aware dots via `occursOn`, locale weekday header), tap day → reminder rows w/ Done buttons
  - `documents_screen.dart` — vault (picked files COPIED into `media/`, images w/ errorBuilder preview, non-image tap → snackbar, deletes confirmed)
  - `health_forms.dart` — generic `RecordSheet<T>` bottom sheet (null onSave = invalid, stays open + `form_invalid`); sheets: vaccine, medication, vet visit (+edit), weight, symptom, expense; NO translated strings stored (canonical English)
  - `routines_screen.dart` — per-pet routines, checklist with per-day reset (CheckboxListTile), form sheet (emoji + name + items; edit preserves item IDs/ticks), deletes confirmed
  - `quick_log.dart` — quick log bottom sheet (`QuickLogSheet.show(context, pet, type, {initialDetail, initialNote})`; canonical-English `_detailEn` stored, `_detailKeys` displayed; `_OptionPill` solid tangerine selected, `ql_title` order per lang; dead mood picker removed p27)
  - `add_pet.dart` (3-col GridView Species selector, 7 portrait pills 72px art + wash wells + species-tint ring; avatar placeholder shows species portrait in tint-ring circle; `_GenderSelector` chips; `_AllergyEditor` chips w/ dedupe; weight validator), `add_reminder.dart` (pet picker honored incl. cross-pet move, zero-pet guard, delete confirmed), `onboarding.dart` (`_LangPill` solid primary selected; MascotHeader + PawDivider + 6 SpeciesPills + Skip; OnboardingDone → HomeShell), `settings_screen.dart` (species gradient pet banners w/ delete+edit circle btns, tonal add-pet pill, `_PrefTile` medallions, bottom-sheet `_LanguageDropdown`, gradient version banner — NO dark toggle, NO sharing, NO remove section), `sharing_screen.dart` DELETED p24

## Models (all implement toMap/fromMap)
Pet (Species: dog/cat/budgie/parrot/rabbit/fish/other + speciesEmoji 🐶🐱🐦🦜🐰🐟🐾), Vaccine, Medication, VetVisit, WeightEntry, SymptomEntry, CareLogEntry (CareType enum w/ emoji+label), Reminder (RepeatRule none/daily/weekly/monthly; occursOn/nextOccurrence/copyWith/isDueToday/isOverdue/isDueNow), MedicalDocument, Expense (6 categories), CareRoutine + RoutineItem (daily progress keyed by `doneDate` yyyy-MM-dd). No SharedMember (sharing deleted p24).

## New modules
- `lib/data/care_templates.dart` — per-species daily routine + 3-5 reminders (idea.md §6); `AppProvider.seedDefaultsFor()` auto-runs on `addPet()` unless pet already has data
- `lib/services/notification_service.dart` — daily 9am DEVICE-LOCAL feed nudge per pet + per-reminder one-shot at `nextOccurrence()` (nearest 50, inexact, `seedTr` titles) + overdue medical `show()` (same-day past counts since p31); toggle via `AppProvider.notificationsEnabled` (`notify_enabled` in Hive, default true), refreshed every boot/mutation; wired in `main.dart` boot + Settings switch; tap opens app (no deep link). Tray delivery PROVEN p31 (live id-999 record in dumpsys).
- i18n: `EasyLocalization` (en/tr/ru/hi, fallback en, saveLocale, useOnlyLangCode), `assets/lang/*.json` (313 keys each), locale switcher in Settings bottom sheet + ChoiceChips on Onboarding; every user-facing string via `.tr()` or `i18n_helpers` (`seedTr()` for stored seed data)
- Ads: `lib/ads/ad_ids.dart` (REAL Android app ID, TEST banner p48 — real unit NO_FILLs while fresh; flip to `.../4899027866` at production) + slim `AdBannerCard` (classic 320x50 in 6px/20r card, p47) above Quick actions. Release TODO: app-ads.txt + real iOS keys + iOS ATT.

## Platform config
- macOS entitlements (DebugProfile + Release): added `com.apple.security.device.camera` = true
- iOS: `NSCameraUsageDescription` added to Info.plist
- Local notifications: `flutter_local_notifications` v22 + `timezone`; daily 9am DEVICE-LOCAL per-pet + per-reminder one-shot at `nextOccurrence()` (nearest 50, inexact) + overdue medical `show()`; toggle persisted as `notify_enabled`; refreshed every boot/mutation. Tap opens app (no deep link).

## Verification commands
- `flutter analyze`
- `flutter test`
- `flutter run` / `flutter build web --debug` / `flutter build macos --debug`

## Known notes / gotchas
- file_picker 11: `FilePicker.pickFiles()` static; `platform.file.name` is non-null
- `firstOrNull` NOT available in core Dart (used manual loops instead) — avoid
- SectionHeader uses positional `title:` arg
- `.withValues(alpha:)` is the new API; one leftover `withOpacity` remains in `lib/widgets/charts.dart:41` (info lint only)
- flutter_local_notifications v22 uses NAMED params: `initialize(settings:)`, `zonedSchedule(id:, title:, body:, scheduledDate:, notificationDetails:, androidScheduleMode:, ...)`, `show(id:, title:, body:, notificationDetails:, ...)` — NOT `initializationSettings:`
- intl pinned to 0.20.2 (easy_localization requires exactly 0.20.2, conflicts with ^0.20.3)
- Hive data persists under app documents dir; images referenced by absolute path
- Hive settings keys: `notify_enabled` (bool, default true). Legacy `dark` key ignored since p20 (light-only).
- Hive crash fix (2026-09-14): NEVER `List<Map<String,dynamic>>.from(list.whereType<Map>())` — Hive returns Map<dynamic,dynamic>; always `.whereType<Map>().map((e) => Map<String,dynamic>.from(e)).toList()`. Fixed all 14 occurrences in app_database.dart (crashed on 2nd launch after seeding routines)
- i18n live-switch fix (2026-09-14, easy_localization 3.0.8): `String.tr()` reads the global controller with NO inherited subscription, and const home/routes block rebuild cascade → switching locale only rebuilt direct `context.locale` readers (partial UI). Fix in main.dart: PawTetherApp.build reads `context.locale/delegates/supportedLocales` itself (subscribes the shell) + `key: ValueKey(locale)` on MaterialApp to remount subtree (resets nav stack to home on switch — accepted). Verified live TR→EN→TR on emulator with screenshots
- Android build env: Android Studio bundled JDK 25 breaks Gradle Kotlin DSL (`JavaVersion.parse`); fixed via `flutter config --jdk-dir=<temurin-20>`; `flutter_local_notifications` needs core desugaring (`isCoreLibraryDesugaringEnabled=true` + `desugar_jdk_libs:2.1.4`) in android/app/build.gradle.kts
- Emulator screen is 1080x2400 — screenshot PNGs are ~900px wide (scale ~1.2); use `uiautomator dump` for exact tap bounds instead of guessing
- Deploy flow (zombie-APK lesson p12): NEVER bare `am start` into running process — always install → force-stop → cold start (`monkey -p`), then verify pid + `mFocusedApp`
- tz trap (p30): `timezone` pkg parks `tz.local` on UTC → 9am fired at 12:00 in +03:00. Convert device-local instants explicitly (`TZDateTime.from(local, tz.UTC)`). Verified via `dumpsys alarm` origWhen lines.
- Overdue semantics (p31): one-time past-today counts as overdue (dropped `isDueSameDay`) — missed times shout on next refresh, no silent limbo.
- Icon lessons: NEVER draw debug overlay + crop same image object (p16 magenta bake); always overlay on a copy. Sources in `icons/` stay pristine RGB; outputs to `assets/quick_actions/` get RGBA rounded mask (22% radius, 4x supersample, LANCZOS). Display w/ `BoxFit.contain`, no clip — cropping mathematically impossible
- Rename history: PawTrack → PawTether p9 (31 files, `com.pawtether.pawtether`); old entries keep historic `pawtrack` strings