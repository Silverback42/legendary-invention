import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/category_icon.dart';
import '../../../shared/widgets/category_donut_chart.dart';
import '../../../shared/widgets/category_bar_chart.dart';
import '../../../shared/widgets/month_selector.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// History screen – Phase 1b.
///
/// Month-by-month navigation (free tier: 3 months back).
/// Shows spending breakdown + month-over-month comparison.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late int _year;
  late int _month;
  bool _showBarChart = false;
  Future<_HistoryData>? _historyFuture;

  // Free tier: 3 months back
  static const int _freeMonthLimit = 3;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  /// How many months back from the current month this selection is.
  int get _monthsBack {
    final now = DateTime.now();
    return (now.year - _year) * 12 + (now.month - _month);
  }

  void _changeMonth(int delta) {
    var m = _month + delta;
    var y = _year;
    if (m > 12) {
      m = 1;
      y++;
    } else if (m < 1) {
      m = 12;
      y--;
    }

    // Don't go into the future
    final now = DateTime.now();
    if (y > now.year || (y == now.year && m > now.month)) return;

    // Free tier limit
    final newMonthsBack = (now.year - y) * 12 + (now.month - m);
    if (newMonthsBack > _freeMonthLimit) return;

    setState(() {
      _month = m;
      _year = y;
      _historyFuture = null; // force reload on next build
    });
  }

  /// Previous month's year/month for comparison.
  (int, int) get _prevMonth {
    var m = _month - 1;
    var y = _year;
    if (m < 1) {
      m = 12;
      y--;
    }
    return (y, m);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);
    final fmt = NumberFormat.currency(
      locale: settings.fullLocale,
      symbol: settings.currencySymbol,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(
            icon: Icon(_showBarChart ? Icons.donut_large : Icons.bar_chart),
            tooltip: l10n.chartToggleTooltip,
            onPressed: () => setState(() => _showBarChart = !_showBarChart),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          MonthSelector(
            year: _year,
            month: _month,
            locale: settings.fullLocale,
            l10n: l10n,
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
            canGoBack: _monthsBack < _freeMonthLimit,
            canGoForward: _monthsBack > 0,
          ),

          // Limit hint
          if (_monthsBack >= _freeMonthLimit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.freeMonthsLimit,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          // Content
          Expanded(
            child: FutureBuilder<_HistoryData>(
              future: _historyFuture ??= _loadData(db),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .error,
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.genericError),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() {
                            _historyFuture = null;
                          }),
                          child: Text(l10n.done), // "retry" — reuses existing string
                        ),
                      ],
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const HistorySkeleton();
                }

                final data = snap.data!;
                if (data.spending.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.noDataForMonth),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total + comparison
                      _TotalCard(
                        total: data.totalCurrent,
                        totalPrev: data.totalPrev,
                        fmt: fmt,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 16),

                      // Chart
                      Text(
                        l10n.spendingByCategory,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_showBarChart)
                        CategoryBarChart(
                          data: data.chartData,
                          formatAmount: (a) => fmt.format(a),
                        )
                      else
                        CategoryDonutChart(
                          data: data.chartData,
                          formatAmount: (a) => fmt.format(a),
                        ),

                      const SizedBox(height: 16),

                      // Category breakdown list
                      ...data.chartData.map((d) => _CategoryRow(
                            data: d,
                            fmt: fmt,
                            l10n: l10n,
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<_HistoryData> _loadData(AppDatabase db) async {
    final spending = await db.getSpendingByCategory(_year, _month);
    final categories = await db.getAllCategories();
    final totalCurrent = await db.getTotalSpendingForMonth(_year, _month);

    final (py, pm) = _prevMonth;
    final totalPrev = await db.getTotalSpendingForMonth(py, pm);

    final chartData = <CategoryChartData>[];
    for (final cat in categories) {
      final amount = spending[cat.id] ?? 0.0;
      if (amount <= 0) continue;
      chartData.add(CategoryChartData(
        categoryId: cat.id,
        name: cat.name,
        color: Color(cat.colorValue),
        amount: amount,
        percentage: totalCurrent > 0 ? (amount / totalCurrent) * 100 : 0,
      ));
    }
    // Sort by amount descending
    chartData.sort((a, b) => b.amount.compareTo(a.amount));

    return _HistoryData(
      spending: spending,
      chartData: chartData,
      totalCurrent: totalCurrent,
      totalPrev: totalPrev,
    );
  }
}

class _HistoryData {
  final Map<int, double> spending;
  final List<CategoryChartData> chartData;
  final double totalCurrent;
  final double totalPrev;

  const _HistoryData({
    required this.spending,
    required this.chartData,
    required this.totalCurrent,
    required this.totalPrev,
  });
}

// ---------------------------------------------------------------------------
// Total spending card with month-over-month comparison
// ---------------------------------------------------------------------------

class _TotalCard extends StatelessWidget {
  final double total;
  final double totalPrev;
  final NumberFormat fmt;
  final AppLocalizations l10n;

  const _TotalCard({
    required this.total,
    required this.totalPrev,
    required this.fmt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrev = totalPrev > 0;
    final diff = hasPrev ? ((total - totalPrev) / totalPrev * 100) : 0.0;
    final isMore = diff > 0;
    final isLess = diff < 0;

    final IconData trendIcon;
    final Color trendColor;
    final String trendLabel;
    if (isMore) {
      trendIcon = Icons.trending_up;
      trendColor = AppTheme.budgetOver;
      trendLabel = l10n.moreSpending;
    } else if (isLess) {
      trendIcon = Icons.trending_down;
      trendColor = AppTheme.budgetOk;
      trendLabel = l10n.lessSpending;
    } else {
      trendIcon = Icons.trending_flat;
      trendColor = AppTheme.budgetNeutral;
      trendLabel = l10n.sameSpending;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.totalSpending,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              fmt.format(total),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (hasPrev) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    trendIcon,
                    size: 18,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.comparedToLastMonth(
                      trendLabel,
                      diff.abs().toStringAsFixed(0),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category breakdown row
// ---------------------------------------------------------------------------

class _CategoryRow extends StatelessWidget {
  final CategoryChartData data;
  final NumberFormat fmt;
  final AppLocalizations l10n;

  const _CategoryRow({
    required this.data,
    required this.fmt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              data.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            fmt.format(data.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${data.percentage.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
