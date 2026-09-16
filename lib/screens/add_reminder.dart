import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../utils/i18n_helpers.dart';
import '../widgets/common.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  late final TextEditingController _title;
  late ReminderType _type;
  late DateTime _date;
  late RepeatRule _repeat;
  late bool _enabled;
  late final TextEditingController _note;
  String? _petId;

  bool get isEdit => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _title = TextEditingController(text: r?.title ?? '');
    _type = r?.type ?? ReminderType.medication;
    _date = r?.date ?? DateTime.now().add(const Duration(hours: 1));
    _repeat = r?.repeat ?? RepeatRule.none;
    _enabled = r?.enabled ?? true;
    _note = TextEditingController(text: r?.note ?? '');
    _petId = r?.petId;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d != null && mounted) {
      setState(() => _date = DateTime(
          d.year, d.month, d.day, _date.hour, _date.minute));
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (t != null && mounted) {
      setState(() => _date =
          DateTime(_date.year, _date.month, _date.day, t.hour, t.minute));
    }
  }

  Pet? _resolvePet(AppProvider app) {
    for (final p in app.pets) {
      if (p.id == _petId) return p;
    }
    return app.currentPet ?? (app.pets.isNotEmpty ? app.pets.first : null);
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('rem_give_title'.tr())));
      return;
    }
    final app = context.read<AppProvider>();
    final pet = _resolvePet(app);
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('scn_need_pet'.tr())));
      return;
    }
    final reminder = Reminder(
      id: widget.reminder?.id,
      petId: pet.id,
      title: title,
      type: _type,
      date: _date,
      repeat: _repeat,
      enabled: _enabled,
      note: _note.text.trim(),
    );
    if (isEdit) {
      // Moving to another pet = delete from the old list, add to the new one.
      final from = widget.reminder!.petId;
      if (from != pet.id) {
        Pet? old;
        for (final p in app.pets) {
          if (p.id == from) old = p;
        }
        if (old != null) app.deleteReminder(old, widget.reminder!);
        app.addReminder(pet, reminder);
      } else {
        app.updateReminder(pet, reminder);
      }
    } else {
      app.addReminder(pet, reminder);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'rem_edit'.tr() : 'rem_new'.tr()),
        actions: [
          TextButton(
              onPressed: _save,
              child: Text('common_save'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'rem_title'.tr(),
              hintText: 'rem_title_hint'.tr(),
              prefixIcon: const Icon(AppIcons.text),
            ),
          ),
          const SizedBox(height: 14),
          Text('rem_type'.tr(), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReminderType.values.map((t) {
              return ChoiceChip(
                label: Text(reminderTypeTr(t)),
                selected: _type == t,
                onSelected: (_) => setState(() => _type = t),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text('rem_pet'.tr(), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _petId ?? app.currentPet?.id,
            decoration: const InputDecoration(prefixIcon: Icon(AppIcons.paw)),
            items: app.pets
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (v) => setState(() => _petId = v),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'rem_date'.tr(),
                      prefixIcon: const Icon(AppIcons.calendarDay),
                    ),
                    child: Text(DateFormat('d MMM yyyy').format(_date)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'rem_time'.tr(),
                      prefixIcon: const Icon(AppIcons.clock),
                    ),
                    child: Text(DateFormat.Hm().format(_date)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('rem_repeat'.tr(), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RepeatRule.values.map((rule) {
              return ChoiceChip(
                label: Text(repeatRuleTr(rule)),
                selected: _repeat == rule,
                onSelected: (_) => setState(() => _repeat = rule),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'rem_note'.tr(),
              prefixIcon: const Icon(AppIcons.notes),
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('rem_active'.tr()),
            subtitle: Text('rem_active_hint'.tr()),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          if (isEdit) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () async {
                if (await confirmDelete(context)) {
                  if (!context.mounted) return;
                  Pet? pet;
                  for (final p in app.pets) {
                    if (p.id == widget.reminder!.petId) pet = p;
                  }
                  if (pet != null) {
                    app.deleteReminder(pet, widget.reminder!);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              icon: const Icon(AppIcons.trash),
              label: Text('rem_delete'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}