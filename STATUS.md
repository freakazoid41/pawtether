# PawTether — Session Status (2026-09-15, tray proven p31)

## Image budget — STRICT (opencode limit 50)
- Generated total: **0 / 50**. Reviewed user screenshots only (grids, settings, calendar — never counted, never generated).
- Rule: emoji + tinted washes only, zero asset images. Never screenshot for
  visual checks — use `flutter analyze`, `flutter test`, and
  `uiautomator dump` bounds if emulator taps are ever needed.
- If future session needs visual proof: max 2 screenshots per change.

## Goal this round (user said "yes do it")
1. Home species-wash banners.
2. Onboarding mascot polish (0 images).
3. `updateVisit` symmetry + UI wiring.

## Done p2
- `lib/screens/home_screen.dart`
  - `_PetSwitcher` → species gradient banner (tint 0.22 → wash, 28r,
    tint border) + bigger avatar (r22) + SpeciesPill label row.
    Also fixed pre-existing warning: early-return null guard, `current.id`
    non-null (was `current?.id` invalid_null_aware_operator).
  - `_NeedsAttention` → both states are species-wash containers (not plain
    Cards): done = tint gradient + species emoji medallion + check icon;
    due = primary gradient → species wash + emoji medallion + bell icon.
- `lib/screens/onboarding.dart`
  - `OnboardingScreen` → MascotHeader(title+subtitle via .tr()) +
    PawDivider(7) + species preview Wrap (4 SpeciesPills). Removed duplicate
    plain title/subtitle Texts.
  - `OnboardingDone` → MascotHeader(🎉, secondary tint) + PawDivider(5).
  - 0 images, emoji only.
- `lib/providers/app_provider.dart` — added `updateVisit` (putRecord +
  replace-by-id or insert, notifyListeners). Now symmetric with
  updateVaccine/updateMedication.
- `lib/screens/health_forms.dart` — `visitSheet(context, petId, [existing])`
  prefills controllers, preserves id, title switches hf_new_visit/hf_edit_visit.
- `lib/screens/pet_detail.dart` — `_Tile` gains optional `onTap`; visits rows
  tap → edit sheet → updateVisit. Visits now editable, not just add/delete.
- i18n — added `hf_edit_visit` en/tr/ru/hi (now **252 keys/lang**).
- `test/models_test.dart` — +1 test: VetVisit round-trip + id-preserving
  replace-by-id (updateVisit semantics).

## Verify (2026-09-15 p2)
- `flutter analyze` → 0 errors, 0 warnings, 19 info lints only.
- `flutter test` → **23/23 pass** (11 models incl. new visit test + 5
  templates + 7 species_care).

## Fix (2026-09-15 p3, bottom-bar mismatch from user screenshot)
- Root cause: `navigationBarTheme` was fixed to cream in `_base()` for both
  modes → pale slab over dark cocoa cards; sage indicator read off-brand.
- `lib/theme/app_theme.dart` — nav theme moved into `light()` (cream bg,
  tangerine indicator, ink/muted labels) and `dark()` (cocoa bg, tangerine
  indicator, white/muted labels).
- `lib/screens/home_shell.dart` — bar wrapped in ClipRRect top-28r to match
  cozy cards. Rebuilt + reinstalled on emulator-5554, 0 errors/0 warnings,
  23/23 tests. No screenshots spent (still 0/50).

## Fix (2026-09-15 p4, species pills misaligned from user screenshot)
- Root cause: `Wrap` + fixed 96px cells; TR "Muhabbet kuşu" wraps to 2 lines
  so that cell grew taller, and emoji glyphs have different metrics.
- `lib/screens/add_pet.dart` — `_SpeciesSelector` is now a 3-col GridView
  (equal cells, 20r): fixed 30px emoji slot (Center) + fixed 32px label slot
  (center, maxLines 2, ellipsis). Selected ring uses species tint, not generic
  primary. Rebuilt + reinstalled on emulator-5554, 0 errors/0 warnings,
  23/23 tests. Still 0 screenshots spent.

## Fix (2026-09-15 p7, dark-mode forms unreadable from user screenshot)
- Root cause: single cream `fillColor` in `_base()` for both modes → pale
  boxes + ghost text on dark cocoa.
- `lib/theme/app_theme.dart` — input theme split per mode: light keeps cream
  fill + ink/muted text + primaryDark icons + pawTint border; dark uses cocoa
  field fill + warm light labels + primary icons + brown border + honey
  floating labels. Shared cream block removed from `_base()`.
  Rebuilt + reinstalled on emulator-5554, 0 errors/0 warnings, 23/23.

