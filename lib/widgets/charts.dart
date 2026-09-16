import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// Weight trend line chart for a pet. Plots logged entries only —
/// the profile's current weight is shown as a stat card, never a dot.
class WeightChart extends StatelessWidget {
  final List<WeightEntry> weights;

  const WeightChart({
    super.key,
    required this.weights,
  });

  @override
  Widget build(BuildContext context) {
    final all = weights.reversed.toList(); // oldest -> newest
    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'chart_empty_weight'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }

    double minV = all.first.weight;
    double maxV = all.first.weight;
    for (final w in all) {
      if (w.weight < minV) minV = w.weight;
      if (w.weight > maxV) maxV = w.weight;
    }
    final pad = (maxV - minV) == 0 ? 1.0 : (maxV - minV) * 0.2;
    minV = (minV - pad).floorToDouble();
    maxV = (maxV + pad).ceilToDouble();

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: minV,
          maxY: maxV,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxV - minV) / 4,
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, meta) => Text(
                  v.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: all.length > 1,
                reservedSize: 24,
                getTitlesWidget: (v, meta) {
                  final i = v.round();
                  if (i < 0 || i >= all.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d MMM').format(all[i].date),
                      style:
                          const TextStyle(fontSize: 9, color: AppColors.muted),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < all.length; i++)
                  FlSpot(i.toDouble(), all[i].weight),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Daily activity bar chart: number of care log entries per day (last 14 days).
class ActivityChart extends StatelessWidget {
  final List<CareLogEntry> logs;

  const ActivityChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final perDay = <int, int>{};
    for (var d = 0; d < 14; d++) {
      final day = base.subtract(Duration(days: 13 - d));
      final count = logs.where((l) {
        final lt = l.dateTime;
        return lt.year == day.year &&
            lt.month == day.month &&
            lt.day == day.day;
      }).length;
      perDay[d] = count;
    }
    final maxCount = perDay.values.fold(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount < 1 ? 1 : maxCount.toDouble(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: maxCount > 0,
                reservedSize: 24,
                getTitlesWidget: (v, meta) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 9, color: AppColors.muted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= 14) return const SizedBox.shrink();
                  if (i % 2 != 0) return const SizedBox.shrink();
                  final day = base.subtract(Duration(days: 13 - i));
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('d/M').format(day),
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.muted),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var d = 0; d < 14; d++)
              BarChartGroupData(
                x: d,
                barRods: [
                  BarChartRodData(
                    toY: perDay[d]!.toDouble(),
                    width: 12,
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}