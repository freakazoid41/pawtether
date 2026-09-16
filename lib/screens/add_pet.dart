import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../storage/image_helper.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../theme/species_art.dart';
import '../widgets/common.dart';

class AddPetScreen extends StatefulWidget {
  final Pet? pet;

  const AddPetScreen({super.key, this.pet});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _weight;
  late final TextEditingController _microchip;
  late final TextEditingController _notes;
  final TextEditingController _allergyInput = TextEditingController();
  late List<String> _allergies;

  late Species _species;
  late String _gender;
  DateTime? _birthday;
  String? _imagePath;

  bool get isEdit => widget.pet != null;

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    _name = TextEditingController(text: p?.name ?? '');
    _breed = TextEditingController(text: p?.breed ?? '');
    _gender = p?.gender ?? 'Unknown';
    _weight = TextEditingController(
        text: p != null && p.weightKg > 0 ? p.weightKg.toString() : '');
    _microchip = TextEditingController(text: p?.microchip ?? '');
    _notes = TextEditingController(text: p?.personalityNotes ?? '');
    _allergies = List<String>.from(p?.allergies ?? []);
    _species = p?.species ?? Species.dog;
    _birthday = p?.birthday;
    _imagePath = p?.imagePath;
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _weight.dispose();
    _microchip.dispose();
    _notes.dispose();
    _allergyInput.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await ImageHelper.pickAndStore();
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _pickBirthday() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2021),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birthday = d);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final pet = Pet(
      id: widget.pet?.id,
      name: _name.text.trim(),
      species: _species,
      breed: _breed.text.trim(),
      birthday: _birthday,
      gender: _gender,
      weightKg: double.tryParse(_weight.text.trim()) ?? 0,
      microchip: _microchip.text.trim(),
      personalityNotes: _notes.text.trim(),
      allergies: _allergies,
      imagePath: _imagePath ?? '',
      isFavorite: widget.pet?.isFavorite ?? false,
      createdAt: widget.pet?.createdAt,
    );
    if (isEdit) {
      app.updatePet(pet);
    } else {
      app.addPet(pet);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? 'pets_edit'.tr(namedArgs: {'name': widget.pet!.name})
            : 'pets_new'.tr()),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('common_save'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    if (_imagePath != null && _imagePath!.isNotEmpty)
                      ClipOval(
                        child: Image.file(
                          File(_imagePath!),
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          cacheWidth: 220,
                          cacheHeight: 220,
                          errorBuilder: (_, __, ___) => Container(
                            width: 110,
                            height: 110,
                            decoration: const BoxDecoration(
                              color: AppColors.cream,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                                PetAvatar.emojiFor(_species),
                                style: const TextStyle(fontSize: 44)),
                          ),
                        ),
                      )
                    else
                      Builder(builder: (context) {
                        final art = SpeciesArt.of(_species);
                        final emoji =
                            PetAvatar.emojiFor(_species);
                        return Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.speciesWash(_species.name),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.speciesTint(_species.name)
                                  .withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: art == null
                              ? Text(emoji,
                                  style: const TextStyle(fontSize: 44))
                              : ClipOval(
                                  child: Image.asset(
                                    art,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(emoji,
                                        style: const TextStyle(fontSize: 44)),
                                  ),
                                ),
                        );
                      }),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(AppIcons.camera,
                          size: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _pickPhoto,
                child: Text('form_change_photo'.tr()),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'form_name'.tr(),
                prefixIcon: const Icon(AppIcons.paw),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'form_give_name'.tr()
                  : null,
            ),
            const SizedBox(height: 14),
            _SpeciesSelector(
              value: _species,
              onChanged: (s) => setState(() => _species = s),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickBirthday,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'form_birthday'.tr(),
                  prefixIcon: const Icon(AppIcons.cakeBirthday),
                ),
                child: Text(_birthday == null
                    ? 'form_tap_to_set'.tr()
                    : DateFormat.yMd().format(_birthday!)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _breed,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'form_breed'.tr(),
                prefixIcon: const Icon(AppIcons.grid),
              ),
            ),
            const SizedBox(height: 14),
            _GenderSelector(
              value: _gender,
              onChanged: (g) => setState(() => _gender = g),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weight,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                    ],
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      final w = double.tryParse(t);
                      if (w == null || w <= 0) return 'form_invalid'.tr();
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'form_weight'.tr(),
                      suffixText: 'unit_kg'.tr(),
                      prefixIcon: const Icon(AppIcons.scale),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _microchip,
                    decoration: InputDecoration(
                      labelText: 'form_microchip'.tr(),
                      prefixIcon: const Icon(AppIcons.microchip),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AllergyEditor(
              allergies: _allergies,
              input: _allergyInput,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'form_notes'.tr(),
                alignLabelWithHint: true,
                prefixIcon: const Icon(AppIcons.notes),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GenderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('Male', 'gender_male'.tr(), '♂️'),
      ('Female', 'gender_female'.tr(), '♀️'),
      ('Unknown', 'gender_unknown'.tr(), '❓'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('form_gender'.tr(),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _chip(options[i].$1, options[i].$2,
                  options[i].$3, value == options[i].$1)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _chip(
      String id, String label, String emoji, bool selected) {
    return InkWell(
      onTap: () => onChanged(id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SpeciesSelector extends StatelessWidget {
  final Species value;
  final ValueChanged<Species> onChanged;

  const _SpeciesSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // 3-column grid (not Wrap): equal cells so art + labels line up even
    // when a label wraps to 2 lines (e.g. TR "Muhabbet kuşu").
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.8,
      children: [
        _pill(Species.dog, 'species_dog'.tr(), value == Species.dog,
            () => onChanged(Species.dog)),
        _pill(Species.cat, 'species_cat'.tr(), value == Species.cat,
            () => onChanged(Species.cat)),
        _pill(Species.budgie, 'species_budgie'.tr(),
            value == Species.budgie, () => onChanged(Species.budgie)),
        _pill(Species.parrot, 'species_parrot'.tr(),
            value == Species.parrot, () => onChanged(Species.parrot)),
        _pill(Species.rabbit, 'species_rabbit'.tr(),
            value == Species.rabbit, () => onChanged(Species.rabbit)),
        _pill(Species.fish, 'species_fish'.tr(), value == Species.fish,
            () => onChanged(Species.fish)),
        _pill(Species.other, 'species_other'.tr(),
            value == Species.other, () => onChanged(Species.other)),
      ],
    );
  }

  Widget _pill(
      Species species, String label, bool selected, VoidCallback onTap) {
    final tint = AppColors.speciesTint(species.name);
    final wash = AppColors.speciesWash(species.name);
    final art = SpeciesArt.of(species);
    final emoji = PetAvatar.emojiFor(species);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? tint.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? tint : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big portrait slot: art fills the cell, labels share one baseline.
            SizedBox(
              height: 80,
              child: Center(
                child: art == null
                    ? Text(emoji, style: const TextStyle(fontSize: 40))
                    : Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: wash,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          art,
                          width: 72,
                          height: 72,
                          cacheWidth: 144,
                          cacheHeight: 144,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(emoji,
                              style: const TextStyle(fontSize: 40)),
                        ),
                      ),
              ),
            ),
            // Fixed-height label slot: 1- and 2-line labels (TR "Muhabbet
            // kuşu") occupy the same space, so rows stay aligned.
            SizedBox(
              height: 32,
              child: Center(
                child: Text(label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip-based allergy editor: type → Add (or Enter) → tappable deletable
/// chips. No commas, no parsing, no truncated label.
class _AllergyEditor extends StatelessWidget {
  final List<String> allergies;
  final TextEditingController input;
  final VoidCallback onChanged;

  const _AllergyEditor(
      {required this.allergies, required this.input, required this.onChanged});

  void _add() {
    final v = input.text.trim().replaceAll(',', '');
    if (v.isEmpty) return;
    if (!allergies.any((a) => a.toLowerCase() == v.toLowerCase())) {
      allergies.add(v);
    }
    input.clear();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.triangleWarning,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('form_allergies'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700)),
            ],
          ),
          if (allergies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in allergies)
                  Chip(
                    label: Text(a),
                    deleteIcon: const Icon(AppIcons.cross, size: 16),
                    onDeleted: () {
                      allergies.remove(a);
                      onChanged();
                    },
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.14),
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'form_allergies_hint'.tr(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _add,
                icon: const Icon(AppIcons.plus, size: 18),
                label: Text('common_add'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
