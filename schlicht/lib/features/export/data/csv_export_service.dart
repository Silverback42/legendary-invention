import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/db/database.dart';

/// CSV-Export-Service – Phase 1.5 (R-022).
/// Kostenlos fuer alle Nutzer.
class CsvExportService {
  /// Erstellt eine CSV-Datei und oeffnet das Share-Sheet.
  ///
  /// [headerLabels] – lokalisierte Spaltenüberschriften (Datum, Kategorie, Betrag, Waehrung, Notiz).
  /// [shareSubject] – lokalisierter Betreff für das Share-Sheet.
  static Future<void> exportAndShare({
    required List<Transaction> transactions,
    required List<Category> categories,
    required String locale,
    required String currencySymbol,
    required List<String> headerLabels,
    required String shareSubject,
  }) async {
    final categoryMap = {for (final c in categories) c.id: c.name};
    final dateFormat = DateFormat('yyyy-MM-dd', locale);
    final buffer = StringBuffer();

    // Lokalisierter Header
    buffer.writeln(headerLabels.join(','));

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
      subject: shareSubject,
    );
  }

  /// Escaped einen Wert fuer CSV.
  /// Neutralisiert Formel-Injection (=, +, -, @) und behandelt Sonderzeichen.
  static String _escapeCsv(String value) {
    var safe = value;

    // Formel-Injection verhindern
    if (safe.isNotEmpty && '=+-@'.contains(safe[0])) {
      safe = "'$safe";
    }

    if (safe.contains(',') || safe.contains('"') || safe.contains('\n') || safe != value) {
      return '"${safe.replaceAll('"', '""')}"';
    }
    return safe;
  }
}
