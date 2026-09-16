import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../models/models.dart';
import '../utils/i18n_helpers.dart';

/// Generic modal sheet used by all record forms.
/// Builds a rounded bottom sheet with a title, fields and a Save button.
class RecordSheet<T> extends StatefulWidget {
  final String title;
  final List<Widget> Function(BuildContext context, StateSetter setState)
      fields;
  /// Null = invalid input: the sheet stays open with a hint snackbar.
  final T? Function() onSave;

  const RecordSheet({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
  });

  @override
  State<RecordSheet<T>> createState() => _RecordSheetState<T>();
}

class _RecordSheetState<T> extends State<RecordSheet<T>> {
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
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.title,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(AppIcons.cross),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...widget.fields(context, (_) => setState(() {})),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      final v = widget.onSave();
                      if (v == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('form_invalid'.tr())));
                      } else {
                        Navigator.pop(context, v);
                      }
                    },
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

Widget _textField(TextEditingController c, String label,
    {TextInputType? kbd, bool multi = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: kbd,
      maxLines: multi ? 3 : 1,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

Widget _dateField(DateTime date, VoidCallback onPick) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'hf_date'.tr(),
          prefixIcon: const Icon(AppIcons.calendarDay),
        ),
        child: Text(DateFormat('d MMM yyyy').format(date)),
      ),
    ),
  );
}

Future<DateTime?> _pickDate(BuildContext context, DateTime initial) =>
    showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 12)),
    );

Future<T?> _showForm<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => child,
  );
}

