import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../utils/i18n_helpers.dart';

class QuickLogSheet extends StatefulWidget {
  final Pet pet;
  final CareType type;
  final String? initialDetail;
  final String? initialNote;

  const QuickLogSheet({
    super.key,
    required this.pet,
    required this.type,
    this.initialDetail,
    this.initialNote,
  });

  static Future<void> show(
    BuildContext context,
    Pet pet,
    CareType type, {
    String? initialDetail,
    String? initialNote,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickLogSheet(
        pet: pet,
        type: type,
        initialDetail: initialDetail,
        initialNote: initialNote,
      ),
    );
  }

  @override
  State<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<QuickLogSheet> {
  final _note = TextEditingController();
  late String _detail = widget.initialDetail ?? '';

  @override
  void initState() {
    super.initState();
    if (widget.initialNote != null) {
      _note.text = widget.initialNote!;
    }
  }

  /// Canonical English details (what gets stored — stable across locales).
  static const Map<CareType, List<String>> _detailEn = {
    CareType.feeding: ['Breakfast', 'Lunch', 'Dinner', 'Treat', 'Snack'],
    CareType.walking: ['Short walk', 'Long walk', 'Off-leash', 'Bathroom'],
    CareType.potty: ['Pee', 'Poo', 'Both'],
    CareType.medication: ['Pill', 'Liquid', 'Injection', 'Topical'],
    CareType.water: ['Filled bowl', 'Refilled'],
    CareType.grooming: ['Brush', 'Bath', 'Nail trim', 'Ears'],
    CareType.sleep: ['Nap', 'Night sleep'],
    CareType.other: ['Other'],
  };

  /// Display keys parallel to [_detailEn].
  static const Map<CareType, List<String>> _detailKeys = {
    CareType.feeding: [
      'ql_opt_breakfast',
      'ql_opt_lunch',
      'ql_opt_dinner',
      'ql_opt_treat',
      'ql_opt_snack'
    ],
    CareType.walking: [
      'ql_opt_short',
      'ql_opt_long',
      'ql_opt_offleash',
      'ql_opt_bathroom'
    ],
    CareType.potty: ['ql_opt_pee', 'ql_opt_poo', 'ql_opt_both'],
    CareType.medication: [
      'ql_opt_pill',
      'ql_opt_liquid',
      'ql_opt_injection',
      'ql_opt_topical'
    ],
    CareType.water: ['ql_opt_filled', 'ql_opt_refilled'],
    CareType.grooming: [
      'ql_opt_brush',
      'ql_opt_bath',
      'ql_opt_nails',
      'ql_opt_ears'
    ],
    CareType.sleep: ['ql_opt_nap', 'ql_opt_night'],
    CareType.other: ['ql_opt_other'],
  };

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final app = context.read<AppProvider>();
    app.addLog(
      widget.pet,
      CareLogEntry(
        petId: widget.pet.id,
        dateTime: DateTime.now(),
        type: widget.type,
        detail: _detail,
        note: _note.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canon = _detailEn[widget.type] ?? const ['Other'];
    final keys = _detailKeys[widget.type] ?? const ['ql_opt_other'];
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
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
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(widget.type.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Text(
                      'ql_title'.tr(namedArgs: {
                        'log': 'ql_log'.tr(),
                        'type': careTypeLabelTr(widget.type)
                      }),
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              // Custom option pills with explicit colors — stock ChoiceChip
              // washed out (cream-on-cream / white-on-cream) in both modes.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < canon.length; i++)
                    _OptionPill(
                      label: keys[i].tr(),
                      selected: _detail == canon[i],
                      onTap: () {
                        final value = canon[i];
                        setState(
                            () => _detail = _detail == value ? '' : value);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                decoration: InputDecoration(
                  labelText: 'ql_note'.tr(),
                  hintText: 'ql_note_hint'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _save,
                  child: Text('ql_log_it'.tr(),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail option pill with explicit colors in both modes.
/// Selected = solid tangerine + white; unselected = surface + ink + border.
class _OptionPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF8A4C)
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFE06A28)
                : cs.outlineVariant.withValues(alpha: 0.9),
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : cs.onSurface)),
      ),
    );
  }
}
