import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/settings/app_settings.dart';
import '../data/csv_export_service.dart';

/// CSV-Export Screen – Phase 1.5 (R-022).
/// Kostenlos fuer alle Nutzer.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  int? _selectedCategoryId;
  bool _exporting = false;

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);

    try {
      final db = ref.read(databaseProvider);
      final settings = ref.read(appSettingsProvider);

      // DST-sichere Berechnung des exklusiven Enddatums
      final endExclusive = DateTime(_endDate.year, _endDate.month, _endDate.day + 1);

      final transactions = await db.getFilteredTransactions(
        startDate: _startDate,
        endDate: endExclusive,
        categoryId: _selectedCategoryId,
      );

      final categories = await db.getAllCategories();
      final l10nExport = AppLocalizations.of(context)!;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      await CsvExportService.exportAndShare(
        transactions: transactions,
        categories: categories,
        locale: settings.fullLocale,
        currencySymbol: settings.currencySymbol,
        headerLabels: [
          l10nExport.csvHeaderDate,
          l10nExport.csvHeaderCategory,
          l10nExport.csvHeaderAmount,
          l10nExport.csvHeaderCurrency,
          l10nExport.csvHeaderNote,
        ],
        shareSubject: '${l10nExport.csvShareSubject} $timestamp',
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);
    final dateFormat = DateFormat.yMMMd(settings.fullLocale);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zeitraum
            Text(l10n.exportDateRange, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(isStart: true),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l10n.exportFrom),
                      child: Text(dateFormat.format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(isStart: false),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l10n.exportTo),
                      child: Text(dateFormat.format(_endDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Kategorie-Filter
            Text(l10n.exportCategoryFilter, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            StreamBuilder<List<Category>>(
              stream: db.watchAllCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.exportAllCategories),
                      selected: _selectedCategoryId == null,
                      onSelected: (_) => setState(() => _selectedCategoryId = null),
                    ),
                    ...categories.map((cat) => ChoiceChip(
                          label: Text(cat.name),
                          selected: _selectedCategoryId == cat.id,
                          selectedColor: Color(cat.colorValue).withOpacity(0.15),
                          onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                        )),
                  ],
                );
              },
            ),
            const Spacer(),

            // Export-Button
            ElevatedButton.icon(
              onPressed: _exporting ? null : _export,
              icon: _exporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.file_download_outlined),
              label: Text(l10n.exportButton),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.exportFreeHint,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
