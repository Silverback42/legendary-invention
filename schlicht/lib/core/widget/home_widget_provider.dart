import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../settings/app_settings.dart';
import 'home_widget_service.dart';

/// Aktualisiert das Home-Widget mit den neuesten Daten.
///
/// Wird als Convenience-Funktion bereitgestellt, damit Dashboard und
/// andere Stellen einfach `updateHomeWidget(ref)` aufrufen koennen.
Future<void> updateHomeWidget(Ref ref) async {
  final db = ref.read(databaseProvider);
  final settings = ref.read(appSettingsProvider);
  await HomeWidgetService.updateWidget(db: db, settings: settings);
}
