import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/database.dart';
import 'core/routing/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/notifications/notification_provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/widget/home_widget_service.dart';
import 'core/subscription/subscription_provider.dart';
import 'core/subscription/subscription_service.dart';
import 'core/theme/app_theme.dart';
import 'core/i18n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  // Eagerly load settings so the router can decide the initial route
  // (onboarding vs dashboard) without a flash of wrong content.
  final settingsNotifier = AppSettingsNotifier();
  await settingsNotifier.initialized;

  // Existing-user migration: users who already have data from Phase 1a/1b
  // should skip onboarding. Check if categories exist in the DB.
  // IMPORTANT: seed AFTER this check — otherwise fresh installs would find
  // seeded categories and wrongly skip onboarding.
  if (!settingsNotifier.state.hasCompletedOnboarding) {
    final categories = await db.getAllCategories();
    if (categories.isNotEmpty) {
      await settingsNotifier.completeOnboarding();
    }
  }

  // Seed default categories for users who completed onboarding already
  // (upgrade from Phase 1a/1b) or will complete it via the onboarding flow.
  // For fresh installs going through onboarding, this is a no-op since the
  // onboarding flow replaces these with template categories.
  if (settingsNotifier.state.hasCompletedOnboarding) {
    await db.seedDefaultCategories();
  }

  // Subscription-Service initialisieren (RevenueCat + lokaler Trial-State)
  final subscriptionService = SubscriptionService(settingsNotifier);
  try {
    await subscriptionService.initialize();
  } on Exception catch (e) {
    debugPrint('SubscriptionService init fehlgeschlagen: $e');
  }

  // Lokale Notifications initialisieren und Digest planen
  try {
    await NotificationService.initialize();
    await syncDigestSchedule(settings: settingsNotifier.state, db: db);
  } on Exception catch (e) {
    debugPrint('NotificationService init fehlgeschlagen: $e');
  }

  // Home-Widget initialisieren und Daten aktualisieren
  try {
    await HomeWidgetService.initialize();
    await HomeWidgetService.updateWidget(db: db, settings: settingsNotifier.state);
  } on Exception catch (e) {
    debugPrint('HomeWidgetService init fehlgeschlagen: $e');
  }

  // Wiederkehrende Ausgaben generieren (Phase 1.5)
  try {
    final generated = await db.generateDueRecurringTransactions();
    if (generated > 0) {
      debugPrint('$generated wiederkehrende Transaktionen generiert.');
    }
  } on Exception catch (e) {
    debugPrint('Recurring-Generierung fehlgeschlagen: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appSettingsProvider.overrideWith((_) => settingsNotifier),
        subscriptionServiceProvider.overrideWithValue(subscriptionService),
      ],
      child: const SchlichtApp(),
    ),
  );
}

class SchlichtApp extends ConsumerWidget {
  const SchlichtApp({super.key});

  static ThemeMode _resolveThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'Schlicht',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _resolveThemeMode(settings.themeMode),
      localizationsDelegates: AppLocalizationsWrapper.localizationsDelegates,
      supportedLocales: AppLocalizationsWrapper.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
