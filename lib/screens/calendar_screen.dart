import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../utils/i18n_helpers.dart';
import '../widgets/common.dart';
import 'add_reminder.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final all = app.remindersForAll().where((r) => r.enabled).toList();
    final dots = _dotsForMonth(all, _month);
    final dayReminders = all.where((r) => r.occursOn(_selected)).toList()
      ..sort((a, b) {
        final at = a.date.hour * 60 + a.date.minute;
        final bt = b.date.hour * 60 + b.date.minute;
        return at.compareTo(bt);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('cal_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.alarmPlus),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AddReminderScreen())),
            tooltip: 'common_reminder'.tr(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(AppIcons.angleLeft),
                        onPressed: () => _shift(-1),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('MMMM yyyy').format(_month),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.angleRight),
                        onPressed: () => _shift(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const _WeekHeader(),
                  const SizedBox(height: 4),
                  _MonthGrid(
                    month: _month,
                    selected: _selected,
                    dots: dots,
                    onTap: (d) => setState(() => _selected = d),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (dayReminders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                emoji: '📭',
                title: 'home_all_caught_up'.tr(),
                subtitle: 'empty_reminders'.tr(),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
              child: Text(
                DateFormat('EEEE, d MMMM').format(_selected),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Card(
              child: Column(
                children: dayReminders
                    .map((r) => _ReminderRow(
                          reminder: r,
                          color: _typeColor(r.type),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Repeat-aware dot counts for every day of [month].
  Map<int, int> _dotsForMonth(List<Reminder> all, DateTime month) {
    final dots = <int, int>{};
    final days = DateTime(month.year, month.month + 1, 0).day;
    for (var d = 1; d <= days; d++) {
      final day = DateTime(month.year, month.month, d);
      var n = 0;
      for (final r in all) {
        if (r.occursOn(day)) n++;
      }
      if (n > 0) dots[d] = n;
    }
    return dots;
  }

  Color _typeColor(ReminderType t) {
    switch (t) {
      case ReminderType.medication:
        return const Color(0xFF7C4DFF);
      case ReminderType.vaccine:
        return AppColors.danger;
      case ReminderType.feeding:
        return AppColors.primary;
      case ReminderType.walking:
        return const Color(0xFF2196F3);
      case ReminderType.grooming:
        return const Color(0xFF00ACC1);
      case ReminderType.vet:
        return const Color(0xFF8BC34A);
      case ReminderType.other:
        return const Color(0xFF9E9E9E);
    }
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    // Monday-first to match the grid; narrow weekday glyphs in app locale.
    final monday = DateTime(2024, 1, 1); // a Monday
    final days = [
      for (var i = 0; i < 7; i++)
        DateFormat('EEEEE').format(monday.add(Duration(days: i))),
    ];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(d,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
                ),
              ))
          .toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final Map<int, int> dots;
  final ValueChanged<DateTime> onTap;

  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.dots,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final leadingBlanks = firstDay.weekday - 1; // Monday=1 -> offset
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final today = DateTime.now();
    final isCurrentMonth = today.year == month.year && today.month == month.month;

    final cells = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final isToday = isCurrentMonth && today.day == d;
      final isSelected = date.year == selected.year &&
          date.month == selected.month &&
          date.day == selected.day;
      final dotCount = dots[d] ?? 0;
      cells.add(_DayCell(
        day: d,
        isToday: isToday,
        isSelected: isSelected,
        dotCount: dotCount,
        onTap: () => onTap(date),
      ));
    }

    return Column(
      children: [
        for (var row = 0; row * 7 < cells.length; row++)
          Row(
            children: cells
                .skip(row * 7)
                .take(7)
                .map((c) => Expanded(child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: c,
                )))
                .toList(),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final int dotCount;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.dotCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight:
                    isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : ink,
              ),
            ),
            if (dotCount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  dotCount > 3 ? 3 : dotCount,
                  (i) => Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final Reminder reminder;
  final Color color;

  const _ReminderRow({required this.reminder, required this.color});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    Pet? pet;
    for (final p in app.pets) {
      if (p.id == reminder.petId) pet = p;
    }
    return ListTile(
      leading: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(seedTr(reminder.title),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${pet?.name ?? 'cal_unknown_pet'.tr()} · ${DateFormat.Hm().format(reminder.date)}',
      ),
      trailing: IconButton(
        icon: const Icon(AppIcons.checkCircle,
            color: AppColors.secondary, size: 24),
        tooltip: 'common_done'.tr(),
        onPressed: pet == null
            ? null
            : () =>
                context.read<AppProvider>().completeReminder(pet!, reminder),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddReminderScreen(reminder: reminder))),
    );
  }
}