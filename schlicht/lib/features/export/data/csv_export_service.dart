import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../core/db/database.dart';

/// CSV-Export-Service – Phase 1.5 (R-022).
/// Kostenlos fuer alle Nutzer.
class CsvExportService {
  /// Erstellt eine CSV-Datei und oeffnet das Share-Sheet.
  static Future<void> exportAndShare({
    required List<Transaction> transactions,
    required List<Category> categories,
    required String locale,
    required String currencySymbol,
  }) async {
    final categoryMap = {for (final c in categories) c.id: c.name};
    final dateFormat = DateFormat('yyyy-MM-dd', locale);
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Datum,Kategorie,Betrag,Waehrung,Notiz');

    // Zeilen
    for (final t in transactions) {
      final date = dateFormat.format(t.date);
      final category = _escapeCsv(categoryMap[t.categoryId] ?? '—');
      final amount = t.amount.toStringAsFixed(2);
      final note = _escapeCsv(t.note ?? '');
      buffer.writeln('$date,$category,$amount,$currencySymbol,$note');
    }

    // Datei schreiben
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(p.join(dir.path, 'schlicht_export_$timestamp.csv'));
    await file.writeAsString(buffer.toString());

    // Teilen
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Schlicht Export $timestamp',
    );
  }

  /// Escaped einen Wert fuer CSV (Anführungszeichen bei Sonderzeichen).
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
