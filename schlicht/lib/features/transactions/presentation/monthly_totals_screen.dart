import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/utils/category_name.dart';
import '../../../shared/widgets/category_icon.dart';

/// Monthly-totals input mode: enter one aggregate amount per category for
/// the chosen month. Each non-zero amount creates a single transaction.
class MonthlyTotalsScreen extends ConsumerStatefulWidget {
  const MonthlyTotalsScreen({super.key});

  @override
  ConsumerState<MonthlyTotalsScreen> createState() =>
      _MonthlyTotalsScreenState();
}

class _MonthlyTotalsScreenState
    extends ConsumerState<MonthlyTotalsScreen> {
  late DateTime _month;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int categoryId) =>
      _controllers.putIfAbsent(
          categoryId, () => TextEditingController());

  Future<void> _save(
      BuildContext context, List<Category> cats) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    int saved = 0;

    for (final cat in cats) {
      final raw = _controllers[cat.id]?.text.trim() ?? '';
      if (raw.isEmpty) continue;
      final amount =
          double.tryParse(raw.replaceAll(',', '.')) ?? 0.0;
      if (amount <= 0) continue;

      // Use the first day of the month as the date stamp
      await db.insertTransaction(
        TransactionsCompanion(
          amount: Value(amount),
          categoryId: Value(cat.id),
          date: Value(DateTime(_month.year, _month.month, 1)),
        ),
      );
      saved++;
    }

    if (context.mounted) {
      if (saved > 0) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.validationAmountRequired)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories =
        ref.watch(allCategoriesStreamProvider).valueOrNull ?? [];
    final currency = ref.watch(settingsProvider).currency;
    final currencySymbol = currency == 'CHF' ? 'CHF' : '€';
    final monthLabel =
        DateFormat.yMMMM(l10n.localeName).format(_month);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inputModeMonthly),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _month =
                      DateTime(_month.year, _month.month - 1)),
                ),
                GestureDetector(
                  onTap: () => _pickMonth(context),
                  child: Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: _month.year < DateTime.now().year ||
                            _month.month < DateTime.now().month
                        ? null
                        : Theme.of(context).disabledColor,
                  ),
                  onPressed: _month.year < DateTime.now().year ||
                          _month.month < DateTime.now().month
                      ? () => setState(() => _month =
                          DateTime(_month.year, _month.month + 1))
                      : null,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Category amount fields
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: categories.map((cat) {
                final ctrl = _controllerFor(cat.id);
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CategoryIcon(
                          iconName: cat.icon,
                          colorValue: cat.colorValue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          categoryDisplayName(
                              l10n, cat.code, cat.name),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: ctrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: '0',
                            prefixText: '$currencySymbol ',
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Save
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              onPressed: () => _save(context, categories),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(
          () => _month = DateTime(picked.year, picked.month));
    }
  }
}
