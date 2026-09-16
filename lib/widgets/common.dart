import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// Shared destructive-action guard: confirm dialog used by every delete
/// button (health rows, logs, routines, documents).
Future<bool> confirmDelete(BuildContext context, {String? title}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? 'common_delete_title'.tr()),
      content: Text('common_delete_sub'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('common_cancel'.tr()),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(context, true),
          child: Text('common_delete'.tr()),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Circular pet photo with a fallback emoji avatar + cozy species ring.
class PetAvatar extends StatelessWidget {
  final Pet? pet;
  final double radius;

  const PetAvatar({super.key, this.pet, this.radius = 28});

  static String emojiFor(Species s) => switch (s) {
        Species.dog => '🐶',
        Species.cat => '🐱',
        Species.budgie => '🐦',
        Species.parrot => '🦜',
        Species.rabbit => '🐰',
        Species.fish => '🐟',
        Species.other => '🐾',
      };

  static Color ringFor(Species s) => switch (s) {
        Species.dog => AppColors.dog,
        Species.cat => AppColors.cat,
        Species.budgie => AppColors.budgie,
        Species.parrot => AppColors.parrot,
        Species.rabbit => AppColors.rabbit,
        Species.fish => AppColors.fish,
        Species.other => AppColors.other,
      };

  @override
  Widget build(BuildContext context) {
    final name = pet?.name ?? '?';
    final img = pet?.imagePath;
    final species = pet?.species ?? Species.other;
    final emoji = emojiFor(species);
    // No sync file check here (existsSync in build janks lists) — a missing
    // file falls through to the emoji avatar via errorBuilder.
    final Widget inner = (img != null && img.isNotEmpty)
        ? ClipOval(
            child: Image.file(
              File(img),
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              cacheWidth: (radius * 4).toInt(),
              cacheHeight: (radius * 4).toInt(),
              errorBuilder: (_, __, ___) => _emojiAvatar(emoji, radius),
            ),
          )
        : _emojiAvatar(emoji, radius);
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [ringFor(species), ringFor(species).withValues(alpha: 0.35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Semantics(label: name, child: inner),
    );
  }

  Widget _emojiAvatar(String emoji, double r) {
    return Container(
      width: r * 2,
      height: r * 2,
      decoration: const BoxDecoration(
        color: AppColors.cream,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: r * 1.1)),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          const Text('🐾', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.pawTint,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25), width: 2),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, height: 1.4)),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Big cozy mascot header: species emoji in a soft blob + title + subtitle.
/// Use on top of detail / care screens for the animal-friendly feel.
/// Zero image assets — emoji only, so no screenshot/image budget cost.
class MascotHeader extends StatelessWidget {
  final String emoji;
  final Color tint;
  final String title;
  final String? subtitle;
  final String? speciesName;

  const MascotHeader({
    super.key,
    required this.emoji,
    required this.tint,
    required this.title,
    this.subtitle,
    this.speciesName,
  });

  @override
  Widget build(BuildContext context) {
    final wash = speciesName == null
        ? AppColors.cream
        : AppColors.speciesWash(speciesName!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tint.withValues(alpha: 0.35), wash],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: tint.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: tint.withValues(alpha: 0.45), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 44)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65),
                              height: 1.35)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (speciesName != null) ...[
            const SizedBox(height: 12),
            SpeciesPill(speciesName: speciesName!, emoji: emoji),
          ],
        ],
      ),
    );
  }
}

/// Little species badge: tinted pill with emoji + label.
/// Cheap, cozy, reused on home switcher + care guide + detail header.
class SpeciesPill extends StatelessWidget {
  final String speciesName;
  final String emoji;
  final String? label;

  const SpeciesPill(
      {super.key,
      required this.speciesName,
      required this.emoji,
      this.label});

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.speciesTint(speciesName);
    final wash = AppColors.speciesWash(speciesName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: wash,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$emoji ${label ?? speciesName.toUpperCase()}',
        style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 12, color: tint),
      ),
    );
  }
}

/// Zero-cost paw divider — emoji only, no assets, no screenshots needed.
class PawDivider extends StatelessWidget {
  final int count;
  const PawDivider({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
            child: Opacity(
              opacity: 0.35 + (i % 3) * 0.15,
              child: Text('🐾',
                  style: TextStyle(fontSize: 14 + (i % 3) * 2.0)),
            ),
          ),
      ],
    );
  }
}

/// Soft banner for warnings/tips with species or semantic tint.
class CozyBanner extends StatelessWidget {
  final String emoji;
  final String text;
  final Color tint;
  final Color? wash;

  const CozyBanner({
    super.key,
    required this.emoji,
    required this.text,
    required this.tint,
    this.wash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (wash ?? tint).withValues(alpha: wash == null ? 0.14 : 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tint.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

