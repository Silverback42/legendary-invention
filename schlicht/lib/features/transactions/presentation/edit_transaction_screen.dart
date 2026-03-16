import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/utils/category_icon.dart';

/// Edit transaction screen – Phase 1a.
///
/// Loads the existing transaction by ID and allows the user to modify
/// amount, category, note and date.
class EditTransactionScreen extends ConsumerStatefulWidget {
  final int transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadTransaction(Transaction t, AppSettings settings) {
    if (_loaded) return;
    _loaded = true;
    _amountController.text = NumberFormat('#0.00', settings.fullLocale).format(t.amount);
    _noteController.text = t.note ?? '';
    _selectedCategoryId = t.categoryId;
    _selectedDate = t.date;
  }

  Future<void> _save(Transaction original) async {
    final l10n = AppLocalizations.of(context)!;
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationAmountPositive)),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationCategoryRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);
      final updated = Transaction(
        id: original.id,
        amount: amount,
        categoryId: _selectedCategoryId!,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _selectedDate,
        createdAt: original.createdAt,
        recurringId: original.recurringId,
      );
      await db.updateTransaction(updated);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editTransaction)),
      body: StreamBuilder<List<Transaction>>(
        stream: _findTransaction(db),
        builder: (context, txSnap) {
          if (txSnap.hasError) {
            return Center(child: Text(l10n.genericError));
          }
          if (!txSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final txList = txSnap.data!;
          if (txList.isEmpty) {
            return Center(child: Text(l10n.genericError));
          }
          final transaction = txList.first;
          _loadTransaction(transaction, settings);

          return StreamBuilder<List<Category>>(
            stream: db.watchAllCategories(),
            builder: (context, catSnap) {
              final categories = catSnap.data ?? [];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        suffixText: settings.currencySymbol,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category selection
                    Text(l10n.category,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final selected = cat.id == _selectedCategoryId;
                        final color = Color(cat.colorValue);
                        return ChoiceChip(
                          label: Text(cat.name),
                          avatar: Icon(
                            categoryIconData(cat.icon),
                            color: color,
                            size: 18,
                          ),
                          selected: selected,
                          selectedColor: color.withOpacity(0.15),
                          onSelected: (_) =>
                              setState(() => _selectedCategoryId = cat.id),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Note
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: l10n.note,
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: 8),

                    // Date
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.date,
                        ),
                        child: Text(
                          DateFormat.yMMMd(settings.fullLocale).format(_selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save
                    ElevatedButton(
                      onPressed: _saving ? null : () => _save(transaction),
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
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Watches all transactions and filters for the target ID.
  /// This is a simple approach since Drift doesn't expose a single-row watch by ID out of the box.
  Stream<List<Transaction>> _findTransaction(AppDatabase db) {
    return (db.select(db.transactions)
          ..where((t) => t.id.equals(widget.transactionId)))
        .watch();
  }
}