## Fix (2026-09-15 p10, quick-log title order + dark chips)
- Title was hardcoded "{log} {type}" → TR "Kaydet Mama". New `ql_title`
  per lang (en/ru "{log} {type}", tr/hi "{type} {log}") + ru ql_log→verb
  "Записать", hi ql_log→"लॉग करें". Now: Log Feed / Mama Kaydet /
  Записать корм / खाना लॉग करें. (257 keys/lang.)
- Chips glowed cream in dark: chipTheme split per mode (dark = cocoa fill,
  light label, brown border, stronger selected tint).

## Fix (2026-09-15 p12, quick-log sheet STILL old on device)
- Root cause of the zombie: `am start` was hot-delivering into the already
  running process ("intent delivered to top-most instance") — new APK never
  actually restarted. Deploy flow fixed: install → force-stop → cold start,
  pid verified.
- `lib/screens/quick_log.dart` — stock ChoiceChips replaced with explicit
  `_OptionPill` (selected = solid tangerine + white; unselected = surface
  container + ink + border), CTA label pinned white w800. No more theme
  roulette in the sheet.
  Rebuilt + reinstalled + force-stopped + cold-started (pid 5694, focused),
  0 errors, 23/23.

## Incident (2026-09-15 p16, magenta boxes + "cut" tiles — MY BUG)
- I drew the magenta debug overlay on the source image and cropped tiles
  from that SAME object → debug rectangles baked into shipped PNGs. Also
  earlier: centered 212-boxes narrower than true ~226 tiles (cut borders),
  and a 60x54 frame over square art (cover shaved top/bottom).
- Fix: true 226x224 tile boxes, pristine-source crops (magenta scan = 0 in
  all 10), 72px square frames, no mat. LESSON: never draw + crop the same
  image object; always overlay on a copy. Verified on device (pid 8066):
  all 8 whole, edge-to-edge. 0 errors, 23/23.

## Fix (2026-09-15 p17, user's own transparent cuts)
- User supplied `icons/Subject*.png` (RGBA, ~200px, true transparency).
  Copied 1:1 to `assets/quick_actions/` (Subject 5 = medication, Subject 4
  parked as medicine list). Display: no clip, `BoxFit.contain` — cropping
  is now mathematically impossible. Verified on device (pid 8708): all 8
  whole + transparent (dark-mode safe). Slicing era over.

## Fix (2026-09-15 p13, checklist + upcoming cards merged)
- Root cause: cardTheme margin is zero + zero gap between the two sections.
- `lib/screens/home_screen.dart` — 16px gap between checklist and Upcoming,
  12px bottom pad on each routine card. Cold-started (pid 5850), 0 errors,
  23/23.

## Work (2026-09-15 p14, Flaticon UIcons everywhere)
- `assets/fonts/uicons-regular-rounded.ttf` (converted woff→ttf via
  fonttools, 3.3.1, 3597 glyphs) + pubspec `UIconsRegular` family.
- New `lib/theme/app_icons.dart` — 70-glyph `AppIcons` map (home, calendar,
  folder-open, settings, bell-ring, syringe, capsules, hospital, paw,
  qr-scan, walking, cake-birthday, venus-mars, microchip, piggy-bank…).
  Attribution: "UIcons by Flaticon" (see pubspec + class doc).
- All 15 files with icons converted Material→AppIcons (bottom nav, home,
  detail, forms, sheets, dialogs). Outline-only, selection via color+pill.
  Analyze 0 errors/0 warnings, tests 23/23. Cold-started (pid 6033).
  Image budget still 0/50.

## Work (2026-09-15 p15, hand-drawn quick-action stickers)
- Source `Gemini_Generated_Image_...jpeg` (1408x768) sliced to 220x220
  squares in `assets/quick_actions/` (10 files; 8 wired + ilac/activity
  parked). Crop boxes verified via debug overlay (labels excluded).
- `home_screen.dart` `_QuickLogGrid` now shows sticker art (52px, 14r clip)
  with done-state green ring + check badge; emoji fallback if asset misses.
  Medication → syringe tile (reads at small size). Labels still via i18n.
  Cold-started (pid 6265), 0 errors, 23/23. 2 debug image reads spent.

## Fix (2026-09-15 p8, gender free-text → select box)
- `lib/screens/add_pet.dart` — gender is now a 3-chip `_GenderSelector`
  (♂️/♀️/❓, stores canonical Male/Female/Unknown, breed went full-width).
- i18n — new `gender_male/female/unknown` in en/tr/ru/hi (256 keys/lang).
  Rebuilt + reinstalled, 0 errors, 23/23.