/* ============================ Vaccine ============================ */
Future<Vaccine?> vaccineSheet(
    BuildContext context, String petId, Vaccine? existing) {
  final name = TextEditingController(text: existing?.name ?? '');
  final vet = TextEditingController(text: existing?.vet ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  var date = existing?.date ?? DateTime.now();
  var due = existing?.nextDue;
  return _showForm<Vaccine>(
    context,
    RecordSheet<Vaccine>(
      title: existing == null ? 'hf_new_vaccine'.tr() : 'hf_edit_vaccine'.tr(),
      fields: (context, setState) => [
        _textField(name, 'hf_vaccine_name'.tr()),
        _dateField(date, () async {
          final d = await _pickDate(context, date);
          if (d != null) {
            setState(() => date = d);
          }
        }),
        _textField(vet, 'hf_vet_clinic'.tr()),
        TextButton.icon(
          onPressed: () async {
            final d = await _pickDate(context,
                due ?? DateTime.now().add(const Duration(days: 365)));
            if (d != null) setState(() => due = d);
          },
          icon: const Icon(AppIcons.calendarCheck),
          label: Text(due == null
              ? 'hf_booster_set'.tr()
              : 'hf_booster_due'.tr(namedArgs: {
                  'date': DateFormat('d MMM yyyy').format(due!)
                })),
        ),
        _textField(notes, 'hf_notes'.tr(), multi: true),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return null;
        return Vaccine(
          id: existing?.id,
          petId: petId,
          name: name.text.trim(),
          date: date,
          nextDue: due,
          vet: vet.text.trim(),
          notes: notes.text.trim(),
        );
      },
    ),
  );
}

/* ============================ Medication ============================ */
Future<Medication?> medicationSheet(
    BuildContext context, String petId, Medication? existing) {
  final name = TextEditingController(text: existing?.name ?? '');
  final dosage = TextEditingController(text: existing?.dosage ?? '');
  final frequency = TextEditingController(text: existing?.frequency ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  var start = existing?.startDate ?? DateTime.now();
  return _showForm<Medication>(
    context,
    RecordSheet<Medication>(
      title: existing == null ? 'hf_new_med'.tr() : 'hf_edit_med'.tr(),
      fields: (context, setState) => [
        _textField(name, 'hf_med_name'.tr()),
        _textField(dosage, 'hf_dosage'.tr()),
        _textField(frequency, 'hf_frequency'.tr()),
        _dateField(start, () async {
          final d = await _pickDate(context, start);
          if (d != null) setState(() => start = d);
        }),
        _textField(notes, 'hf_notes'.tr(), multi: true),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return null;
        final freq = frequency.text.trim();
        return Medication(
          id: existing?.id,
          petId: petId,
          name: name.text.trim(),
          dosage: dosage.text.trim(),
          // Canonical English in storage — never a translated string.
          frequency: freq.isEmpty ? 'Daily' : freq,
          startDate: start,
          endDate: existing?.endDate,
          notes: notes.text.trim(),
        );
      },
    ),
  );
}

/* ============================ Vet visit ============================ */
Future<VetVisit?> visitSheet(BuildContext context, String petId,
    [VetVisit? existing]) {
  final reason = TextEditingController(text: existing?.reason ?? '');
  final vet = TextEditingController(text: existing?.vetName ?? '');
  final diagnosis = TextEditingController(text: existing?.diagnosis ?? '');
  final cost = TextEditingController(
      text: existing != null && existing.cost > 0
          ? existing.cost.toStringAsFixed(0)
          : '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  var date = existing?.date ?? DateTime.now();
  return _showForm<VetVisit>(
    context,
    RecordSheet<VetVisit>(
      title: existing == null ? 'hf_new_visit'.tr() : 'hf_edit_visit'.tr(),
      fields: (context, setState) => [
        _textField(reason, 'hf_reason'.tr()),
        _dateField(date, () async {
          final d = await _pickDate(context, date);
          if (d != null) setState(() => date = d);
        }),
        _textField(vet, 'hf_vet_name'.tr()),
        _textField(diagnosis, 'hf_diagnosis'.tr()),
        _textField(cost, 'hf_cost'.tr(),
            kbd: const TextInputType.numberWithOptions(decimal: true)),
        _textField(notes, 'hf_notes'.tr(), multi: true),
      ],
      onSave: () {
        if (reason.text.trim().isEmpty) return null;
        return VetVisit(
          id: existing?.id,
          petId: petId,
          date: date,
          reason: reason.text.trim(),
          vetName: vet.text.trim(),
          diagnosis: diagnosis.text.trim(),
          cost: double.tryParse(cost.text.trim()) ?? 0,
          notes: notes.text.trim(),
        );
      },
    ),
  );
}

/* ============================ Weight ============================ */
Future<WeightEntry?> weightSheet(
    BuildContext context, String petId, double? currentWeight) {
  final weight =
      TextEditingController(text: currentWeight?.toString() ?? '');
  var date = DateTime.now();
  return _showForm<WeightEntry>(
    context,
    RecordSheet<WeightEntry>(
      title: 'hf_log_weight'.tr(),
      fields: (context, setState) => [
        _textField(weight, 'hf_weight'.tr(),
            kbd: const TextInputType.numberWithOptions(decimal: true)),
        _dateField(date, () async {
          final d = await _pickDate(context, date);
          if (d != null) setState(() => date = d);
        }),
      ],
      onSave: () {
        final w = double.tryParse(weight.text.trim());
        if (w == null || w <= 0) return null;
        return WeightEntry(petId: petId, date: date, weight: w);
      },
    ),
  );
}

/* ============================ Expense ============================ */
Future<Expense?> expenseSheet(BuildContext context, String petId) {
  final title = TextEditingController();
  final amount = TextEditingController();
  final notes = TextEditingController();
  var date = DateTime.now();
  var category = ExpenseCategory.food;
  return _showForm<Expense>(
    context,
    RecordSheet<Expense>(
      title: 'hf_log_expense'.tr(),
      fields: (context, setState) => [
        _textField(title, 'hf_expense_for'.tr()),
        Row(
          children: [
            Expanded(
              child: _textField(amount, 'hf_amount'.tr(),
                  kbd: const TextInputType.numberWithOptions(decimal: true)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dateField(date, () async {
                final d = await _pickDate(context, date);
                if (d != null) setState(() => date = d);
              }),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child:
              Text('hf_category'.tr(), style: Theme.of(context).textTheme.titleSmall),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExpenseCategory.values.map((c) {
            return ChoiceChip(
              avatar: Text(_catEmoji(c)),
              label: Text(expenseCatTr(c)),
              selected: category == c,
              onSelected: (_) => setState(() => category = c),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _textField(notes, 'hf_notes'.tr(), multi: true),
      ],
      onSave: () {
        final amt = double.tryParse(amount.text.trim());
        if (amt == null || amt <= 0) return null;
        final t = title.text.trim();
        return Expense(
          petId: petId,
          // Category key in storage — UI translates at display time.
          title: t.isEmpty ? 'cat:${category.name}' : t,
          category: category,
          amount: amt,
          date: date,
          notes: notes.text.trim(),
        );
      },
    ),
  );
}

String _catEmoji(ExpenseCategory c) {  switch (c) {
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
/* ============================ Symptom ============================ */
Future<SymptomEntry?> symptomSheet(BuildContext context, String petId) {
  final symptom = TextEditingController();
  final notes = TextEditingController();
  var date = DateTime.now();
  var severity = 2;
  return _showForm<SymptomEntry>(
    context,
    RecordSheet<SymptomEntry>(
      title: 'hf_log_symptom'.tr(),
      fields: (context, setState) => [
        _textField(symptom, 'hf_symptom_what'.tr()),
        _dateField(date, () async {
          final d = await _pickDate(context, date);
          if (d != null) setState(() => date = d);
        }),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child:
              Text('hf_severity'.tr(), style: Theme.of(context).textTheme.titleSmall),
        ),
        Row(
          children: List.generate(5, (i) {
            final filled = i < severity;
            return IconButton(
              onPressed: () => setState(() => severity = i + 1),
              icon: Icon(
                i < severity ? AppIcons.heart : AppIcons.heart,
                color: filled ? Colors.redAccent : Colors.grey,
              ),
            );
          }),
        ),
        _textField(notes, 'hf_notes'.tr(), multi: true),
      ],
      onSave: () {
        final s = symptom.text.trim();
        if (s.isEmpty) return null;
        return SymptomEntry(
          petId: petId,
          date: date,
          symptom: s,
          severity: severity,
          notes: notes.text.trim(),
        );
      },
    ),
  );
}