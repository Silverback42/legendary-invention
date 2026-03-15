import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/datetime_extensions.dart';
import '../../../shared/utils/category_name.dart';
import '../../../shared/widgets/category_icon.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final txAsync = ref.watch(transactionsForMonthProvider);
    final budgetsAsync = ref.watch(budgetsForMonthProvider);
    final totalSpending = ref.watch(totalSpendingProvider);
    final cats = ref.watch(allCategoriesStreamProvider).valueOrNull ?? [];
    final catMap = {for (final c in cats) c.id: c};
    final currency = ref.watch(settingsProvider).currency;
    final currencySymbol = currency == 'CHF' ? 'CHF\u00a0' : '€\u00a0';

    final monthLabel =
        DateFormat.yMMMM(l10n.localeName).format(selectedMonth);

    // Remaining budget (sum of all budgets minus total spending)
    final totalBudget = budgetsAsync.valueOrNull
            ?.fold(0.0, (s, b) => s + b.amount) ??
        0.0;
    final budgetSet = totalBudget > 0;
    final remaining = totalBudget - totalSpending;

    // Last 5 transactions
    final recentTxs = (txAsync.valueOrNull ?? []).take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schlicht'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: l10n.dashboardMonthTooltip,
            onPressed: () => _pickMonth(context, ref, selectedMonth),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Month label
          Text(
            monthLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),

          // Total spending card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.totalSpending,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    '$currencySymbol${_fmt(totalSpending)}',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: AppTheme.budgetOk),
                  ),
                  if (budgetSet) ...[
                    const SizedBox(height: 12),
                    _BudgetBar(
                      spent: totalSpending,
                      budget: totalBudget,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.budgetRemaining,
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          '$currencySymbol${_fmt(remaining.clamp(0, double.infinity))}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: remaining < 0
                                    ? AppTheme.budgetOver
                                    : AppTheme.budgetOk,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.recentTransactions,
                  style: Theme.of(context).textTheme.labelLarge),
              if ((txAsync.valueOrNull?.length ?? 0) > 5)
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: const Text('→'),
                ),
            ],
          ),
          const SizedBox(height: 8),

          txAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(l10n.genericError),
            data: (txs) {
              if (txs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48,
                          color:
                              Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(l10n.noTransactionsYet,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(l10n.noTransactionsSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center),
                    ],
                  ),
                );
              }
              return Column(
                children: recentTxs.map((tx) {
                  final cat = catMap[tx.categoryId];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: cat != null
                        ? CategoryIcon(
                            iconName: cat.icon,
                            colorValue: cat.colorValue,
                          )
                        : const Icon(Icons.label_outline),
                    title: Text(cat != null
                        ? categoryDisplayName(l10n, cat.code, cat.name)
                        : '—'),
                    subtitle: Text(
                      _formatDate(context, l10n, tx.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Text(
                      '$currencySymbol${_fmt(tx.amount)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () =>
                        context.push('/transactions/${tx.id}/edit'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(
      BuildContext context, WidgetRef ref, DateTime current) async {
    // Simple year/month picker using showDatePicker with day-level precision;
    // we only care about year+month.
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: '',
      fieldLabelText: '',
    );
    if (picked != null) {
      ref.read(selectedMonthProvider.notifier).state =
          DateTime(picked.year, picked.month);
    }
  }

  String _formatDate(
      BuildContext context, AppLocalizations l10n, DateTime date) {
    if (date.isToday) return l10n.today;
    if (date.isYesterday) return l10n.yesterday;
    return DateFormat.MMMd(l10n.localeName).format(date);
  }

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);
}

// ---------------------------------------------------------------------------
// Budget progress bar
// ---------------------------------------------------------------------------

class _BudgetBar extends StatelessWidget {
  final double spent;
  final double budget;

  const _BudgetBar({required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final ratio = (budget > 0 ? spent / budget : 0.0).clamp(0.0, 1.0);
    final color = ratio >= 1.0
        ? AppTheme.budgetOver
        : ratio >= 0.8
            ? AppTheme.budgetWarning
            : AppTheme.budgetOk;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: ratio,
        minHeight: 8,
        color: color,
        backgroundColor: Theme.of(context).dividerColor,
      ),
    );
  }
}
