import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/category_icon.dart';

/// Budget setup screen – Phase 1b.
///
/// Lists all categories with their current budget for the selected month.
/// Users can set / update / remove a per-category monthly budget.
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _changeMonth(int delta) {
    setState(() {
      var m = _month + delta;
      var y = _year;
      if (m > 12) {
        m = 1;
        y++;
      } else if (m < 1) {
        m = 12;
        y--;
      }
      _month = m;
      _year = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetSetupTitle),
      ),
      body: Column(
        children: [
          // Month selector
          _MonthSelector(
            year: _year,
            month: _month,
            locale: settings.fullLocale,
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
            l10n: l10n,
          ),

          // Category budget list
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: db.watchAllCategories(),
              builder: (context, catSnap) {
                final categories = catSnap.data ?? [];
                if (categories.isEmpty) {
                  return Center(child: Text(l10n.noBudgetsSubtitle));
                }

                return StreamBuilder<List<Budget>>(
                  stream: db.watchBudgetsForMonth(_year, _month),
                  builder: (context, budgetSnap) {
                    final budgets = budgetSnap.data ?? [];
                    final budgetMap = {
                      for (final b in budgets) b.categoryId: b,
                    };

                    return FutureBuilder<Map<int, double>>(
                      future: db.getSpendingByCategory(_year, _month),
                      builder: (context, spendingSnap) {
                        final spending = spendingSnap.data ?? {};

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final budget = budgetMap[cat.id];
                            final spent = spending[cat.id] ?? 0.0;

                            return _BudgetCategoryTile(
                              category: cat,
                              budget: budget,
                              spent: spent,
                              year: _year,
                              month: _month,
                              locale: settings.fullLocale,
                              currencySymbol: settings.currencySymbol,
                              db: db,
                              l10n: l10n,
                            );
                          },
                        );
                      },
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
// Month selector
// ---------------------------------------------------------------------------

class _MonthSelector extends StatelessWidget {
  final int year;
  final int month;
  final String locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final AppLocalizations l10n;

  const _MonthSelector({
    required this.year,
    required this.month,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        DateFormat.yMMMM(locale).format(DateTime(year, month));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.monthPrevious,
            onPressed: onPrevious,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.monthNext,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single category budget tile with progress bar
// ---------------------------------------------------------------------------

class _BudgetCategoryTile extends StatelessWidget {
  final Category category;
  final Budget? budget;
  final double spent;
  final int year;
  final int month;
  final String locale;
  final String currencySymbol;
  final AppDatabase db;
  final AppLocalizations l10n;

  const _BudgetCategoryTile({
    required this.category,
    required this.budget,
    required this.spent,
    required this.year,
    required this.month,
    required this.locale,
    required this.currencySymbol,
    required this.db,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasBudget = budget != null && budget!.amount > 0;
    final budgetAmount = budget?.amount ?? 0.0;
    final ratio = hasBudget ? spent / budgetAmount : 0.0;
    final fmt = NumberFormat.currency(locale: locale, symbol: currencySymbol);

    Color statusColor;
    String? hint;
    if (!hasBudget) {
      statusColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
    } else if (ratio >= 1.0) {
      statusColor = AppTheme.budgetOver;
      hint = l10n.budgetOverHint;
    } else if (ratio >= 0.8) {
      statusColor = AppTheme.budgetWarning;
      hint = l10n.budgetAlmostReachedHint;
    } else {
      statusColor = AppTheme.budgetOk;
      hint = l10n.budgetOnTrack;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBudgetDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Color(category.colorValue).withOpacity(0.15),
                    child: Icon(
                      categoryIconData(category.icon),
                      color: Color(category.colorValue),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (hasBudget)
                    Text(
                      l10n.budgetProgress(fmt.format(spent), fmt.format(budgetAmount)),
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    Text(
                      l10n.noBudgetSet,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),

              // Progress bar
              if (hasBudget) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Theme.of(context).dividerColor,
                    color: statusColor,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: budget != null && budget!.amount > 0
          ? budget!.amount.toStringAsFixed(2)
          : '',
    );

    final result = await showDialog<double?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetFor(category.name)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            labelText: l10n.budgetAmount,
            prefixText: '$currencySymbol ',
          ),
          autofocus: true,
        ),
        actions: [
          if (budget != null && budget!.amount > 0)
            TextButton(
              onPressed: () => Navigator.pop(ctx, -1.0), // signal: delete
              child: Text(
                l10n.delete,
                style: TextStyle(color: AppTheme.budgetOver),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.replaceAll(',', '.');
              final amount = double.tryParse(text);
              if (amount != null && amount > 0) {
                Navigator.pop(ctx, amount);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == -1.0 && budget != null) {
      await db.deleteBudget(budget!.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.budgetRemoved)),
        );
      }
    } else if (result > 0) {
      await db.insertBudget(BudgetsCompanion(
        categoryId: Value(category.id),
        amount: Value(result),
        month: Value(month),
        year: Value(year),
      ));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.budgetSaved)),
        );
      }
    }
  }
}
