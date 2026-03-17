import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Top-Level Callback fuer den Home-Widget Background-Refresh.
///
/// Wird von `home_widget` aufgerufen wenn das Widget aktualisiert
/// werden soll (z.B. bei Timeline-Refresh auf iOS).
///
/// Muss eine Top-Level-Funktion sein (kein Instanz-Method).
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  debugPrint('HomeWidget background callback: $uri');

  if (uri?.host == 'open') {
    // Deep-Link: App oeffnen (wird vom System-Default-Handler behandelt)
    return;
  }

  // Fuer Background-Refresh: Daten koennen hier nicht einfach
  // berechnet werden (kein Riverpod/DB-Context verfuegbar).
  // Stattdessen werden die Daten beim naechsten App-Start aktualisiert.
}
