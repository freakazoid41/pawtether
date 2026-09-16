import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../utils/i18n_helpers.dart';
import '../widgets/common.dart';

const _emojis = ['📋', '🧴', '💊', '🦷', '✂️', '🧼', '🐾', '💧', '🏃', '😴', '🩺', '🎾'];

class RoutinesScreen extends StatelessWidget {
  final Pet pet;

  const RoutinesScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final routines = app.routines(pet);
    return Scaffold(
      appBar: AppBar(title: Text('rou_title'.tr(namedArgs: {'name': pet.name}))),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(AppIcons.plus),
        label: Text('rou_new'.tr()),
        onPressed: () => _showForm(context, app, null),
      ),
      body: routines.isEmpty
          ? EmptyState(
              emoji: '📋',
              title: 'empty_routines'.tr(),
              subtitle: 'home_today_checklist'.tr(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: routines
                  .map((r) => _RoutineCard(
                        routine: r,
                        onEdit: () => _showForm(context, app, r),
                        onDelete: () async {
                          if (await confirmDelete(context)) {
                            if (context.mounted) {
                              app.deleteRoutine(pet, r);
                            }
                          }
                        },
                      ))
                  .toList(),
            ),
    );
  }

  void _showForm(BuildContext context, AppProvider app, CareRoutine? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoutineFormSheet(pet: pet, existing: existing),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final CareRoutine routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoutineCard({
    required this.routine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    final progress = routine.completedCount;
    final total = routine.itemCount;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(routine.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(seedTr(routine.name),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(AppIcons.pencil, size: 18),
                  onPressed: onEdit,
                  tooltip: 'tooltip_edit'.tr(),
                ),
                IconButton(
                  icon: const Icon(AppIcons.trash,
                      size: 18, color: AppColors.danger),
                  onPressed: onDelete,
                  tooltip: 'common_delete'.tr(),
                ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress / total,
                color: AppColors.secondary,
                backgroundColor: AppColors.secondary.withValues(alpha: .12),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text('rou_done'.tr(namedArgs: {'done': '$progress', 'total': '$total'}),
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .55))),
              const SizedBox(height: 10),
            ],
            if (routine.items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'rou_no_items'.tr(),
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .5)),
                ),
              )
            else
              ...routine.items.map((item) {
                final done = routine.isDone(item.id);
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: done,
                  title: Text(seedTr(item.title),
                      style: TextStyle(
                        decoration:
                            done ? TextDecoration.lineThrough : null,
                        color: done
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: .5)
                            : null,
                      )),
                  onChanged: (_) {
                    Pet? p;
                    for (final pet in app.pets) {
                      if (pet.id == routine.petId) p = pet;
                    }
                    if (p != null) {
                      context
                          .read<AppProvider>()
                          .toggleRoutineItem(p, routine, item);
                    }
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class RoutineFormSheet extends StatefulWidget {
  final Pet pet;
  final CareRoutine? existing;

  const RoutineFormSheet({super.key, required this.pet, this.existing});

  @override
  State<RoutineFormSheet> createState() => _RoutineFormSheetState();
}

class _RoutineFormSheetState extends State<RoutineFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _items;
  late String _emoji;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _name = TextEditingController(text: r?.name ?? '');
    _items = TextEditingController(
        text: (r?.items ?? []).map((i) => i.title).join('\n'));
    _emoji = r?.emoji ?? '📋';
  }

  @override
  void dispose() {
    _name.dispose();
    _items.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('rou_give_name'.tr())));
      return;
    }
    final lines = _items.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final app = context.read<AppProvider>();
    if (isEdit) {
      final r = widget.existing!;
      // Match by title so surviving items keep their IDs — and their ticks.
      final oldByTitle = {
        for (final i in r.items) i.title.toLowerCase(): i
      };
      r.name = name;
      r.emoji = _emoji;
      r.items = [
        for (final l in lines)
          oldByTitle[l.toLowerCase()] ?? RoutineItem(title: l)
      ];
      // Adopt the edited casing; IDs (and ticks) survive.
      for (final i in r.items) {
        i.title =
            lines.firstWhere((l) => l.toLowerCase() == i.title.toLowerCase());
      }
      final keep = r.items.map((i) => i.id).toSet();
      r.doneIds = r.doneIds.where(keep.contains).toList();
      app.updateRoutine(widget.pet, r);
    } else {
      app.addRoutine(widget.pet, CareRoutine(
        petId: widget.pet.id,
        name: name,
        emoji: _emoji,
        items: [for (final l in lines) RoutineItem(title: l)],
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(isEdit ? 'rou_edit'.tr() : 'rou_new'.tr(),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('rou_icon'.tr(), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emojis.map((e) {
                    final selected = _emoji == e;
                    return ChoiceChip(
                      label: Text(e, style: const TextStyle(fontSize: 20)),
                      selected: selected,
                      onSelected: (_) => setState(() => _emoji = e),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: 'rou_name'.tr(), hintText: 'rou_name_hint'.tr()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _items,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'rou_items'.tr(),
                    hintText: 'rou_items_hint'.tr(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _save,
                    child: Text('common_save'.tr(), style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}