## Fix (2026-09-15 p5, comma-separated allergies from user screenshot)
- Root cause: single text field parsed on commas — nobody does that, plus
  the long TR label truncated with a warning icon.
- `lib/screens/add_pet.dart` — new `_AllergyEditor`: type → Add/Enter →
  deletable chips (case-insensitive dedupe, commas stripped). Edit mode
  prefills chips from pet. Card-style box with title row, no truncation.
- i18n — `form_allergies` shortened ("Allergies/Alerjiler/..."), new
  `form_allergies_hint` in en/tr/ru/hi (253 keys/lang). Add button reuses
  `common_add`. Rebuilt + reinstalled on emulator-5554, 0 errors, 23/23.

## Fix (2026-09-15 p11, onboarding language chips washed out)
- Root cause: raw ChoiceChip relied on M3 theme defaults → white-on-cream.
- `lib/screens/onboarding.dart` — new `_LangPill`: solid primary + white
  bold + check when selected, surface + onSurface ink + outline border when
  not. CTA labels now explicit white w800. Rebuilt + reinstalled, 0 errors,
  23/23.

## Rename (2026-09-15 p9, PawTrack → PawTether)
- Web check: zero app-store / web hits for "PawTether" — clean, claimed her.
- 31 files: pubspec `pawtether`, `package:pawtether/` imports, Android
  namespace/applicationId `com.pawtether.pawtether` (+kotlin dir moved),
  iOS/macOS bundle ids, linux/windows names, web manifest/title,
  `app_title`/`onboarding_title` all 4 langs, `PawTetherApp`, Hive dir +
  notif channel `pawtether*`, guide strings, README/idea/memory titles,
  root + android .iml renamed. Old `com.pawtrack.pawtrack` uninstalled from
  emulator-5554; new app focused (pid verified). 0 errors, 23/23.
  (This file's older entries keep historic `pawtrack` strings.)

## Fix (2026-09-15 p6, outlined smooth nav icons)
- `lib/screens/home_shell.dart` — destinations now outlined-only (no filled
  swap on select); the tangerine pill + label color carry selection.
  Rebuilt + reinstalled, 23/23. If you want the same treatment deeper
  (detail tiles, dialogs), say so.

## Files touched p2
- lib/screens/home_screen.dart
- lib/screens/onboarding.dart
- lib/providers/app_provider.dart
- lib/screens/health_forms.dart
- lib/screens/pet_detail.dart
- assets/lang/{en,tr,ru,hi}.json (+hf_edit_visit)
- test/models_test.dart

## Cumulative (p1+p2)
- Theme: species palette + washes, 28r cards, pill buttons.
- Widgets: SpeciesPill, PawDivider, CozyBanner, MascotHeader+speciesName.
- Species guide: actionable needs/meds/vaccines, 6 needs/species, Log+Remind.
- Home + detail + onboarding all species-washed, 0 images.
- Visits CRUD now complete (add/update/delete).

## Fix (2026-09-15 p18, new Image*.png curved sides)
- Sources `icons/Image.png + Image 2-10.png` were all RGB opaque (~221-226px,
  cream corners ~252,248,236) — square edges showed in dark mode.
- Rounded all 10 to RGBA with 22% radius (~48px) + 4x supersampled mask
  (smooth AA, corners A=0, center 255). Pristine `icons/` untouched.
- Mapped to `assets/quick_actions/`: Image→feeding, 2→walking, 3→potty,
  5→medication, 6→water, 7→grooming, 8→sleep, 9→other, 4→medicine_parked,
  10→activity_parked. Same filenames → `home_screen.dart:348` artFor needs
  zero code changes, pubspec already declares them.
- p18b: swapped parked (4→activity_parked, 10→medicine_parked per "both").
  Rebuilt + reinstalled + force-stop + cold start on PixelPlay (pid 4115,
  focused). Verify: analyze 0 errors/0 warnings (21 info), test 23/23.

## Polish (2026-09-15 p19, quick-actions perfect pass from screenshot)
- `lib/screens/home_screen.dart` `_QuickLogGrid`: harsh ink outline +
  tall 0.65 cards + 10px labels → cozy 24r cards w/ soft shadow, species
  wash art-wells (18r, tint 0.25 ring, transparent art corners show wash
  through), 0.78 aspect, 12px w700/w800 labels, done badge on white disc.
  Dark-mode: wash 0.22 alpha well, outline 0.5. Ink ripple via Material+Ink.
- Deploy: rebuilt + cold-started PixelPlay (pid 4291, focused), 0 errors,
  0 warnings, 23/23.
- Verify: analyze 0 errors/0 warnings (21 info), test 23/23.

## Removal (2026-09-15 p20, dark mode deleted per user)
- `lib/main.dart` — dropped `darkTheme` + `themeMode`, light-only.
- `lib/providers/app_provider.dart` — removed `_dark/isDark/themeMode/toggleDark` + Hive `dark` load (orphan key ignored).
- `lib/screens/settings_screen.dart` — removed dark-mode Card + `_DarkModeSwitch`.
- `lib/screens/home_screen.dart` — removed `isDark` branches (0.35 outline, 0.65 wash always).
- `lib/theme/app_theme.dart` — deleted `dark()` + `_dark*` constants, light-only comments.
- `assets/lang/*.json` — removed `settings_dark_mode` (now 256 keys/lang).
- Deploy: rebuilt + cold-started PixelPlay (pid 4500, focused), 0 errors, 0 warnings, 23/23.

## Work (2026-09-15 p21, rabbit + fish full species + portraits)
- Sources `icons/animals/Image*.png` (6, RGB opaque ~230px) rounded to RGBA
  22% radius + 4x supersample (corners A=0) → `assets/species/sp_{dog,cat,budgie,parrot,rabbit,fish}.png` + pubspec. Pristine `icons/` untouched.
- New `lib/theme/species_art.dart` — `SpeciesArt.of()` (null for other → 🐾 fallback).
- `Species.{rabbit,fish}` added: `pet.dart` (enum/fromString/label/emoji 🐰/🐟),
  `app_theme.dart` (rabbit rose #D96C8A/wash #F9DEE6, fish deep-sea #0E7C86/wash #D5EEF0 + tint/wash switches),
  `common.dart` (emojiFor/ringFor), `i18n_helpers.dart` (speciesLabelTr),
  `care_templates.dart` (rabbit 5+4, fish 4+4), `species_care.dart` (6 needs + 3 meds + 2 vaccines + 5 toxic each),
  `home_screen.dart` typesFor (fish w/ birds, rabbit litter-first), onboarding pills → 6.
- Add-pet areas: `_SpeciesSelector` 7 portrait pills (42px art in wash 14r well, 0.95 aspect) + avatar placeholder shows species portrait in tint-ring circle.
- i18n `species_rabbit/fish` en/tr/ru/hi (now 258 keys/lang). Tests +2 (rabbit/fish templates).
- Deploy: rebuilt + cold-started PixelPlay (pid 4987, focused), 0 errors, 0 warnings, 25/25.

## Polish (2026-09-15 p22, species art bigger per screenshot)
- `lib/screens/add_pet.dart` `_pill`: 42px art in 46px slot → 72px art in
  80px slot (wash well 20r, padding 4), emoji fallback 24→40, aspect 0.95→0.8.
- Deploy: rebuilt + cold-started PixelPlay (pid 5367), 0 errors, 0 warnings, 25/25.

## Polish (2026-09-15 p23, settings cozy pass per screenshot)
- `lib/screens/settings_screen.dart`: pet rows → species gradient banners
  (tint 0.22→wash, 24r, SpeciesPill + age, white circle share/edit btns);
  add-pet → tangerine tonal pill w/ white plus disc; remove → danger-tint
  card w/ full-width rows; prefs → `_PrefTile` (44px tinted medallion 15r +
  bold title); version → primary gradient banner w/ paw medallion.
  New `_CircleBtn/_DeleteRow/_PrefTile/_LanguageDropdown`, dropped
  `_confirmDelete/_LanguageTile`.
- i18n `settings_title` en/tr/ru/hi (now 259 keys/lang).
- Deploy: rebuilt + cold-started PixelPlay (pid 5571), 0 errors, 0 warnings, 25/25.

## Removal (2026-09-15 p24, co-owner feature deleted per user)
- Banner share icon → red trash: `settings_screen.dart` pet banner now has
  delete (confirm dialog + deletePet) + edit; `pet_detail.dart` appbar share
  → delete (confirm + deletePet + pop). The "Remove a pet" danger card below
  stays — same confirm, same action.
- Deleted `lib/screens/sharing_screen.dart` + `lib/models/share.dart`
  (SharedMember/AccessLevel), export removed from `models.dart`.
- `app_provider.dart`: dropped `_members/members()/addMember/deleteMember`
  + load line + deletePet list entry. `app_database.dart`: dropped `shares`
  box open + membersFor/addMember/deleteMember (on-device Hive `shares` box
  orphaned, ignored).
- i18n: removed 10 keys × 4 langs (tooltip_share + 9 shr_*) → 249 keys/lang.
- Deploy: rebuilt + cold-started PixelPlay (pid 5776, focused), 0 errors, 0 warnings, 25/25.

## Removal (2026-09-15 p25, Remove-a-pet section deleted per screenshot)
- `settings_screen.dart`: dropped the "Remove a pet" header + danger card +
  `_DeleteRow` (banner trash + detail trash cover deletion w/ same confirm).
- i18n: removed `pets_remove_title` × 4 → 248 keys/lang.
- Deploy: rebuilt + cold-started PixelPlay (pid 5924), 0 errors, 0 warnings, 25/25.

## Fix (2026-09-15 p26, language dropdown white-on-white per screenshot)
- Root cause: raw `DropdownButton` menu inherits menu-theme text colors →
  white items on white sheet, unreadable.
- `settings_screen.dart`: `_LanguageDropdown` is now label + chevron opening
  a cozy bottom sheet (grabber, 4 option rows w/ selected = primary tint +
  check). Explicit ink/primaryDark colors everywhere, no theme roulette.
- Deploy: rebuilt + cold-started PixelPlay (pid 6095), 0 errors, 0 warnings, 25/25.

## Audit + fixes (2026-09-15 p27, full shitcheck per user)
- Baseline: 24 info, 0 missing i18n keys, 10 dead keys.
- Reminder engine (was decorative): `reminder.dart` gains `occursOn()` /
  `nextOccurrence()` (daily/weekly/monthly-clamped) / `copyWith()`;
  `isDueToday` is now occurrence-based; `speciesFromString` unknown → other.
  New `completeReminder()` (one-time deletes, repeats jump forward); Done
  buttons in Upcoming + calendar rows; calendar dots + day list + Upcoming
  sort all repeat-aware; notification reschedule poked on
  add/update/deleteReminder + addVaccine + deletePet.
- Data integrity: `db.deletePet` now wipes per-pet boxes (was orphaning);
  forms validate (no empty names, no 0kg/0-amount junk, sheet stays open +
  `form_invalid`); no translated strings stored as data (frequency `Daily`,
  expense `_catEn`, symptom requires text); routine edit preserves item IDs
  + ticks; species-care stops pushing blank form + dedupes vaccines
  (`spc_already`); detail resolves live pet + bounces if deleted elsewhere.
- Crashes/UX: scan sheet via navigator context; home grid/upcoming watch
  (done rings + lists go live); docs files copied into vault + errorBuilders
  + non-image snackbar (`doc_no_preview`) + delete confirms; shared
  `confirmDelete()` on all deletes (tiles/routines/docs/expenses/logs/
  reminders); mounted guards on sheet callers; add-pet weight validator;
  dead mood picker removed; onboarding skip (`onboarding_skip`); charts
  phantom dot deleted + `chart_empty_weight`; empty-home add-pet CTA;
  Monday-first locale weekday header; `Intl.defaultLocale` follows app
  locale (+tr/ru/hi date symbols init) so all DateFormats localize.
- Hygiene: deleted SectionCard/PawPrint/pickDate/overrideName/displayAge?
  (kept model getters, dropped widget dead code), `needFrequencyLabel`,
  `_sameDay`, 6 intl imports, dummy `Pet()` builds (static emojiFor),
  PetAvatar drops sync `existsSync`; `AppIcons.share/moon` kept (map).
- i18n: 250 keys/lang, 0 missing, 0 unused (used home_due_now pair +
  misc_add_pet; purged 9 dead incl. ql_mood/hf_not_reported).
- Tests: new `test/reminders_test.dart` (8) → 33/33. Analyze 16 info
  (all pre-existing style), 0 errors/warnings.
- Deploy: rebuilt + cold-started PixelPlay (pid 6635, focused, no logcat
  exceptions), smoke pid stable.

## Fresh run (2026-09-15 p28, clean wipe per user)
- Uninstalled (wipes legacy Hive: orphan `shares` box + `dark` key gone),
  rebuilt APK, fresh install + cold start on PixelPlay (pid 7127, focused,
  logcat clean, pid stable).

## Fix (2026-09-15 p29, seed strings ignore locale per screenshot)
- Root cause: routine/reminder seeds stored once in English as user data and
  rendered raw — TR UI showed "Flea treatment" etc.
- `i18n_helpers.dart`: new `seedTr()` — 88-entry EN→key map (63 `seed_*` +
  25 `ql_opt_*`); known strings render translated, custom text passes
  through. 63 new keys × 4 langs (hand-written TR/RU/HI).
- Display sites: Upcoming + calendar + due banners (home/detail) +
  checklist + routines screen + today-log details.
- `quick_log.dart`: pills now store canonical English, display translated
  (new logs switch language cleanly; legacy rows show as-is).
- Tests +1 (seedTr mapping/passthrough) → 34/34. i18n: 313 keys/lang,
  0 missing, 0 unused. Analyze 16 info, 0 errors/warnings.
- Deploy: rebuilt + cold-started PixelPlay (pid 7357), logcat clean.

## Fix (2026-09-15 p30, reminders never notified per user)
- `notification_service.dart`: new `scheduleReminderOccurrences()` — every
  enabled reminder gets a one-shot alarm at `nextOccurrence()` (nearest 50,
  `seedTr` title + pet name · time, inexact, payload `reminder:id`).
  `_next9am` fixed to device-local 9am (was firing 12:00 in +03:00 — tz
  database parks `tz.local` on UTC; explicit instant conversion via `_zoned`).
- `app_provider.dart` `refreshNotifications()`: daily nudges + occurrences +
  overdue show, every boot/mutation. `main.dart` boot delegates to it.
- Verified on PixelPlay `dumpsys alarm`: 6 alarms (daily 09:00 local +
  user's real Sept 22 ×2 / Oct 15 ×2 / annual) — all at true local times.
- Limits (by design): one-shot alarms refresh on boot/mutation; inexact
  window (~1h) so no exact-alarm permission needed; tap just opens the app.
- Deploy: rebuilt + cold-started PixelPlay (pid 7546), 0 errors, 34/34.

## Fix (2026-09-15 p31, live-fire test flopped → real bug found)
- User's TEST reminder saved today 20:45, already past at save → same-day
  exclusion in `isOverdue` left it in silent limbo (due-today display only,
  no alarm, not overdue). Verified via Hive bytes.
- `isOverdue` now counts same-day past (dropped `isDueSameDay`); missed
  times shout on next refresh instead of rotting silently.
- Proof: cold start fired id-999 `pawtether_daily` record live in
  `dumpsys notification` (interruptive, importance 4, sound+vibration).
- Deploy: rebuilt + cold-started PixelPlay (pid 7813), 0 errors, 34/34.

## Work (2026-09-15 p33, paw app icon everywhere per user)
- Source `~/Desktop/Gemini_Generated_Image_pztceipztceipztc.jpeg` (1033x1024)
  → square 1024 master at `assets/icon/app_icon_1024.png` (not a runtime asset).
- Generated (PIL LANCZOS): Android mipmap 48/72/96/144/192; iOS set complete
  (20→1024, 1024 opaque RGB for store); macOS 16→1024; web 192/512 +
  maskable pair (navy-padded safe zone) + 64 favicon; Windows multi-ICO.
- Deploy: rebuilt + cold-started PixelPlay (pid 5740), 16 info, 34/34.
  NOTE: launcher may cache the old glyph — reboot emulator if stale.

## Work (2026-09-15 p34, bg-removed icon per user — navy square looked bad)
- Source swapped to `... Background Removed.png` (RGBA, true transparent
  corners). Android/macOS/web/Windows keep transparency; iOS full set
  flattened on white (store + devices hate alpha).
- Deploy: rebuilt + cold-started PixelPlay (pid 6078), 34/34.

## Fix (2026-09-15 p35, Chrome shortcut ugly per screenshot)
- Why: `index.html` pointed `apple-touch-icon` at transparent Icon-192 →
  Chrome shrank it into a circle on auto-generated cream + badge dot.
- New opaque white `web/icons/apple-touch-icon.png` (180px, full-bleed paw)
  wired in `index.html`. (Pink dot was our live notification badge — working.)
- Web rebuilt ✓ (no emulator push needed).

## Fix (2026-09-16 p37, shortcut STILL small per screenshot)
- Why p35 missed: Chrome NTP tiles use the **favicon**, not apple-touch-icon.
- `web/favicon.png` → opaque white 96px full-bleed paw. Web rebuilt ✓.
- User must hard-refresh / re-add the shortcut (Chrome caches tile icons).

## Fix (2026-09-16 p38, launcher icon squished — screenshot was EMULATOR)
- Why: legacy PNG only → Pixel Launcher shrinks it onto a disc.
- Adaptive icons: `mipmap-anydpi-v26/ic_launcher.xml` (cream `#FFF6EC`
  background + foreground paw at 72dp safe zone, all densities) + legacy
  PNGs kept as fallback.
- Deploy: rebuilt + cold-started PixelPlay (pid 7121).
  NOTE: launcher caches icons — reboot emulator if the drawer still shows
  the old disc. (Pink dot was the live notification badge — working.)

## Work (2026-09-16 p39, splash screen per user)
- Source `~/Desktop/...yle4s5....jpeg` → Android `drawable-xxxhdpi/
  splash_image.png` (1080) centered on cream in both launch_backgrounds;
  iOS LaunchImage set 340/680/1020 + storyboard bg cream.
- Master kept at `assets/icon/splash_master.png`.
- Deploy: rebuilt + cold-started PixelPlay (pid 7649), 34/34.

## Fix (2026-09-16 p40, splash showed mini launcher icon per screenshot)
- Why: Android 12+ ignores legacy drawables, shows system splash (launcher
  icon mini on theme bg). Teal ring was the touch indicator, not UI.
- `flutter_native_splash: ^2.4.7` (dev) + pubspec config (cream bg, splash
  master, android_12 + ios, web off) → generated legacy/v31/iOS splash.
  Hand-made p39 drawables superseded (orphan xxxhdpi PNG deleted).
- Deploy: rebuilt + cold-started PixelPlay (pid 8922), 16 info, 34/34.

## Work (2026-09-16 p41, FULL-BLEED in-app splash per user)
- System splash is circle-capped by Android 12+ — real collage now shows in
  `SplashGate` (1.4s, cream, contain) → HomeShell/Onboarding. Asset added to
  pubspec; `main.dart` home is the gate.
- Deploy: rebuilt + cold-started PixelPlay (pid 9444), 0 errors, 34/34,
  no asset-load errors.

## Fix (2026-09-16 p42, cream bands clash per screenshot)
- Gate bg is now the art's own gradient (pink `#FEC4D1` top → mint
  `#B0E2D6` bottom, edge-sampled) — bands melt into the collage.
- Deploy: rebuilt + cold-started PixelPlay (pid 10077), 0 errors, 34/34.

## Fix (2026-09-16 p43, gradient seams still visible per screenshot)
- Gate now uses blurred cover-fill of the SAME art behind the sharp
  contain image — every seam meets its own colors.
- Deploy: rebuilt + cold-started PixelPlay (pid 10956), 0 errors, 34/34.

## Work (2026-09-16 p44, tall splash art per user)
- New portrait master (768x1376, pink→mint) replaces splash_master;
  native splash regenerated; gate blur-backdrop still blends any ratio.
- Deploy: rebuilt + cold-started PixelPlay (pid 11814), 0 errors, 34/34,
  no asset errors.

## Fix (2026-09-16 p45, system splash mini-circle per screenshot)- Why: Android 12+ circle-masks the tall art into a tiny disc before the gate.
- `android_12.image` → paw app icon (born for small sizes); full collage
  still opens in the gate right after. Regenerated + rebuilt + cold-started
  PixelPlay (pid 12862), 0 errors, 34/34.

## Work (2026-09-16 p46, system splash fills its circle per user)
- New `assets/icon/splash_system.png` (square center-crop of the tall
  master) feeds `android_12.image`; regenerated. Verified byte-identical
  into `drawable-xxxhdpi/android12splash.png` — circle now shows max art.
  (2 verification screenshots spent, home screen confirms adaptive paw
  icon renders beautifully.)
- Deploy: cold-started PixelPlay (pid 13983), 0 errors, 34/34.

## Fix (2026-09-16 p47, ad card fat per screenshot)
- Root cause: anchored adaptive creative (~100px) crammed into the 50px box.
- `AdBannerCard` now loads slim classic 320x50 in `initState` (no async
  size lookup); card chrome already 6px/20r/50px.
- Deploy: rebuilt + cold-started PixelPlay (pid 16149), 0 errors, 34/34.

## Work (2026-09-16 p48, back to TEST banner till production per user)
- Real unit returned NO_FILL (error 3, fresh unit) → `homeBanner` back to
  Google test unit; manifest keeps REAL app ID.
- Proof: logcat shows test-device request + doubleclick creative loading,
  zero load failures. Deploy pid 16666.
- TODO production: flip `AdIds.homeBanner` to `.../4899027866`.

## Work (2026-09-16 p50, source to GitHub per user)
- Repo initialized, 248 files, pushed to
  `https://github.com/freakazoid41/pawtether.git` (was empty, now `main`).
- `.gitignore` hardened (keystore/key.properties/build excluded — verified
  absent from remote).

## Fix (2026-09-16 p51, app-ads.txt placement per user)
- User's Pages root ALREADY serves `/app-ads.txt` with their pub ID
  (`...f08c47fec0942fa0`, same account) — one domain = one file, and that
  line already covers PawTether. Removed the subpath copy from the project
  repo (never crawled, only confusing). NOTHING to add anywhere.
- Play listing Website MUST be `https://freakazoid41.github.io` (root).
  If AdMob ever flags auth, append the documented cert-ID twin line
  `google.com, pub-1088997129209291, DIRECT, f5cf6f5d4d1f3aa0` to the root.

## Audit + store prep (2026-09-16 p49, careful pass per user)
- Baseline: 16 info, 34/34, i18n 313 perfect. Rejected 2 audit claims w/
  evidence (tz `_zoned` proven by 09:00 alarm dump; midnight routine edge
  can't happen via `isCurrent`).
- Store blockers FIXED: INTERNET + ACCESS_NETWORK_STATE in main manifest
  (release had zero permissions); label `PawTether`; `allowBackup=false`
  (absolute Hive/media paths); upload keystore generated
  (`android/upload-keystore.jks` + `key.properties`, 30y) + release
  signing wired; release AAB built 69MB, `jarsigner verified`, self-signed
  CN=PawTether to 2056. BACK UP THE KEYSTORE — lose it, lose updates.
- Strings: notif feed/overdue keys ×4, `unit_kg`, locale `yMd` dates,
  locale currency, canonical frequency/expense display, timeline `seedTr`
  parity, onboarding translated pills, `rou_done` counter, all deletes
  confirmed. Guide bodies stay EN by design. i18n now 317 keys, 0/0/0.
- Perf: cacheWidth thumbs/avatars, RepaintBoundary splash blur + charts,
  notificationsEnabled cached, debugPrint in best-effort catches.
- Mechanics: scan per-code cooldown, stable reminder alarm ids (1000+i),
  dead `skipIfEmpty`/`_sameDay`/getters removed, calendar non-null selected,
  timeline ListView.builder.
- 19 info (style only), 0 errors/warnings, 34/34. Debug on PixelPlay
  pid 18957, logcat clean.
- Release AAB: `build/app/outputs/bundle/release/app-release.aab`.
- Still console-side (yours): upload AAB, Data Safety (ads ID, photos/docs,
  notifications), app-ads.txt, content rating, real iOS keys + ATT, feature
  graphic + screenshots, privacy policy URL (AdMob requires it).

## Polish (2026-09-16 p47, thinner ad card per screenshot)
- `AdBannerCard`: large adaptive → standard anchored adaptive (≈60dp tall),
  padding 8→6, radii 24/16→20/14. (Standard API is deprecated in v9 in favor
  of the large one — kept deliberately for thinness; 1 info lint.)
- First attempt failed to compile (1-arg call); fixed with
  (orientation, width) overload. Caught before shipping — stale APK never
  went out twice.
- Deploy: rebuilt + cold-started PixelPlay (pid 15647), 0 errors, 34/34.

## Work (2026-09-16 p36, REAL AdMob keys per user)
- Android production IDs in manifest + `AdIds.homeBanner`
  (app `...~3718255248`, banner `.../4899027866`). iOS still test IDs.
- Deploy: rebuilt + cold-started PixelPlay (pid 6672), 34/34.
  NOTE: fresh AdMob units can take a few hours to serve real ads; also add
  app-ads.txt on your domain before store release + real iOS keys later.

## Work (2026-09-15 p32, AdMob banner above Quick actions per user)
- `google_mobile_ads: ^9.1.0` + `MobileAds.instance.initialize()` at boot
  (best-effort, never blocks). TEST ids only — swap in `lib/ads/ad_ids.dart`
  before release. Android manifest APPLICATION_ID + iOS GADApplicationIdentifier.
- New `lib/widgets/ad_banner.dart` `AdBannerCard`: large adaptive banner in
  a cozy 24r card, zero-height until loaded / on failure (never jumps).
  Wired in `home_screen.dart` directly above `home_quick_actions` header.
- Deploy: rebuilt + cold-started PixelPlay (pid 5095), 16 info,
  0 errors/warnings, 34/34.

## Next (not started)
- README is still default Flutter template — rewrite (features, i18n, run cmds).
- Optional V2 per idea.md: weight-anomaly alert, food-stock via QR count,
  vet PDF export, cloud sync.
- Store prep: iOS build, adaptive icon (counts as images — budget 2 max).

## Resume prompt
"Continue PawTether from STATUS.md — 2/50 images spent, 34/34 tests green, pid 18957 debug on PixelPlay; release AAB 69MB signed (upload keystore in android/). Light-only, 7 species, TEST AdMob.
Next: Play Console upload (AAB ready) + README rewrite."
