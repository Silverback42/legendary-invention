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

/// Dashboard – Phase 1a minimal version.
///
/// Shows:
/// - Current month + total spending
/// - Remaining budget (if set)
/// - Last 5 transactions
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schlicht'),
      ),
      body: SingleChildScrollView(
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

            // Spending + Budget card
            _SpendingCard(
              db: db,
              year: year,
              month: month,
              l10n: l10n,
              locale: settings.fullLocale,
              currencySymbol: settings.currencySymbol,
            ),
            const SizedBox(height: 24),

            // Recent transactions
            _RecentTransactions(
              db: db,
              year: year,
              month: month,
              l10n: l10n,
              locale: settings.fullLocale,
              currencySymbol: settings.currencySymbol,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spending overview card
// ---------------------------------------------------------------------------

class _SpendingCard extends StatelessWidget {
  final AppDatabase db;
  final int year;
  final int month;
  final AppLocalizations l10n;
  final String locale;
  final String currencySymbol;

  const _SpendingCard({
    required this.db,
    required this.year,
    required this.month,
    required this.l10n,
    required this.locale,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: db.watchTransactionsForMonth(year, month),
      builder: (context, txSnap) {
        final transactions = txSnap.data ?? [];
        final totalSpending = transactions.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );

        return StreamBuilder<List<Budget>>(
          stream: db.watchBudgetsForMonth(year, month),
          builder: (context, budgetSnap) {
            final budgets = budgetSnap.data ?? [];
            final totalBudget = budgets.fold<double>(
              0,
              (sum, b) => sum + b.amount,
            );
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

            final currencyFormat = NumberFormat.currency(
              locale: locale,
              symbol: currencySymbol,
            );

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total spending
                    Text(
                      l10n.totalSpending,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalSpending),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    if (hasBudget) ...[
                      const SizedBox(height: 16),
                      // Budget progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio.clamp(0, 1).toDouble(),
                          minHeight: 8,
                          backgroundColor:
                              Theme.of(context).dividerColor,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Remaining
                      Text(
                        remaining >= 0
                            ? '${l10n.budgetRemaining}: ${currencyFormat.format(remaining)}'
                            : '${l10n.budgetOver}: ${currencyFormat.format(remaining.abs())}',
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
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Recent transactions
// ---------------------------------------------------------------------------

class _RecentTransactions extends StatelessWidget {
  final AppDatabase db;
  final int year;
  final int month;
  final AppLocalizations l10n;
  final String locale;
  final String currencySymbol;

  const _RecentTransactions({
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

            // Sort by date descending and show last 5
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
