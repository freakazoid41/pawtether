import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../utils/i18n_helpers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/common.dart';
import 'add_pet.dart';
import 'add_reminder.dart';
import 'pet_detail.dart';
import 'quick_log.dart';
import 'routines_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    if (!app.hasPets) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: EmptyState(
              emoji: '🦴',
              title: 'pets_empty'.tr(),
              subtitle: 'onboarding_subtitle'.tr(),
              action: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AddPetScreen())),
                icon: const Icon(AppIcons.plus, size: 18),
                label: Text('misc_add_pet'.tr()),
              ),
            ),
          ),
        ),
      );
    }
    final pet = app.currentPet!;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _PetSwitcher(),
            const SizedBox(height: 18),
            _NeedsAttention(pet),
            const SizedBox(height: 20),
            const AdBannerCard(),
            const SizedBox(height: 20),
            SectionHeader('home_quick_actions'.tr()),
            _QuickLogGrid(pet),
            const SizedBox(height: 22),
            _TodayChecklist(pet),
            const SizedBox(height: 16),
            _UpcomingCare(pet),
            const SizedBox(height: 22),
            _TodaySection(pet),
          ],
        ),
      ),
    );
  }
}

class _PetSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final pets = app.pets;
    final current = app.currentPet;
    if (current == null) return const SizedBox.shrink();
    final tint = AppColors.speciesTint(current.species.name);
    final wash = AppColors.speciesWash(current.species.name);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tint.withValues(alpha: 0.22), wash],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: tint.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PetDetailScreen(pet: current))),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      PetAvatar(pet: current, radius: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 22),
                            ),
                            Text(
                              '${speciesLabelTr(current.species)} · ${petAgeTr(current)}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.55)),
                            ),
                            const SizedBox(height: 6),
                            SpeciesPill(
                              speciesName: current.species.name,
                              emoji: current.speciesEmoji,
                              label: speciesLabelTr(current.species),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        AppIcons.angleRight,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AddPetScreen())),
              icon: const Icon(AppIcons.plus,
                  color: AppColors.primary),
              tooltip: 'tooltip_add_pet'.tr(),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ScanScreen())),
              icon: const Icon(AppIcons.qrScan,
                  color: AppColors.primary),
              tooltip: 'tooltip_scan_qr'.tr(),
            ),
          ],
          ),
        ),
        if (pets.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final p = pets[i];
                final selected = current.id == p.id;
                return ChoiceChip(
                  selected: selected,
                  avatar: PetAvatar(pet: p, radius: 11),
                  label: Text(p.name),
                  onSelected: (_) => app.setCurrentPet(p.id),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _NeedsAttention extends StatelessWidget {
  final Pet pet;
  const _NeedsAttention(this.pet);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final due = app.reminders(pet).where((r) => r.isDueNow).toList();
    final tint = AppColors.speciesTint(pet.species.name);
    final wash = AppColors.speciesWash(pet.species.name);

    if (due.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tint.withValues(alpha: 0.20), wash],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: tint.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(pet.speciesEmoji,
                  style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'home_all_done_for'
                          .tr(namedArgs: {'name': pet.name}),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: tint)),
                  const SizedBox(height: 2),
                  Text(
                    'home_no_care_due'.tr(),
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            const Icon(AppIcons.checkCircle,
                color: AppColors.secondary, size: 28),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.20),
            wash
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(pet.speciesEmoji,
                style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  due.length == 1
                      ? 'home_due_now'
                          .tr(namedArgs: {'count': '${due.length}'})
                      : 'home_due_now_plural'
                          .tr(namedArgs: {'count': '${due.length}'}),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  due.take(2).map((r) => seedTr(r.title)).join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          const Icon(AppIcons.bellRing,
              color: AppColors.primary, size: 26),
        ],
      ),
    );
  }
}

class _QuickLogGrid extends StatelessWidget {
  final Pet pet;
  const _QuickLogGrid(this.pet);

