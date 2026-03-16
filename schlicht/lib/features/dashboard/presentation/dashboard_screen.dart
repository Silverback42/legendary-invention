import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/category_icon.dart';
import '../../../shared/widgets/category_donut_chart.dart';
import '../../../shared/widgets/category_bar_chart.dart';

/// Dashboard – Phase 1b Bento-Grid version.
///
/// Cards:
/// 1. Spending overview + total budget progress
/// 2. Category donut/bar chart (switchable)
/// 3. Budget status per category (progress bars)
/// 4. Top category
/// 5. Month-over-month comparison
/// 6. Recent transactions
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showBarChart = false;

  @override
  Widget build(BuildContext context, ) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final fmt = NumberFormat.currency(
      locale: settings.fullLocale,
      symbol: settings.currencySymbol,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schlicht'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.history,
            onPressed: () => context.go(AppRoutes.history),
          ),
        ],
      ),
      body: StreamBuilder<_DashboardData>(
        stream: _watchDashboardData(db, year, month),
        builder: (context, snap) {
          final data = snap.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month label
                Text(
                  DateFormat.yMMMM(settings.fullLocale).format(now),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),

                // ── Bento Grid ──
                // Row 1: Spending + Budget
                _SpendingBentoCard(
                  data: data,
                  fmt: fmt,
                  l10n: l10n,
                ),
                const SizedBox(height: 12),

                // Row 2: Chart card
                if (data != null && data.chartData.isNotEmpty) ...[
                  _ChartCard(
                    chartData: data.chartData,
                    showBar: _showBarChart,
                    onToggle: () =>
                        setState(() => _showBarChart = !_showBarChart),
                    fmt: fmt,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                ],

                // Row 3: Two small cards side by side
                if (data != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top category
                      Expanded(
                        child: _TopCategoryCard(
                          chartData: data.chartData,
                          l10n: l10n,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Comparison
                      Expanded(
                        child: _ComparisonCard(
                          db: db,
                          currentTotal: data.totalSpending,
                          year: year,
                          month: month,
                          fmt: fmt,
                          l10n: l10n,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                // Row 4: Per-category budget progress
                if (data != null && data.budgets.isNotEmpty)
                  _BudgetProgressCard(
                    data: data,
                    fmt: fmt,
                    l10n: l10n,
                  ),
                if (data != null && data.budgets.isNotEmpty)
                  const SizedBox(height: 12),

                // Row 5: Recent transactions
                _RecentTransactionsCard(
                  db: db,
                  year: year,
                  month: month,
                  l10n: l10n,
                  locale: settings.fullLocale,
                  currencySymbol: settings.currencySymbol,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Combines multiple DB streams into a single dashboard data stream.
  Stream<_DashboardData> _watchDashboardData(
    AppDatabase db,
    int year,
    int month,
  ) {
    // We combine the 3 streams manually via nested StreamBuilders below,
    // but for cleaner architecture, use a FutureBuilder wrapper.
    // For now, return a stream from transactions that triggers rebuilds.
    return db.watchTransactionsForMonth(year, month).asyncMap((txs) async {
      final categories = await db.getAllCategories();
      final spending = await db.getSpendingByCategory(year, month);
      final budgets = await db.watchBudgetsForMonth(year, month).first;

      final totalSpending = txs.fold<double>(0, (s, t) => s + t.amount);
      final totalBudget = budgets.fold<double>(0, (s, b) => s + b.amount);
      final totalAll =
          spending.values.fold<double>(0, (s, v) => s + v);

      final chartData = <CategoryChartData>[];
      for (final cat in categories) {
        final amount = spending[cat.id] ?? 0.0;
        if (amount <= 0) continue;
        chartData.add(CategoryChartData(
          categoryId: cat.id,
          name: cat.name,
          color: Color(cat.colorValue),
          amount: amount,
          percentage: totalAll > 0 ? (amount / totalAll) * 100 : 0,
        ));
      }
      chartData.sort((a, b) => b.amount.compareTo(a.amount));

      final budgetMap = {for (final b in budgets) b.categoryId: b};

      return _DashboardData(
        transactions: txs,
        categories: categories,
        spending: spending,
        budgets: budgets,
        budgetMap: budgetMap,
        chartData: chartData,
        totalSpending: totalSpending,
        totalBudget: totalBudget,
      );
    });
  }
}

class _DashboardData {
  final List<Transaction> transactions;
  final List<Category> categories;
  final Map<int, double> spending;
  final List<Budget> budgets;
  final Map<int, Budget> budgetMap;
  final List<CategoryChartData> chartData;
  final double totalSpending;
  final double totalBudget;

  const _DashboardData({
    required this.transactions,
    required this.categories,
    required this.spending,
    required this.budgets,
    required this.budgetMap,
    required this.chartData,
    required this.totalSpending,
    required this.totalBudget,
  });
}

// ==========================================================================
// Bento Cards
// ==========================================================================

// ---------------------------------------------------------------------------
// 1. Spending + budget summary
// ---------------------------------------------------------------------------

class _SpendingBentoCard extends StatelessWidget {
  final _DashboardData? data;
  final NumberFormat fmt;
  final AppLocalizations l10n;

  const _SpendingBentoCard({
    required this.data,
    required this.fmt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpending = data?.totalSpending ?? 0.0;
    final totalBudget = data?.totalBudget ?? 0.0;
    final hasBudget = totalBudget > 0;
    final remaining = totalBudget - totalSpending;
    final ratio = hasBudget ? totalSpending / totalBudget : 0.0;

    Color statusColor;
    if (!hasBudget) {
      statusColor = Theme.of(context).colorScheme.onSurface;
    } else if (ratio >= 1.0) {
      statusColor = AppTheme.budgetOver;
    } else if (ratio >= 0.8) {
      statusColor = AppTheme.budgetWarning;
    } else {
      statusColor = AppTheme.budgetOk;
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
              fmt.format(totalSpending),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (hasBudget) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Theme.of(context).dividerColor,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                remaining >= 0
                    ? '${l10n.budgetRemaining}: ${fmt.format(remaining)}'
                    : '${l10n.budgetOver}: ${fmt.format(remaining.abs())}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: statusColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Chart card (donut / bar switchable)
// ---------------------------------------------------------------------------

class _ChartCard extends StatelessWidget {
  final List<CategoryChartData> chartData;
  final bool showBar;
  final VoidCallback onToggle;
  final NumberFormat fmt;
  final AppLocalizations l10n;

  const _ChartCard({
    required this.chartData,
    required this.showBar,
    required this.onToggle,
    required this.fmt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.spendingByCategory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: Icon(
                    showBar ? Icons.donut_large : Icons.bar_chart,
                    size: 20,
                  ),
                  tooltip: l10n.chartToggleTooltip,
                  onPressed: onToggle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (showBar)
              CategoryBarChart(
                data: chartData,
                formatAmount: (a) => fmt.format(a),
              )
            else
              CategoryDonutChart(
                data: chartData,
                formatAmount: (a) => fmt.format(a),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Top category mini card
// ---------------------------------------------------------------------------

class _TopCategoryCard extends StatelessWidget {
  final List<CategoryChartData> chartData;
  final AppLocalizations l10n;

  const _TopCategoryCard({
    required this.chartData,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dashboardTopCategory,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text('—', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    final top = chartData.first; // already sorted descending
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dashboardTopCategory,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: top.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    top.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${top.percentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: top.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Comparison mini card (vs last month)
// ---------------------------------------------------------------------------

class _ComparisonCard extends StatefulWidget {
  final AppDatabase db;
  final double currentTotal;
  final int year;
  final int month;
  final NumberFormat fmt;
  final AppLocalizations l10n;

  const _ComparisonCard({
    required this.db,
    required this.currentTotal,
    required this.year,
    required this.month,
    required this.fmt,
    required this.l10n,
  });

  @override
  State<_ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends State<_ComparisonCard> {
  double? _prevTotal;

  @override
  void initState() {
    super.initState();
    _loadPrev();
  }

  @override
  void didUpdateWidget(_ComparisonCard old) {
    super.didUpdateWidget(old);
    if (old.currentTotal != widget.currentTotal) _loadPrev();
  }

  Future<void> _loadPrev() async {
    var pm = widget.month - 1;
    var py = widget.year;
    if (pm < 1) {
      pm = 12;
      py--;
    }
    final total = await widget.db.getTotalSpendingForMonth(py, pm);
    if (mounted) setState(() => _prevTotal = total);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    if (_prevTotal == null || _prevTotal == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dashboardComparison,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                l10n.dashboardNoComparison,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    final diff =
        ((widget.currentTotal - _prevTotal!) / _prevTotal! * 100);
    final isMore = diff > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dashboardComparison,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isMore ? Icons.trending_up : Icons.trending_down,
                  color: isMore ? AppTheme.budgetOver : AppTheme.budgetOk,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${diff.abs().toStringAsFixed(0)}%',
                    style:
                        Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isMore
                                  ? AppTheme.budgetOver
                                  : AppTheme.budgetOk,
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isMore ? l10n.moreSpending : l10n.lessSpending,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Per-category budget progress card
// ---------------------------------------------------------------------------

class _BudgetProgressCard extends StatelessWidget {
  final _DashboardData data;
  final NumberFormat fmt;
  final AppLocalizations l10n;

  const _BudgetProgressCard({
    required this.data,
    required this.fmt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Only categories that have a budget set
    final categoriesWithBudget = data.categories
        .where((c) =>
            data.budgetMap.containsKey(c.id) &&
            data.budgetMap[c.id]!.amount > 0)
        .toList();

    if (categoriesWithBudget.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardBudgetCard,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...categoriesWithBudget.map((cat) {
              final budget = data.budgetMap[cat.id]!;
              final spent = data.spending[cat.id] ?? 0.0;
              final ratio = spent / budget.amount;

              Color statusColor;
              String? hint;
              if (ratio >= 1.0) {
                statusColor = AppTheme.budgetOver;
                hint = l10n.budgetOverHint;
              } else if (ratio >= 0.8) {
                statusColor = AppTheme.budgetWarning;
                hint = l10n.budgetAlmostReachedHint;
              } else {
                statusColor = AppTheme.budgetOk;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          categoryIconData(cat.icon),
                          color: Color(cat.colorValue),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          l10n.budgetProgress(
                            fmt.format(spent),
                            fmt.format(budget.amount),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: Theme.of(context).dividerColor,
                        color: statusColor,
                      ),
                    ),
                    if (hint != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Recent transactions
// ---------------------------------------------------------------------------

class _RecentTransactionsCard extends StatelessWidget {
  final AppDatabase db;
  final int year;
  final int month;
  final AppLocalizations l10n;
  final String locale;
  final String currencySymbol;

  const _RecentTransactionsCard({
    required this.db,
    required this.year,
    required this.month,
    required this.l10n,
    required this.locale,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentTransactions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.transactions),
              child: Text(l10n.navTransactions),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Transaction>>(
          stream: db.watchTransactionsForMonth(year, month),
          builder: (context, txSnap) {
            final transactions = txSnap.data ?? [];
            if (transactions.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noTransactionsYet,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.noTransactionsSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final sorted = List<Transaction>.from(transactions)
              ..sort((a, b) => b.date.compareTo(a.date));
            final recent = sorted.take(5).toList();

            return StreamBuilder<List<Category>>(
              stream: db.watchAllCategories(),
              builder: (context, catSnap) {
                final categories = catSnap.data ?? [];

                return Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < recent.length; i++) ...[
                        if (i > 0) const Divider(height: 1, indent: 56),
                        _RecentTile(
                          transaction: recent[i],
                          categories: categories,
                          locale: locale,
                          currencySymbol: currencySymbol,
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _RecentTile extends StatelessWidget {
  final Transaction transaction;
  final List<Category> categories;
  final String locale;
  final String currencySymbol;

  const _RecentTile({
    required this.transaction,
    required this.categories,
    required this.locale,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final category =
        categories.where((c) => c.id == transaction.categoryId).firstOrNull;
    final color =
        category != null ? Color(category.colorValue) : Colors.grey;

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          category != null
              ? categoryIconData(category.icon)
              : Icons.circle_outlined,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        category?.name ?? '—',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: transaction.note != null && transaction.note!.isNotEmpty
          ? Text(
              transaction.note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: Text(
        NumberFormat.currency(locale: locale, symbol: currencySymbol)
            .format(transaction.amount),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
