import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import 'subscription_service.dart';
import 'subscription_status.dart';

/// Singleton-Provider fuer den SubscriptionService.
///
/// Wird in main.dart mit `overrideWithValue` ueberschrieben,
/// damit der Service die eagerly erstellte AppSettingsNotifier-Instanz bekommt.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final settingsNotifier = ref.watch(appSettingsProvider.notifier);
  return SubscriptionService(settingsNotifier);
});

/// Aktueller Abo-Status als FutureProvider.
///
/// Wird bei Aenderungen an appSettingsProvider automatisch neu berechnet.
final subscriptionStatusProvider = FutureProvider<SubscriptionStatus>((ref) {
  // State beobachten, damit der Provider bei Settings-Aenderungen neu berechnet wird.
  ref.watch(appSettingsProvider);
  final service = ref.watch(subscriptionServiceProvider);
  return service.getStatus();
});

/// Convenience-Provider: ist der User Premium (Trial oder bezahlt)?
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final status = await ref.watch(subscriptionStatusProvider.future);
  return status.isPremium;
});
