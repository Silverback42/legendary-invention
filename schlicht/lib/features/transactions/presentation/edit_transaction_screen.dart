import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/providers/db_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../shared/extensions/datetime_extensions.dart';
import 'transaction_form_widgets.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final int transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends ConsumerState<EditTransactionScreen> {
  String _amountStr = '';
  int? _selectedCategoryId;
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  Transaction? _original;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadTransaction() async {
    final tx = await ref
        .read(databaseProvider)
        .getTransactionById(widget.transactionId);
    if (!mounted) return;
    setState(() {
      _original = tx;
      if (tx != null) {
        _amountStr = tx.amount % 1 == 0
            ? tx.amount.toInt().toString()
            : tx.amount.toString();
        _selectedCategoryId = tx.categoryId;
        _noteController.text = tx.note ?? '';
        _selectedDate = tx.date;
      }
      _loading = false;
    });
  }

  double get _parsedAmount => double.tryParse(_amountStr) ?? 0.0;
  String get _displayAmount => _amountStr.isEmpty ? '0' : _amountStr;

  void _onNumKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountStr.isNotEmpty) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
        return;
      }
      if (key == ',') {
        if (!_amountStr.contains('.')) {
          if (_amountStr.isEmpty) _amountStr = '0';
          _amountStr += '.';
        }
        return;
      }
      final parts = _amountStr.split('.');
      if (parts.length == 2 && parts[1].length >= 2) return;
      if (_amountStr.length >= 8) return;
      _amountStr = (_amountStr == '0') ? key : _amountStr + key;
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_parsedAmount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.validationAmountPositive)));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.validationCategoryRequired)));
      return;
    }
    final note = _noteController.text.trim();
    final updated = _original!.copyWith(
      amount: _parsedAmount,
      categoryId: _selectedCategoryId!,
      note: Value(note.isEmpty ? null : note),
      date: _selectedDate,
    );
    await ref.read(databaseProvider).updateTransaction(updated);
    if (context.mounted) context.pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
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
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(databaseProvider)
          .deleteTransaction(widget.transactionId);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_original == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Icon(Icons.error_outline, size: 48)),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(allCategoriesStreamProvider);
    final currency = ref.watch(settingsProvider).currency;
    final currencySymbol = currency == 'CHF' ? 'CHF ' : '€ ';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editTransaction),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
            tooltip: l10n.deleteTransaction,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceVariant,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Text(
              '$currencySymbol$_displayAmount',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.right,
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              children: [
                Text(l10n.category,
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 10),
                categories.when(
                  loading: () => const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text(l10n.genericError),
                  data: (cats) => GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.85,
                    children: cats
                        .map((cat) => TransactionCategoryTile(
                              cat: cat,
                              selected: cat.id == _selectedCategoryId,
                              l10n: l10n,
                              onTap: () =>
                                  setState(() => _selectedCategoryId = cat.id),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: l10n.note,
                    prefixIcon: const Icon(Icons.edit_note_outlined),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(_formatDate(context, _selectedDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickDate(context),
                ),
              ],
            ),
          ),

          TransactionNumPad(onKey: _onNumKey),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton(
              onPressed: () => _save(context),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    if (date.isToday) return l10n.today;
    if (date.isYesterday) return l10n.yesterday;
    return DateFormat.MMMd(l10n.localeName).format(date);
  }
}
