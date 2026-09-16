import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../utils/i18n_helpers.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'add_pet.dart';
import 'health_forms.dart';
import 'species_care_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {

  /// Live pet: profile edits create a new Pet object, so the constructor
  /// snapshot goes stale — always resolve by id.
  Pet get pet {
    final app = context.read<AppProvider>();
    for (final p in app.pets) {
      if (p.id == widget.pet.id) return p;
    }
    return widget.pet;
  }

  @override
  Widget build(BuildContext context) {
    final gone = context
        .read<AppProvider>()
        .pets
        .every((p) => p.id != widget.pet.id);
    if (gone) {
      // Deleted from settings while open — bounce back home.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(pet.name),
          actions: [
            IconButton(
              icon: const Icon(AppIcons.trash),
              tooltip:
                  '${'common_delete'.tr()} ${pet.name}',
              onPressed: () async {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('pets_remove_confirm'
                            .tr(namedArgs: {'name': pet.name})),
                        content: Text('pets_delete_confirm'
                            .tr(namedArgs: {'name': pet.name})),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: Text('common_cancel'.tr()),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.danger),
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: Text('common_delete'.tr()),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (ok && context.mounted) {
                  context.read<AppProvider>().deletePet(pet);
                  Navigator.of(context).pop();
                }
              },
            ),
            IconButton(
              icon: const Icon(AppIcons.pencil),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPetScreen(pet: pet)));
                if (mounted) setState(() {});
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
            tabs: [
              Tab(text: 'pd_overview'.tr()),
              Tab(text: 'pd_care'.tr()),
              Tab(text: 'pd_health'.tr()),
              Tab(text: 'pd_stats'.tr()),
              Tab(text: 'pd_timeline'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Overview(pet: pet),
            SpeciesCareTab(pet: pet),
            _Health(pet: pet),
            _Stats(pet: pet),
            _Timeline(pet: pet),
          ],
        ),
      ),
    );
  }
}

