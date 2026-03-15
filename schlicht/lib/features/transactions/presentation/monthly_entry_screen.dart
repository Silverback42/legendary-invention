import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../shared/utils/category_icon.dart';

/// Monthly totals entry screen – Phase 1a.
///
/// Allows the user to enter a total amount per category for a selected month.
/// Each non-zero entry creates a transaction for the 1st of that month.
class MonthlyEntryScreen extends ConsumerStatefulWidget {
  const MonthlyEntryScreen({super.key});

  @override
  ConsumerState<MonthlyEntryScreen> createState() =>
      _MonthlyEntryScreenState();
}

class _MonthlyEntryScreenState extends ConsumerState<MonthlyEntryScreen> {
  late DateTime _selectedMonth;
  final Map<int, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int categoryId) {
    return _controllers.putIfAbsent(
      categoryId,
      () => TextEditingController(),
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  Future<void> _save(List<Category> categories) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, 1);

      for (final cat in categories) {
        final text = _controllerFor(cat.id).text.trim().replaceAll(',', '.');
        final amount = double.tryParse(text);
        if (amount != null && amount > 0) {
          await db.insertTransaction(TransactionsCompanion(
            amount: Value(amount),
            categoryId: Value(cat.id),
            note: Value('Monatssumme ${DateFormat.yMMMM('de_DE').format(date)}'),
            date: Value(date),
          ));
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inputModeMonthly),
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat.yMMMM('de_DE').format(_selectedMonth),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          const Divider(),

          // Category list with amount fields
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: db.watchAllCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final color = Color(cat.colorValue);
                    return _CategoryAmountRow(
                      category: cat,
                      color: color,
                      controller: _controllerFor(cat.id),
                    );
                  },
                );
              },
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: StreamBuilder<List<Category>>(
              stream: db.watchAllCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                return ElevatedButton(
                  onPressed:
                      _saving ? null : () => _save(categories),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryAmountRow extends StatelessWidget {
  final Category category;
  final Color color;
  final TextEditingController controller;

  const _CategoryAmountRow({
    required this.category,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            categoryIconData(category.icon),
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '0,00',
              suffixText: '€',
              isDense: true,
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