  /// Species-tuned order: birds don't walk — cleaning, mist/groom and
  /// meds float up; dogs/cats keep the full classic order.
  static List<CareType> typesFor(Species s) {
    switch (s) {
      case Species.budgie:
      case Species.parrot:
      case Species.fish:
        return const [
          CareType.feeding,
          CareType.water,
          CareType.potty,
          CareType.grooming,
          CareType.medication,
          CareType.sleep,
          CareType.other,
          CareType.walking,
        ];
      case Species.rabbit:
        return const [
          CareType.feeding,
          CareType.potty,
          CareType.water,
          CareType.grooming,
          CareType.sleep,
          CareType.medication,
          CareType.other,
          CareType.walking,
        ];
      case Species.dog:
      case Species.cat:
      case Species.other:
        return const [
          CareType.feeding,
          CareType.walking,
          CareType.potty,
          CareType.medication,
          CareType.water,
          CareType.grooming,
          CareType.sleep,
          CareType.other,
        ];
    }
  }

  /// Hand-drawn sticker art (sliced from the shared icon set) per type.
  /// Medication uses the syringe tile — reads instantly at small size.
  static String artFor(CareType t) => switch (t) {
        CareType.feeding => 'assets/quick_actions/qa_feeding.png',
        CareType.walking => 'assets/quick_actions/qa_walking.png',
        CareType.potty => 'assets/quick_actions/qa_potty.png',
        CareType.medication => 'assets/quick_actions/qa_medication.png',
        CareType.water => 'assets/quick_actions/qa_water.png',
        CareType.grooming => 'assets/quick_actions/qa_grooming.png',
        CareType.sleep => 'assets/quick_actions/qa_sleep.png',
        CareType.other => 'assets/quick_actions/qa_other.png',
      };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final types = typesFor(pet.species);
    final cs = Theme.of(context).colorScheme;
    final tint = AppColors.speciesTint(pet.species.name);
    final wash = AppColors.speciesWash(pet.species.name);
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 12,
      childAspectRatio: 0.78,
      children: types.map((t) {
        final isDone = app.todayDone(pet, t) != null;
        final border = isDone
            ? AppColors.secondary
            : cs.outlineVariant.withValues(alpha: 0.35);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => QuickLogSheet.show(context, pet, t),
            child: Ink(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 9),
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.secondary.withValues(alpha: 0.14)
                    : cs.surface,
                border: Border.all(color: border, width: isDone ? 2 : 1.2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isDone ? AppColors.secondary : tint)
                        .withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.secondary.withValues(alpha: 0.18)
                            : wash.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (isDone ? AppColors.secondary : tint)
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Transparent rounded art: corners show the wash
                          // through — no white box.
                          Image.asset(
                            artFor(t),
                            width: 68,
                            height: 68,
                            cacheWidth: 136,
                            cacheHeight: 136,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(t.icon,
                                style: const TextStyle(fontSize: 30)),
                          ),
                          if (isDone)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(AppIcons.checkCircle,
                                    color: AppColors.secondary, size: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    careTypeLabelTr(t),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isDone ? FontWeight.w800 : FontWeight.w700,
                      letterSpacing: -0.1,
                      color: isDone
                          ? AppColors.secondary
                          : cs.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TodayChecklist extends StatelessWidget {
  final Pet pet;
  const _TodayChecklist(this.pet);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final routines = app.routines(pet);
    if (routines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: SectionHeader('home_today_checklist'.tr())),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RoutinesScreen(pet: pet))),
              icon: const Icon(AppIcons.settingsSliders, size: 16),
              label: Text('common_manage'.tr()),
            ),
          ],
        ),
        ...routines.map((r) {
          final total = r.itemCount;
          final progress = r.completedCount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(seedTr(r.name),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                        ),
                        if (total > 0)
                          Text(
                              'rou_done'.tr(namedArgs: {
                                'done': '$progress',
                                'total': '$total'
                              }),
                              style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700)),
                      ],
                    ),
                    ...r.items.take(6).map((item) {
                      final done = r.isDone(item.id);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        value: done,
                        title: Text(seedTr(item.title),
                            style: TextStyle(
                              decoration:
                                  done ? TextDecoration.lineThrough : null,
                              color: done
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: .45)
                                  : null,
                            )),
                        onChanged: (_) => context
                            .read<AppProvider>()
                            .toggleRoutineItem(pet, r, item),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _UpcomingCare extends StatelessWidget {
  final Pet pet;
  const _UpcomingCare(this.pet);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final upcoming = app.reminders(pet).where((r) => r.enabled).toList()
      ..sort((a, b) {
        final an = a.nextOccurrence() ?? a.date;
        final bn = b.nextOccurrence() ?? b.date;
        return an.compareTo(bn);
      });
    final top = upcoming.take(4).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('home_upcoming'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AddReminderScreen())),
                  icon: const Icon(AppIcons.plus, size: 18),
                  label: Text('common_reminder'.tr()),
                ),
              ],
            ),
            if (top.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
                child: Text(
                  'empty_reminders'.tr(),
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55)),
                ),
              )
            else
              ...top.map((r) {
                final icon = _reminderIcon(r.type);
                final occ = r.nextOccurrence() ?? r.date;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: AppColors.primary, size: 20),
                  ),
                  title: Text(seedTr(r.title),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_when(r, occ)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(AppIcons.checkCircle,
                            color: AppColors.secondary, size: 24),
                        tooltip: 'common_done'.tr(),
                        onPressed: () => context
                            .read<AppProvider>()
                            .completeReminder(pet, r),
                      ),
                      const Icon(AppIcons.angleRight, size: 20),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AddReminderScreen(reminder: r))),
                );
              }),
          ],
        ),
      ),
    );
  }

  IconData _reminderIcon(ReminderType t) {
    switch (t) {
      case ReminderType.medication:
        return AppIcons.capsules;
      case ReminderType.vaccine:
        return AppIcons.syringe;
      case ReminderType.feeding:
        return AppIcons.restaurant;
      case ReminderType.walking:
        return AppIcons.walking;
      case ReminderType.grooming:
        return AppIcons.scissors;
      case ReminderType.vet:
        return AppIcons.hospital;
      case ReminderType.other:
        return AppIcons.bell;
    }
  }

  String _when(Reminder r, DateTime occ) {
    final t = DateFormat.Hm().format(occ);
    if (r.repeat != RepeatRule.none) {
      final occDay = DateTime(occ.year, occ.month, occ.day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dayLabel = occDay == today
          ? 'cal_today'.tr()
          : occDay == today.add(const Duration(days: 1))
              ? 'cal_tomorrow'.tr()
              : DateFormat('d MMM').format(occ);
      return '${repeatRuleTr(r.repeat)} · $dayLabel · $t';
    }
    final d = DateFormat('d MMM').format(occ);
    return '$d · $t';
  }
}

class _TodaySection extends StatelessWidget {
  final Pet pet;
  const _TodaySection(this.pet);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final logs = app.logs(pet).where((l) => l.isToday()).take(5).toList();
    if (logs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader('home_today_log'.tr()),
        Card(
          child: Column(
            children: logs
                .map((l) => ListTile(
                      dense: true,
                      leading: Text(l.type.icon,
                          style: const TextStyle(fontSize: 22)),
                      title: Text(
                          '${careTypeLabelTr(l.type)}${l.detail.isNotEmpty ? ' · ${seedTr(l.detail)}' : ''}'),
                      subtitle: Text(DateFormat.Hm().format(l.dateTime)),
                      trailing: IconButton(
                        icon: const Icon(AppIcons.cross, size: 18),
                        tooltip: 'common_delete'.tr(),
                        onPressed: () async {
                          if (await confirmDelete(context)) {
                            if (context.mounted) {
                              context
                                  .read<AppProvider>()
                                  .deleteLog(pet, l);
                            }
                          }
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}