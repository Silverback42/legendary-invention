import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/utils/category_icon.dart';

/// Uebersicht und Verwaltung wiederkehrender Ausgaben – Phase 1.5 (R-013).
class RecurringExpensesScreen extends ConsumerWidget {
  const RecurringExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<RecurringExpense>>(
        stream: db.watchAllRecurringExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data!;
          if (expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.noRecurringYet, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(l10n.noRecurringSubtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return StreamBuilder<List<Category>>(
            stream: db.watchAllCategories(),
            builder: (context, catSnap) {
              final categories = catSnap.data ?? [];
              final currencyFormat = NumberFormat.currency(
                locale: settings.fullLocale,
                symbol: settings.currencySymbol,
              );

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  final category = categories.where((c) => c.id == expense.categoryId).firstOrNull;

                  return Dismissible(
                    key: ValueKey(expense.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.deleteRecurring),
                          content: Text(l10n.deleteRecurringConfirm),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) => db.deleteRecurringExpense(expense.id),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category != null
                            ? Color(category.colorValue).withOpacity(0.15)
                            : Colors.grey.withOpacity(0.15),
                        child: Icon(
                          category != null ? categoryIconData(category.icon) : Icons.circle_outlined,
                          color: category != null ? Color(category.colorValue) : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(category?.name ?? '—'),
                      subtitle: Text(
                        '${currencyFormat.format(expense.amount)} · ${_frequencyLabel(l10n, expense.frequency)}',
                      ),
                      trailing: Switch(
                        value: expense.isActive,
                        onChanged: (active) {
                          db.updateRecurringExpense(RecurringExpense(
                            id: expense.id,
                            amount: expense.amount,
                            categoryId: expense.categoryId,
                            note: expense.note,
                            frequency: expense.frequency,
                            dayOfPeriod: expense.dayOfPeriod,
                            isActive: active,
                            createdAt: expense.createdAt,
                            lastGeneratedAt: expense.lastGeneratedAt,
                          ));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _frequencyLabel(AppLocalizations l10n, String frequency) {
    switch (frequency) {
      case 'weekly':
        return l10n.frequencyWeekly;
      case 'yearly':
        return l10n.frequencyYearly;
      default:
        return l10n.frequencyMonthly;
    }
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final categories = await db.getAllCategories();

    if (!context.mounted) return;

    final amountController = TextEditingController();
    final noteController = TextEditingController();
    int? selectedCategoryId;
    String selectedFrequency = 'monthly';
    int dayOfPeriod = DateTime.now().day;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.addRecurring, style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: 16),

              // Betrag
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: l10n.amount),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              // Kategorie
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final selected = cat.id == selectedCategoryId;
                  final color = Color(cat.colorValue);
                  return ChoiceChip(
                    label: Text(cat.name),
                    avatar: Icon(categoryIconData(cat.icon), color: color, size: 16),
                    selected: selected,
                    selectedColor: color.withOpacity(0.15),
                    onSelected: (_) => setSheetState(() => selectedCategoryId = cat.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Notiz
              TextField(
                controller: noteController,
                decoration: InputDecoration(labelText: l10n.note),
                maxLength: 100,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              ),
              const SizedBox(height: 12),

              // Frequenz
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'weekly', label: Text(l10n.frequencyWeekly)),
                  ButtonSegment(value: 'monthly', label: Text(l10n.frequencyMonthly)),
                  ButtonSegment(value: 'yearly', label: Text(l10n.frequencyYearly)),
                ],
                selected: {selectedFrequency},
                onSelectionChanged: (v) => setSheetState(() => selectedFrequency = v.first),
              ),
              const SizedBox(height: 20),

              // Speichern
              ElevatedButton(
                onPressed: () async {
                  final amountText = amountController.text.replaceAll(',', '.');
                  final amount = double.tryParse(amountText);
                  if (amount == null || amount <= 0 || selectedCategoryId == null) return;

                  await db.insertRecurringExpense(RecurringExpensesCompanion(
                    amount: Value(amount),
                    categoryId: Value(selectedCategoryId!),
                    note: Value(noteController.text.trim().isEmpty ? null : noteController.text.trim()),
                    frequency: Value(selectedFrequency),
                    dayOfPeriod: Value(dayOfPeriod),
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
