import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../settings/app_settings.dart';
import 'digest_calculator.dart';
import 'notification_service.dart';

/// Plant oder bricht den woechentlichen Digest basierend auf Settings ab.
///
/// Wird in main.dart nach dem App-Start aufgerufen und bei
/// Settings-Aenderungen erneut getriggert.
Future<void> syncDigestSchedule({
  required AppSettings settings,
  required AppDatabase db,
}) async {
  if (settings.weeklyDigestEnabled) {
    final digest = await DigestCalculator.calculate(
      db: db,
      locale: settings.locale,
    );
    await NotificationService.scheduleWeeklyDigest(
      title: digest.title,
      body: digest.body,
    );
  } else {
    await NotificationService.cancelWeeklyDigest();
  }
}
