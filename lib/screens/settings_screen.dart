import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../utils/i18n_helpers.dart';
import '../widgets/common.dart';
import 'add_pet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmRemove(BuildContext context, Pet pet) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('pets_remove_confirm'
                .tr(namedArgs: {'name': pet.name})),
            content: Text('pets_delete_confirm'
                .tr(namedArgs: {'name': pet.name})),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('common_cancel'.tr()),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger),
                onPressed: () => Navigator.pop(context, true),
                child: Text('common_delete'.tr()),
              ),
            ],
          ),
        ) ??
        false;
    if (ok && context.mounted) {
      context.read<AppProvider>().deletePet(pet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('nav_more'.tr())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SectionHeader('pets_title'.tr()),
          if (app.pets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('pets_empty'.tr(),
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5))),
            )
          else
            ...app.pets.map((pet) {
              final tint = AppColors.speciesTint(pet.species.name);
              final wash = AppColors.speciesWash(pet.species.name);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tint.withValues(alpha: 0.22),
                        wash.withValues(alpha: 0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: tint.withValues(alpha: 0.45)),
                    boxShadow: [
                      BoxShadow(
                        color: tint.withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      PetAvatar(pet: pet, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pet.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17)),
                            const SizedBox(height: 5),
                            SpeciesPill(
                              speciesName: pet.species.name,
                              emoji: pet.speciesEmoji,
                              label: speciesLabelTr(pet.species),
                            ),
                            const SizedBox(height: 4),
                            Text(petAgeTr(pet),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface
                                        .withValues(alpha: 0.55))),
                          ],
                        ),
                      ),
                      _CircleBtn(
                        icon: AppIcons.trash,
                        tint: AppColors.danger,
                        tooltip:
                            '${'common_delete'.tr()} ${pet.name}',
                        onTap: () =>
                            _confirmRemove(context, pet),
                      ),
                      const SizedBox(width: 4),
                      _CircleBtn(
                        icon: AppIcons.pencil,
                        tint: tint,
                        tooltip: 'tooltip_edit'.tr(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddPetScreen(pet: pet),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AddPetScreen())),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(AppIcons.plus,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text('pets_add_another'.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primaryDark)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader('settings_title'.tr()),
          _PrefTile(
            icon: AppIcons.language,
            tint: AppColors.primary,
            wash: AppColors.pawTint,
            title: 'settings_language'.tr(),
            trailing: const _LanguageDropdown(),
          ),
          const SizedBox(height: 10),
          _PrefTile(
            icon: AppIcons.bell,
            tint: AppColors.secondary,
            wash: AppColors.meadow,
            title: 'settings_notifications'.tr(),
            trailing: Switch(
              value: app.notificationsEnabled,
              onChanged: (v) => context
                  .read<AppProvider>()
                  .setNotificationsEnabled(v),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.20),
                  AppColors.cream,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐾',
                      style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('app_title'.tr(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 17)),
                      const SizedBox(height: 2),
                      Text('settings_version'.tr(),
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small white circular icon button used on the pet banners.
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleBtn(
      {required this.icon,
      required this.tint,
      required this.tooltip,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border:
                Border.all(color: tint.withValues(alpha: 0.4)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 19, color: tint),
        ),
      ),
    );
  }
}

/// Cozy preference tile: tinted icon medallion + bold title + trailing.
class _PrefTile extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color wash;
  final String title;
  final Widget trailing;

  const _PrefTile(
      {required this.icon,
      required this.tint,
      required this.wash,
      required this.title,
      required this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: wash,
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: tint.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Language picker: current label + chevron opens a cozy bottom sheet.
/// (A raw DropdownButton renders white-on-white menu text — never again.)
class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown();

  static const _labels = {
    'en': 'English',
    'tr': 'Türkçe',
    'ru': 'Русский',
    'hi': 'हिन्दी',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final code = context.locale.languageCode;
    final current = _labels.containsKey(code) ? code : 'en';
    return InkWell(
      onTap: () => _pick(context, current),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_labels[current]!,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: cs.onSurface)),
            const SizedBox(width: 4),
            Icon(Icons.expand_more,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, String current) async {
    final cs = Theme.of(context).colorScheme;
    final sel = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Text('settings_language'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 8),
              for (final e in _labels.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () => Navigator.pop(sheet, e.key),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: e.key == current
                            ? AppColors.primary
                                .withValues(alpha: 0.14)
                            : cs.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: e.key == current
                              ? AppColors.primary
                              : cs.outlineVariant
                                  .withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(e.value,
                                style: TextStyle(
                                    fontWeight: e.key == current
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 15,
                                    color: e.key == current
                                        ? AppColors.primaryDark
                                        : cs.onSurface)),
                          ),
                          if (e.key == current)
                            const Icon(AppIcons.check,
                                size: 20,
                                color: AppColors.primaryDark),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (sel != null && sel != current && context.mounted) {
      await context.setLocale(Locale(sel));
    }
  }
}