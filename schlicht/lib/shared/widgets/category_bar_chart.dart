import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'category_donut_chart.dart'; // reuse CategoryChartData

/// Vertical bar chart showing spending per category.
class CategoryBarChart extends StatelessWidget {
  final List<CategoryChartData> data;
  final ValueChanged<int>? onBarTap;
  final String Function(double amount) formatAmount;

  const CategoryBarChart({
    required this.data, required this.formatAmount, super.key,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxAmount =
        data.fold<double>(0, (m, d) => d.amount > m ? d.amount : m);
    final safeMaxY = maxAmount > 0 ? maxAmount * 1.15 : 1.0;

    return SizedBox(
      height: data.length * 44.0 + 16,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: safeMaxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[group.x];
                return BarTooltipItem(
                  '${d.name}\n${formatAmount(d.amount)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
            touchCallback: (event, barTouchResponse) {
              if (event is FlTapUpEvent &&
                  barTouchResponse != null &&
                  barTouchResponse.spot != null) {
                final index = barTouchResponse.spot!.touchedBarGroupIndex;
                if (index >= 0 && index < data.length) {
                  onBarTap?.call(data[index].categoryId);
                }
              }
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final label = data[index].name.length > 6
                      ? '${data[index].name.substring(0, 5)}…'
                      : data[index].name;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(data.length, (i) {
            final d = data[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: d.amount,
                  color: d.color,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
