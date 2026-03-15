import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/extensions/datetime_extensions.dart';
import '../../../shared/utils/category_name.dart';
import '../../../shared/widgets/category_icon.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final txAsync = ref.watch(transactionsForMonthProvider);
    final cats = ref.watch(allCategoriesStreamProvider).valueOrNull ?? [];
    final catMap = {for (final c in cats) c.id: c};
    final currency = ref.watch(settingsProvider).currency;
    final currencySymbol = currency == 'CHF' ? 'CHF\u00a0' : '€\u00a0';

    final monthLabel = DateFormat.yMMMM(l10n.localeName).format(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _MonthNavigator(
            label: monthLabel,
            onPrev: () => ref
                .read(selectedMonthProvider.notifier)
                .state = DateTime(
              selectedMonth.year,
              selectedMonth.month - 1,
            ),
            onNext: selectedMonth.year < DateTime.now().year ||
                    selectedMonth.month < DateTime.now().month
                ? () => ref
                    .read(selectedMonthProvider.notifier)
                    .state = DateTime(
                    selectedMonth.year,
                    selectedMonth.month + 1,
                  )
                : null,
          ),
        ),
      ),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.genericError)),
        data: (txs) {
          if (txs.isEmpty) {
            return _EmptyState(l10n: l10n);
          }
          // Group by calendar day (descending)
          final grouped = <DateTime, List<Transaction>>{};
          for (final tx in txs) {
            final day = tx.date.dateOnly;
            grouped.putIfAbsent(day, () => []).add(tx);
          }
          final days = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding:
                const EdgeInsets.only(bottom: 100), // space for FAB
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              final dayTxs = grouped[day]!;
              final dayTotal = dayTxs.fold(0.0, (s, t) => s + t.amount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDay(context, l10n, day),
                          style:
                              Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          '$currencySymbol${_formatAmount(dayTotal)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary,
                              ),
                        ),
                      ],
                    ),
                  ),

                  ...dayTxs.map((tx) {
                    final cat = catMap[tx.categoryId];
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.shade400,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      onDismissed: (_) => ref
                          .read(databaseProvider)
                          .deleteTransaction(tx.id),
                      child: ListTile(
                        leading: cat != null
                            ? CategoryIcon(
                                iconName: cat.icon,
                                colorValue: cat.colorValue,
                              )
                            : const Icon(Icons.label_outline),
                        title: Text(
                          cat != null
                              ? categoryDisplayName(
                                  l10n, cat.code, cat.name)
                              : '—',
                        ),
                        subtitle: tx.note != null
                            ? Text(tx.note!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall)
                            : null,
                        trailing: Text(
                          '$currencySymbol${_formatAmount(tx.amount)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        onTap: () => context.push(
                          '/transactions/${tx.id}/edit',
                        ),
                      ),
                    );
                  }),

                  const Divider(height: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatDay(
      BuildContext context, AppLocalizations l10n, DateTime day) {
    if (day.isToday) return l10n.today;
    if (day.isYesterday) return l10n.yesterday;
    return DateFormat.MMMd(l10n.localeName).format(day);
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }
}

// ---------------------------------------------------------------------------
// Month navigation bar
// ---------------------------------------------------------------------------

class _MonthNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  const _MonthNavigator({
    required this.label,
    required this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: onNext != null
                  ? null
                  : Theme.of(context).disabledColor,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(l10n.noTransactionsYet,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.noTransactionsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