/* ============================ Overview ============================ */
class _Overview extends StatelessWidget {
  final Pet pet;
  const _Overview({required this.pet});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final due = app.reminders(pet).where((r) => r.isDueNow).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Header(pet: pet),
        const SizedBox(height: 20),
        Row(
          children: [
            _StatCard(icon: AppIcons.scale, label: 'pd_weight'.tr(),
                value: pet.weightKg > 0
                    ? '${pet.weightKg} ${'unit_kg'.tr()}'
                    : '—'),
            const SizedBox(width: 12),
            _StatCard(icon: AppIcons.cakeBirthday, label: 'pd_age'.tr(),
                value: petAgeTr(pet)),
            const SizedBox(width: 12),
            _StatCard(icon: AppIcons.microchip, label: 'pd_microchip'.tr(),
                value: pet.microchip.isEmpty ? '—' : pet.microchip),
            const SizedBox(width: 12),
            _StatCard(icon: AppIcons.venusMars, label: 'pd_gender'.tr(),
                value: switch (pet.gender) {
                  'Male' => 'gender_male'.tr(),
                  'Female' => 'gender_female'.tr(),
                  _ => '—',
                }),
          ],
        ),
        if (pet.allergies.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(AppIcons.triangleWarning,
                          color: Color(0xFFF2B01E), size: 20),
                      const SizedBox(width: 8),
                      Text('pd_allergies'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pet.allergies
                        .map((a) => Chip(
                              label: Text(a),
                              backgroundColor:
                                  const Color(0xFFF2B01E).withValues(alpha: .15),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (pet.personalityNotes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('pd_personality'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(pet.personalityNotes,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7))),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (due.isNotEmpty)
          Card(
            color: AppColors.primary.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '⚠️ ${(due.length == 1 ? 'pd_due_one'.tr() : 'pd_due_many'.tr(namedArgs: {'count': '${due.length}'}))}\n${due.map((r) => '· ${seedTr(r.title)}').join('\n')}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final Pet pet;
  const _Header({required this.pet});

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.speciesTint(pet.species.name);
    final wash = AppColors.speciesWash(pet.species.name);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tint.withValues(alpha: 0.28), wash],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: tint.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          PetAvatar(pet: pet, radius: 38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(pet.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    if (pet.isFavorite) const Icon(AppIcons.star, color: AppColors.accent, size: 20),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${speciesLabelTr(pet.species)}${pet.breed.isNotEmpty ? ' · ${pet.breed}' : ''}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.muted)),
                const SizedBox(height: 8),
                SpeciesPill(
                    speciesName: pet.species.name, emoji: pet.speciesEmoji),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(height: 6),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================ Health ============================ */
class _Health extends StatelessWidget {
  final Pet pet;
  const _Health({required this.pet});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final vaccines = app.vaccines(pet);
    final meds = app.medications(pet);
    final visits = app.visits(pet);
    final weights = app.weights(pet);
    final symptoms = app.symptoms(pet);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionBox(
          title: 'pd_vaccines'.tr(),
          icon: AppIcons.syringe,
          onAdd: () async {
            final v = await vaccineSheet(context, pet.id, null);
            if (v != null && context.mounted) {
              context.read<AppProvider>().addVaccine(pet, v);
            }
          },
          child: vaccines.isEmpty
              ? _Muted('pd_empty_vaccines'.tr())
              : Column(
                  children: vaccines
                      .map((v) => _Tile(
                            icon: AppIcons.syringe,
                            color: AppColors.secondary,
                            title: v.name,
                            subtitle: _dateLabel(v.date) +
                                (v.nextDue == null
                                    ? ''
                                    : ' · ${'pd_boost_due'.tr(namedArgs: {'date': _dateLabel(v.nextDue!)})}'),
                            onDelete: () =>
                                context.read<AppProvider>().deleteVaccine(pet, v),
                          ))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionBox(
          title: 'pd_meds'.tr(),
          icon: AppIcons.capsules,
          onAdd: () async {
            final m = await medicationSheet(context, pet.id, null);
            if (m != null && context.mounted) {
              context.read<AppProvider>().addMedication(pet, m);
            }
          },
          child: meds.isEmpty
              ? _Muted('pd_empty_meds'.tr())
              : Column(
                  children: meds
                      .map((m) => _Tile(
                            icon: AppIcons.capsules,
                            color: const Color(0xFF7C4DFF),
                            title: m.name,
                            subtitle:
                                '${m.dosage.isNotEmpty ? m.dosage + ' · ' : ''}${_freqTr(m.frequency)}',
                            onDelete: () =>
                                context.read<AppProvider>().deleteMedication(pet, m),
                          ))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionBox(
          title: 'pd_visits'.tr(),
          icon: AppIcons.hospital,
          onAdd: () async {
            final v = await visitSheet(context, pet.id);
            if (v != null && context.mounted) {
              context.read<AppProvider>().addVisit(pet, v);
            }
          },
          child: visits.isEmpty
              ? _Muted('pd_empty_visits'.tr())
              : Column(
                  children: visits
                      .map((v) => _Tile(
                            icon: AppIcons.hospital,
                            color: const Color(0xFF2196F3),
                            title: v.reason.isEmpty ? 'pd_visit_fallback'.tr() : v.reason,
                            subtitle: _dateLabel(v.date) +
                                (v.vetName.isNotEmpty ? ' · ${v.vetName}' : '') +
                                (v.cost > 0
                                    ? ' · ${_money(v.cost)}'
                                    : ''),
                            onDelete: () =>
                                context.read<AppProvider>().deleteVisit(pet, v),
                            onTap: () async {
                              final updated =
                                  await visitSheet(context, pet.id, v);
                              if (updated != null && context.mounted) {
                                context
                                    .read<AppProvider>()
                                    .updateVisit(pet, updated);
                              }
                            },
                          ))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionBox(
          title: 'pd_weight_log'.tr(),
          icon: AppIcons.scale,
          onAdd: () async {
            final w = await weightSheet(context, pet.id, pet.weightKg);
            if (w != null && context.mounted) {
              context.read<AppProvider>().addWeight(pet, w);
            }
          },
          child: weights.isEmpty
              ? _Muted('pd_empty_weight'.tr())
              : Column(
                  children: weights
                      .take(6)
                      .map((w) => _Tile(
                            icon: AppIcons.scale,
                            color: AppColors.accent,
                            title: '${w.weight} ${'unit_kg'.tr()}',
                            subtitle: _dateLabel(w.date),
                            onDelete: () => context
                                .read<AppProvider>()
                                .deleteWeight(pet, w),
                          ))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionBox(
          title: 'pd_symptoms'.tr(),
          icon: AppIcons.shieldCheck,
          onAdd: () async {
            final s = await symptomSheet(context, pet.id);
            if (s != null && context.mounted) {
              context.read<AppProvider>().addSymptom(pet, s);
            }
          },
          child: symptoms.isEmpty
              ? _Muted('pd_empty_symptoms'.tr())
              : Column(
                  children: symptoms
                      .take(6)
                      .map((s) => _Tile(
                            icon: AppIcons.heart,
                            color: _severityColor(s.severity),
                            title: s.symptom,
                            subtitle: _dateLabel(s.date) +
                                ' · ${'pd_severity'.tr(namedArgs: {'s': '${s.severity}'})}',
                            onDelete: () => context
                                .read<AppProvider>()
                                .deleteSymptom(pet, s),
                          ))
                      .toList(),
                ),
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 40),
      ],
    );
  }

  Color _severityColor(int sev) {
    if (sev >= 4) return const Color(0xFFE05B4D);
    if (sev >= 3) return const Color(0xFFF26201);
    return const Color(0xFF6EC6A1);
  }
}

class _SectionBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onAdd;
  final Widget child;

  const _SectionBox({
    required this.title,
    required this.icon,
    required this.onAdd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(AppIcons.plus, size: 18),
                  label: Text('common_add'.tr()),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: IconButton(
        icon: const Icon(AppIcons.trash, size: 18),
        tooltip: 'common_delete'.tr(),
        onPressed: () async {
          if (await confirmDelete(context)) onDelete();
        },
      ),
    );
  }
}

class _Muted extends StatelessWidget {
  final String text;
  const _Muted(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
    );
  }
}

/* ============================ Stats ============================ */
class _Stats extends StatelessWidget {
  final Pet pet;
  const _Stats({required this.pet});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final weights = app.weights(pet);
    final logs = app.logs(pet);
    final expenses = app.expenses(pet);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.scale,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('pd_weight_trend'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Text(
                      pet.weightKg > 0
                          ? '${pet.weightKg} ${'unit_kg'.tr()}'
                          : '',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RepaintBoundary(
                  child: WeightChart(
                    weights: weights,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.chartSimple,
                        color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text('pd_activity'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                RepaintBoundary(child: ActivityChart(logs: logs)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ExpensesCard(pet: pet, expenses: expenses),
      ],
    );
  }
}

class _ExpensesCard extends StatelessWidget {
  final Pet pet;
  final List<Expense> expenses;

  const _ExpensesCard({required this.pet, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final monthTotal = expenses
        .where((e) =>
            e.date.month == DateTime.now().month &&
            e.date.year == DateTime.now().year)
        .fold(0.0, (sum, e) => sum + e.amount);
    final allTotal = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.piggyBank,
                    color: Color(0xFF7C4DFF), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('pd_expenses'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final e = await expenseSheet(context, pet.id);
                    if (e != null && context.mounted) {
                      context.read<AppProvider>().addExpense(pet, e);
                    }
                  },
                  icon: const Icon(AppIcons.plus, size: 18),
                  label: Text('common_log'.tr()),
                ),
              ],
            ),
            Row(
              children: [
                _ExpenseStat(
                    label: 'pd_this_month'.tr(),
                    value: _money(monthTotal)),
                const SizedBox(width: 12),
                _ExpenseStat(
                    label: 'pd_all_time'.tr(), value: _money(allTotal)),
              ],
            ),
            const SizedBox(height: 8),
            if (expenses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'pd_empty_expenses'.tr(),
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .5)),
                ),
              )
            else
              ...expenses.take(5).map((e) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Text(_catEmoji(e.category),
                        style: const TextStyle(fontSize: 20)),
                    title: Text(_expenseTitle(e),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${DateFormat('d MMM').format(e.date)} · ${expenseCatTr(e.category)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('-${_money(e.amount)}',
                            style: const TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700)),
                        IconButton(
                          icon: const Icon(AppIcons.cross, size: 16),
                          tooltip: 'common_delete'.tr(),
                          onPressed: () async {
                            if (await confirmDelete(context)) {
                              if (context.mounted) {
                                context
                                    .read<AppProvider>()
                                    .deleteExpense(pet, e);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

/// Expense titles stored as `cat:<name>` render translated; legacy and
/// custom titles show raw.
String _expenseTitle(Expense e) {
  if (e.title.startsWith('cat:')) {
    final name = e.title.substring(4);
    for (final c in ExpenseCategory.values) {
      if (c.name == name) return expenseCatTr(c);
    }
  }
  return e.title;
}

String _catEmoji(ExpenseCategory c) {
    switch (c) {
      case ExpenseCategory.food:
        return '🍖';
      case ExpenseCategory.vet:
        return '🏥';
      case ExpenseCategory.grooming:
        return '✂️';
      case ExpenseCategory.supplies:
        return '🎾';
      case ExpenseCategory.medication:
        return '💊';
      case ExpenseCategory.other:
        return '📌';
    }
  }
}

class _ExpenseStat extends StatelessWidget {
  final String label;
  final String value;

  const _ExpenseStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF7C4DFF).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C4DFF))),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

/* ============================ Timeline ============================ */
class _Timeline extends StatelessWidget {
  final Pet pet;
  const _Timeline({required this.pet});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final logs = app.logs(pet);
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐾', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('pd_empty_timeline'.tr()),
              const SizedBox(height: 6),
              Text('pd_empty_timeline_sub'.tr(),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    final grouped = <String, List<CareLogEntry>>{};
    for (final log in logs) {
      final key = DateFormat('d MMMM yyyy').format(log.dateTime);
      grouped.putIfAbsent(key, () => []).add(log);
    }
    final entries = grouped.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(entry.key,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14)),
            ),
            Card(
              child: Column(
                children: entry.value
                    .map((l) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        leading: Text(l.type.icon,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(
                            '${careTypeLabelTr(l.type)}${l.detail.isNotEmpty ? ' · ${seedTr(l.detail)}' : ''}'),
                        subtitle: Text(
                            DateFormat('HH:mm').format(l.dateTime) +
                                (l.note.isNotEmpty ? ' · ${l.note}' : '')),
                        trailing: IconButton(
                          icon: const Icon(AppIcons.cross, size: 18),
                          tooltip: 'common_delete'.tr(),
                          onPressed: () async {
                            if (await confirmDelete(context)) {
                              if (context.mounted) {
                                context.read<AppProvider>().deleteLog(pet, l);
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
      },
    );
  }
}

String _dateLabel(DateTime d) => DateFormat('d MMM yyyy').format(d);

/// Canonical 'Daily' (stored by old form versions) renders translated.
String _freqTr(String f) => f == 'Daily' ? 'remrep_daily'.tr() : f;

String _money(double v) =>
    NumberFormat.simpleCurrency().format(v);