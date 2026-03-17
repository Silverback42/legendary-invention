import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Data for a single slice in the category chart.
class CategoryChartData {
  final int categoryId;
  final String name;
  final Color color;
  final double amount;
  final double percentage;

  const CategoryChartData({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

/// A donut chart showing spending per category.
///
/// Tapping a segment calls [onSegmentTap] with the category id.
class CategoryDonutChart extends StatefulWidget {
  final List<CategoryChartData> data;
  final ValueChanged<int>? onSegmentTap;
  final String Function(double amount) formatAmount;

  const CategoryDonutChart({
    required this.data, required this.formatAmount, super.key,
    this.onSegmentTap,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          // Chart
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });

                    // On tap up, notify parent
                    if (event is FlTapUpEvent &&
                        _touchedIndex >= 0 &&
                        _touchedIndex < widget.data.length) {
                      widget.onSegmentTap
                          ?.call(widget.data[_touchedIndex].categoryId);
                    }
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildSections(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Legend
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < widget.data.length; i++)
                  Builder(builder: (context) {
                    final d = widget.data[i];
                    final isTouched = i == _touchedIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: d.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              d.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight:
                                        isTouched ? FontWeight.w600 : FontWeight.w400,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${d.percentage.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight:
                                      isTouched ? FontWeight.w600 : FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.data.length, (i) {
      final isTouched = i == _touchedIndex;
      final d = widget.data[i];
      return PieChartSectionData(
        color: d.color,
        value: d.amount,
        title: isTouched ? widget.formatAmount(d.amount) : '',
        radius: isTouched ? 56 : 48,
        titleStyle: TextStyle(
          fontSize: isTouched ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    });
  }
}
