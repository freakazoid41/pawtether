import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_care.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../widgets/common.dart';
import 'quick_log.dart';

/// Species-specific care guide: needs, medicines, vaccines, toxic foods.
/// Guide content is English-base (like seeds); chrome is translated.
/// Zero image assets — emoji + tinted washes only (image-budget safe).
class SpeciesCareTab extends StatelessWidget {
  final Pet pet;
  const SpeciesCareTab({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final care = careFor(pet.species);
    final tint = care.tint;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        MascotHeader(
          emoji: care.emoji,
          tint: tint,
          title: speciesCareTitle(pet),
          subtitle: care.tagline,
          speciesName: pet.species.name,
        ),
        const SizedBox(height: 16),
        const PawDivider(),
        const SizedBox(height: 8),
        SectionHeader('spc_needs'.tr()),
        ...care.needs.map((n) => _NeedCard(pet: pet, need: n, tint: tint)),
        const SizedBox(height: 16),
        SectionHeader('spc_meds'.tr()),
        CozyBanner(
          emoji: '⚠️',
          text: 'spc_vet_note'.tr(),
          tint: AppColors.honey,
          wash: AppColors.honey,
        ),
        const SizedBox(height: 10),
        ...care.medicines.map((m) => _MedicineCard(pet: pet, med: m)),
        const SizedBox(height: 16),
        SectionHeader('spc_vaccines'.tr()),
        ...care.vaccines.map((v) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Text('💉', style: TextStyle(fontSize: 22)),
                title: Text(v.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(v.schedule),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (v.loggable)
                      IconButton(
                        icon: const Icon(AppIcons.checkCircle,
                            color: AppColors.secondary),
                        tooltip: 'common_log'.tr(),
                        onPressed: () => _logVaccine(context, pet, v),
                      ),
                    IconButton(
                      icon: const Icon(AppIcons.alarmPlus,
                          color: AppColors.primary),
                      tooltip: 'spc_remind'.tr(),
                      onPressed: () => _remind(context, pet, v.name,
                          ReminderType.vaccine, RepeatRule.none, v.remindInDays),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        SectionHeader('spc_toxic'.tr()),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border:
                Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: care.toxicFoods
                .map((f) => Chip(
                      avatar: const Text('☠️'),
                      label: Text(f),
                      backgroundColor:
                          AppColors.danger.withValues(alpha: 0.1),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  String speciesCareTitle(Pet p) =>
      'spc_title'.tr(namedArgs: {'name': p.name});

  void _remind(BuildContext context, Pet pet, String title,
      ReminderType type, RepeatRule repeat, int inDays) {
    final app = context.read<AppProvider>();
    app.addReminder(
      pet,
      Reminder(
        petId: pet.id,
        title: title,
        type: type,
        date: DateTime.now().add(Duration(days: inDays)),
        repeat: repeat,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('spc_reminder_set'.tr())),
    );
  }

  void _logVaccine(BuildContext context, Pet pet, SpeciesVaccine v) {
    final app = context.read<AppProvider>();
    final already =
        app.vaccines(pet).any((x) => x.name.toLowerCase() == v.name.toLowerCase());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(already ? 'spc_already'.tr() : 'spc_logged'.tr())),
    );
    if (!already) {
      app.addVaccine(
        pet,
        Vaccine(petId: pet.id, name: v.name, date: DateTime.now()),
      );
    }
  }
}

class _NeedCard extends StatelessWidget {
  final Pet pet;
  final SpeciesNeed need;
  final Color tint;
  const _NeedCard({required this.pet, required this.need, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: tint.withValues(alpha: 0.4)),
              ),
              alignment: Alignment.center,
              child: Text(need.icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(need.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(need.detail,
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.72))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(_freqLabel(need.frequency)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.meadow,
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => QuickLogSheet.show(
                          context,
                          pet,
                          need.quickLog,
                          initialNote: need.title,
                        ),
                        icon: const Icon(AppIcons.checkCircle, size: 18),
                        label: Text('common_log'.tr()),
                      ),
                      TextButton.icon(
                        onPressed: () => _remindForNeed(context),
                        icon: const Icon(AppIcons.alarmPlus, size: 18),
                        label: Text('spc_remind'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _freqLabel(NeedFrequency f) => switch (f) {
        NeedFrequency.daily => 'remrep_daily'.tr(),
        NeedFrequency.weekly => 'remrep_weekly'.tr(),
        NeedFrequency.monthly => 'remrep_monthly'.tr(),
        NeedFrequency.periodic => 'spc_periodic'.tr(),
      };

  void _remindForNeed(BuildContext context) {
    context.read<AppProvider>().addReminder(
          pet,
          Reminder(
            petId: pet.id,
            title: '${need.icon} ${need.title}',
            type: need.remindAs,
            date: DateTime.now().add(const Duration(days: 1)),
            repeat: repeatForNeed(need.frequency),
            note: need.detail,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('spc_reminder_set'.tr())),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Pet pet;
  final SpeciesMedicine med;
  const _MedicineCard({required this.pet, required this.med});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(med.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Chip(
                  label: Text(_freqLabel(med.frequency)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      AppColors.honey.withValues(alpha: 0.35),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('🩺 ${med.use}',
                style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 2),
            Text('📏 ${med.doseHint}',
                style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7))),
            const SizedBox(height: 2),
            Text('⚠️ ${med.warning}',
                style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.danger)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => QuickLogSheet.show(
                    context,
                    pet,
                    CareType.medication,
                    initialDetail: null,
                    initialNote: med.name,
                  ),
                  icon: const Icon(AppIcons.checkCircle, size: 18),
                  label: Text('common_log'.tr()),
                ),
                TextButton.icon(
                  onPressed: () => _remindForMed(context),
                  icon: const Icon(AppIcons.alarmPlus, size: 18),
                  label: Text('spc_remind'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _freqLabel(NeedFrequency f) => switch (f) {
        NeedFrequency.daily => 'remrep_daily'.tr(),
        NeedFrequency.weekly => 'remrep_weekly'.tr(),
        NeedFrequency.monthly => 'remrep_monthly'.tr(),
        NeedFrequency.periodic => 'spc_periodic'.tr(),
      };

  void _remindForMed(BuildContext context) {
    context.read<AppProvider>().addReminder(
          pet,
          Reminder(
            petId: pet.id,
            title: '💊 ${med.name}',
            type: med.remindAs,
            date: DateTime.now().add(const Duration(days: 1)),
            repeat: repeatForNeed(med.frequency),
            note: '${med.use} · ${med.doseHint}',
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('spc_reminder_set'.tr())),
    );
  }
}
