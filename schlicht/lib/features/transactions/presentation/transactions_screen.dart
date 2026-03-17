import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/utils/category_icon.dart';

/// Transactions list – Phase 1a.
///
/// Groups transactions by day, supports month navigation,
/// swipe-to-delete and tap-to-edit.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() => _currentMonth = next);
    }
  }

  bool get _canGoNext {
    final now = DateTime.now();
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    return next.isBefore(DateTime(now.year, now.month + 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);
    final monthLabel = DateFormat.yMMMM(settings.fullLocale).format(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionsTitle),
      ),
      body: Column(
        children: [
          // Month navigation
          _MonthSelector(
            label: monthLabel,
            onPrevious: _previousMonth,
            onNext: _canGoNext ? _nextMonth : null,
          ),

          // Transaction list
          Expanded(
            child: StreamBuilder<List<Transaction>>(
              stream: db.watchTransactionsForMonth(
                _currentMonth.year,
                _currentMonth.month,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return _EmptyState(l10n: l10n);
                }
                return StreamBuilder<List<Category>>(
                  stream: db.watchAllCategories(),
                  builder: (context, catSnap) {
                    final categories = catSnap.data ?? [];
                    return _TransactionListByDay(
                      transactions: transactions,
                      categories: categories,
                      db: db,
                      l10n: l10n,
                      locale: settings.fullLocale,
                      currencySymbol: settings.currencySymbol,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month selector bar
// ---------------------------------------------------------------------------

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransactionsYet,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noTransactionsSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped transaction list
// ---------------------------------------------------------------------------

class _TransactionListByDay extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final AppDatabase db;
  final AppLocalizations l10n;
  final String locale;
  final String currencySymbol;

  const _TransactionListByDay({
    required this.transactions,
    required this.categories,
    required this.db,
    required this.l10n,
    required this.locale,
    required this.currencySymbol,
  });

  Map<DateTime, List<Transaction>> _groupByDay() {
    final map = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      (map[key] ??= []).add(t);
    }
    return map;
  }

  String _dayLabel(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (date == today) return l10n.today;
    if (date == today.subtract(const Duration(days: 1))) {
      return l10n.yesterday;
    }
    return DateFormat.MMMEd(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay();
    final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final currencyFormat = NumberFormat.currency(
      locale: locale,
      symbol: currencySymbol,
    );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final dayTransactions = grouped[day]!;
        final dayTotal = dayTransactions.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dayLabel(context, day),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    currencyFormat.format(dayTotal),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Transaction items
            ...dayTransactions.map((t) => _TransactionTile(
                  transaction: t,
                  categories: categories,
                  db: db,
                  l10n: l10n,
                  currencyFormat: currencyFormat,
                )),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single transaction tile (swipe-to-delete)
// ---------------------------------------------------------------------------

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final List<Category> categories;
  final AppDatabase db;
  final AppLocalizations l10n;
  final NumberFormat currencyFormat;

  const _TransactionTile({
    required this.transaction,
    required this.categories,
    required this.db,
    required this.l10n,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final category = categories
        .where((c) => c.id == transaction.categoryId)
        .firstOrNull;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.deleteTransaction),
            content: Text(l10n.deleteTransactionConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        try {
          await db.deleteTransaction(transaction.id);
        } catch (e) {
          debugPrint('Failed to delete transaction ${transaction.id}: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.deleteError)),
            );
          }
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category != null
              ? Color(category.colorValue).withOpacity(0.15)
              : Colors.grey.withOpacity(0.15),
          child: Icon(
            category != null
                ? categoryIconData(category.icon)
                : Icons.circle_outlined,
            color:
                category != null ? Color(category.colorValue) : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          category?.name ?? '—',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: transaction.note != null && transaction.note!.isNotEmpty
            ? Text(
                transaction.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        onTap: () {
          context.push(
            AppRoutes.editTransaction
                .replaceFirst(':id', '${transaction.id}'),
          );
        },
      ),
    );
  }
}
