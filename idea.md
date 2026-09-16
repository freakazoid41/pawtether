# PawTether — Pet Management App Plan (THICK Edition)

## 1. Vision
Offline-first Flutter app to manage daily care for dogs, cats, budgie birds, parrots.
Answer: "Did you feed it? Clean its shit? Do its medical stuff on time?" — every day, no guilt-trip missed.

Project dir: `animalManagement` · App: `pawtether` (`com.pawtether`)

## 2. Supported Pets
- Dog, Cat, Budgie, Parrot (+ extensible: Pet model has `species` string, easy to add Rabbit, Fish later)
- Multi-pet household first-class: switcher on Home, per-pet routines / reminders / health / expenses.
- Pet profile: name, species, breed, birthDate, weight, photo (`media/` copy), notes.

## 3. Languages (TR, EN, RU, HI)
- Target 4 locales: `tr`, `en`, `ru`, `hi` (Hindi — your "INDIA" ask).
- Plan: `easy_localization` + JSON per locale (`assets/lang/en.json` etc.), `fallbackLocale: en`.
- All CareType labels, Reminder strings, empty-states, onboarding go through `.tr()`. No hardcoded strings in new code.
- RTL check not needed, but date/number formatting via `intl` per locale.

## 4. Core Loops
### A. Onboarding → Home
Onboarding → add first pet(s) → auto-seed routines + reminders per species → land on HomeShell.

### B. Daily Care Loop (the money loop)
1. Home shows: NeedsAttention (overdue/due today) → Today's Checklist (routines reset daily via `doneDate`) → Quick Actions (feed/water/clean/play with "done today" state) → Upcoming care → Today log.
2. User taps done → writes `CareLogEntry` + marks `CareRoutine` item → Timeline + Stats update instantly.
3. Missed day → shows overdue, never auto-deletes.

### C. Periodic Medical Loop
Vaccine / Medication / VetVisit / Weight / Symptom records (`RecordSheet<T>` bottom sheets) → Reminders with `RepeatRule none/daily/weekly/monthly` → Calendar dots → push (LAST phase).

## 5. Feature Map (what exists + what idea demands)
- **Pets**: add/edit/delete/share, avatar, multi-select filter. `settings_screen.dart` handles edit.
- **Quick Log**: feed, water, toilet/cage clean, walk, play, grooming. Question style: "Did you feed X today?" "Did you clean its shit/litter/cage?" One-tap yes + optional note/photo.
- **Routines**: per-pet templates with emoji + items. Daily reset. Checklist UI (`routines_screen.dart`).
- **Reminders + Calendar**: title, pet, dateTime, repeat, `isDueToday/isOverdue/isDueNow`. Month grid with dots, tap day → rows. This covers "daily/weekly/monthly maintenance suggestions."
- **Health Vault**: vaccines, meds, vet visits, weight chart (`WeightChart`), symptoms, activity (`ActivityChart`). Medical procedures on period = repeat reminders auto-created from vaccine/medication expiry.
- **Documents**: photo/file vault per pet, previewable. Vet PDFs, prescriptions.
- **Expenses**: 6 categories, monthly + all-time totals on Pet Detail Stats tab.
- **QR Scanner**: `mobile_scanner` → remember product (food/meds) name in `qr_codes` box → one-tap "Log feeding" / "Log meds" with prefill. Killer for re-buy + logging speed.
- **Sharing**: invite with view/edit (`SharedMember`), per-pet box `shares`.
- **Theme/Settings**: light/dark (`AppColors`: tangerine #FF8A4C, sage, cream/ink, Material3), locale switcher lives here.

## 6. Default Care Templates (auto-suggest on pet create)
**Dog — Daily**: fresh water x2, feed 2x, walk 2x, poop pick + paw wipe, 10min play/training. Weekly: bath/brush, bedding wash, toy clean. Monthly: flea/tick, weight check, nail trim. Periodic: vaccines, vet 6-12mo.
**Cat — Daily**: fresh water, feed 2x, litter scoop, 15min play. Weekly: full litter change + box wash, brush, scratcher check. Monthly: flea, weight, nail trim. Periodic: vaccines, vet 12mo.
**Budgie — Daily**: water change, seed + veg, cage paper check, droppings glance, 30min out/social. Weekly: full cage clean, perches/toys disinfect, bath water. Monthly: beak/nail/weight check, daylight 10-12h audit. Periodic: avian vet 12mo.
**Parrot — Daily**: water, pellets + fruit/veg, cage spot-clean shit trays, 1-2h social/out, mental toy rotate. Weekly: deep cage clean, shower/mist, toy safety check. Monthly: weight, beak/feather check. Periodic: avian vet 6-12mo, blood/parasite as advised.

Each template = 1 `CareRoutine` + 3-5 `Reminder`s seeded, user can edit/delete. No forced paywall.

## 7. Data / Tech (locked)
- State: `provider` single `AppProvider` (`ChangeNotifier`), no codegen.
- Storage: Hive boxes, models to Map via `toMap/fromMap`: `pets`, per-pet `vaccine/medication/visit/weight/symptom`, `care_logs`, `reminders`, `documents`, `shares`, `expenses`, `routines`, `qr_codes`, `settings`. Offline-first, absolute image paths under app docs `media/`.
- Deps: `provider, hive, hive_flutter, intl(0.20.2 pinned), image_picker, file_picker(v11 static), path_provider, uuid, fl_chart, mobile_scanner(v7.4), easy_localization(^3.0.8), flutter_local_notifications(v22) + timezone`. All added ✓ (push LAST done).
- Gotchas: no `firstOrNull`, `SectionHeader(title: positional)`, `.withValues(alpha:)` not `withOpacity`, file_picker static API.

## 8. UX Structure
`HomeShell` bottom nav: Home · Care (calendar) · Files · More.
Home header: pet ChoiceChips + add-pet + QR scan.
PetDetail tabs: Overview / Health / Stats / Timeline.

## 9. MVP Definition of Done
- [x] Multi-pet, quick log, routines daily reset, reminders + calendar, health forms, docs, expenses, QR remember/log, charts, dark mode, tests 15/15, analyze 0 errors, web+APK green
- [x] i18n TR/EN/RU/HI wired (240 keys/lang, all screens, live switch verified on emulator)
- [x] Seed templates auto-create on add-pet
- [x] Local notifications (daily 9am "Did you feed X?" + overdue medical nudge) — was intentionally LAST, now done
- [x] Onboarding polish + empty states in all 4 langs

## 10. V2 (after MVP sucks less)
- Vet share link / PDF export, weight anomaly alert, food stock tracking via QR scan count, widgets, cloud sync (Supabase/Firebase), sitter mode.

## 11. Verification
`flutter analyze` → 0 errors · `flutter test` → 15/15 · `flutter build web` / APK green (macOS target generated, not yet rebuilt). iOS build before store.
