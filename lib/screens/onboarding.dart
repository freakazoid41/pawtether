import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../utils/i18n_helpers.dart';
import '../widgets/common.dart';
import 'add_pet.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              MascotHeader(
                emoji: '🐾',
                tint: AppColors.primary,
                title: 'onboarding_title'.tr(),
                subtitle: 'onboarding_subtitle'.tr(),
              ),
              const SizedBox(height: 12),
              const PawDivider(count: 7),
              const SizedBox(height: 12),
              // Species preview — translated labels, zero image cost.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  SpeciesPill(
                      speciesName: 'dog',
                      emoji: '🐶',
                      label: speciesLabelTr(Species.dog)),
                  SpeciesPill(
                      speciesName: 'cat',
                      emoji: '🐱',
                      label: speciesLabelTr(Species.cat)),
                  SpeciesPill(
                      speciesName: 'budgie',
                      emoji: '🐦',
                      label: speciesLabelTr(Species.budgie)),
                  SpeciesPill(
                      speciesName: 'parrot',
                      emoji: '🦜',
                      label: speciesLabelTr(Species.parrot)),
                  SpeciesPill(
                      speciesName: 'rabbit',
                      emoji: '🐰',
                      label: speciesLabelTr(Species.rabbit)),
                  SpeciesPill(
                      speciesName: 'fish',
                      emoji: '🐟',
                      label: speciesLabelTr(Species.fish)),
                ],
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final loc in const [
                    ('en', 'English'),
                    ('tr', 'Türkçe'),
                    ('ru', 'Русский'),
                    ('hi', 'हिन्दी'),
                  ])
                    _LangPill(
                      label: loc.$2,
                      selected:
                          context.locale.languageCode == loc.$1,
                      onTap: () async =>
                          await context.setLocale(Locale(loc.$1)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    final added = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                          builder: (_) => const AddPetScreen()),
                    );
                    if (added == true &&
                        context.mounted &&
                        context.read<AppProvider>().hasPets) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const OnboardingDone()),
                      );
                    }
                  },
                  child: Text('onboarding_add_first'.tr(),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeShell()),
                ),
                child: Text('onboarding_skip'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Language pill with explicit colors — never relies on ChoiceChip theme
/// defaults (those washed out to white-on-cream in light mode).
class _LangPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : cs.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primaryDark
                : cs.outlineVariant.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(AppIcons.check, size: 16, color: Colors.white),
              ),
            Text(label,
                style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                    color: selected
                        ? Colors.white
                        : cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

class OnboardingDone extends StatelessWidget {
  const OnboardingDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              MascotHeader(
                emoji: '🎉',
                tint: AppColors.secondary,
                title: 'onboarding_done_title'.tr(),
                subtitle: 'onboarding_done_subtitle'.tr(),
              ),
              const SizedBox(height: 12),
              const PawDivider(count: 5),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                  ),
                  child: Text('onboarding_start'.tr(),
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
