import 'package:intl/intl.dart';

import '../db/database.dart';

/// Ergebnis der Digest-Berechnung.
class DigestResult {
  final String title;
  final String body;

  const DigestResult({required this.title, required this.body});
}

/// Berechnet den woechentlichen Digest-Inhalt.
class DigestCalculator {
  DigestCalculator._();

  /// Berechnet den Digest fuer die aktuelle Woche.
  ///
  /// Vergleicht Ausgaben der Woche mit dem proportionalen Monatsbudget
  /// und liefert eine positive, ermutigende Nachricht.
  static Future<DigestResult> calculate({
    required AppDatabase db,
    required String locale,
    required String currency,
  }) async {
    final now = DateTime.now();

    // Wochenanfang (Montag) und -ende (Sonntag)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weeklyTransactions = await db.getTransactionsForDateRange(
      DateTime(weekStart.year, weekStart.month, weekStart.day),
      DateTime(weekEnd.year, weekEnd.month, weekEnd.day),
    );

    final weeklyTotal =
        weeklyTransactions.fold<double>(0, (sum, t) => sum + t.amount);

    // Monatsbudget proportional auf die Woche herunterrechnen
    final budgets = await db.getAllBudgets(now.year, now.month);
    final monthlyBudget =
        budgets.fold<double>(0, (sum, b) => sum + b.amount);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final weeklyBudget = monthlyBudget > 0
        ? (monthlyBudget / daysInMonth) * 7
        : 0.0;

    final fullLocale = locale == 'en' ? 'en_US' : 'de_DE';
    final symbol = currency == 'CHF' ? 'CHF' : '€';
    final fmt = NumberFormat.currency(
      locale: fullLocale,
      symbol: symbol,
      decimalDigits: 0,
    );

    // Titel und Text
    final isGerman = locale == 'de';
    final title = isGerman ? 'Dein Wochen-Check' : 'Your weekly check-in';

    String body;
    if (weeklyTotal == 0) {
      body = isGerman
          ? 'Diese Woche noch nichts ausgegeben – weiter so!'
          : 'No spending this week – keep it up!';
    } else if (weeklyBudget > 0 && weeklyTotal <= weeklyBudget) {
      final remaining = fmt.format(weeklyBudget - weeklyTotal);
      body = isGerman
          ? '${fmt.format(weeklyTotal)} ausgegeben, $remaining noch übrig. Weiter so!'
          : '${fmt.format(weeklyTotal)} spent, $remaining remaining. Great job!';
    } else if (weeklyBudget > 0 && weeklyTotal > weeklyBudget) {
      body = isGerman
          ? '${fmt.format(weeklyTotal)} ausgegeben. Nächste Woche wird besser!'
          : '${fmt.format(weeklyTotal)} spent. Next week will be better!';
    } else {
      body = isGerman
          ? 'Diese Woche: ${fmt.format(weeklyTotal)} ausgegeben.'
          : 'This week: ${fmt.format(weeklyTotal)} spent.';
    }

    return DigestResult(title: title, body: body);
  }
}
