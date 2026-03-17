import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../settings/app_settings.dart';

/// Dart-Side Bridge fuer das iOS WidgetKit / Android AppWidget.
///
/// Berechnet das verbleibende Monatsbudget und speichert die Daten
/// via `HomeWidget.saveWidgetData()` in den Shared Storage,
/// von wo das native Widget sie liest.
///
/// Native Widget-UI (SwiftUI / XML) muss vom User erstellt werden.
/// Template-Code:
///
/// **iOS (SwiftUI WidgetView):**
/// ```swift
/// // App Group: group.com.schlicht.widget
/// // Keys: remaining_budget, currency_symbol, month_label, has_budget
/// let defaults = UserDefaults(suiteName: "group.com.schlicht.widget")
/// let remaining = defaults?.string(forKey: "remaining_budget") ?? "–"
/// let currency = defaults?.string(forKey: "currency_symbol") ?? "€"
/// let month = defaults?.string(forKey: "month_label") ?? ""
/// let hasBudget = defaults?.bool(forKey: "has_budget") ?? false
/// ```
///
/// **Android (AppWidgetProvider):**
/// ```kotlin
/// // SharedPreferences name: HomeWidgetPlugin
/// // Keys: remaining_budget, currency_symbol, month_label, has_budget
/// val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)
/// val remaining = prefs.getString("remaining_budget", "–")
/// ```
class HomeWidgetService {
  HomeWidgetService._();

  static const _appGroupId = 'group.com.schlicht.widget';
  static const _androidWidgetName = 'SchlichtWidgetProvider';

  /// Einmalig beim App-Start aufrufen.
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (e) {
      debugPrint('HomeWidget init failed: $e');
    }
  }

  /// Widget-Daten aktualisieren.
  ///
  /// Berechnet verbleibendes Budget fuer den aktuellen Monat
  /// und speichert es im Shared Storage.
  static Future<void> updateWidget({
    required AppDatabase db,
    required AppSettings settings,
  }) async {
    try {
      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // Gesamtbudget und -ausgaben laden
      final budgets = await db.getAllBudgets(year, month);
      final totalBudget =
          budgets.fold<double>(0, (sum, b) => sum + b.amount);
      final totalSpending =
          await db.getTotalSpendingForMonth(year, month);

      final hasBudget = totalBudget > 0;
      final remaining = totalBudget - totalSpending;

      // Formatierung
      final fullLocale = settings.locale == 'en' ? 'en_US' : 'de_DE';
      final fmt = NumberFormat.currency(
        locale: fullLocale,
        symbol: settings.currencySymbol,
        decimalDigits: 0,
      );
      final monthLabel =
          DateFormat.MMMM(fullLocale).format(DateTime(year, month));

      // Daten speichern
      await HomeWidget.saveWidgetData('remaining_budget', fmt.format(remaining));
      await HomeWidget.saveWidgetData('currency_symbol', settings.currencySymbol);
      await HomeWidget.saveWidgetData('month_label', monthLabel);
      await HomeWidget.saveWidgetData('has_budget', hasBudget);

      // Natives Widget aktualisieren
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: 'SchlichtWidget',
      );
    } catch (e) {
      debugPrint('HomeWidget update failed: $e');
    }
  }
}
