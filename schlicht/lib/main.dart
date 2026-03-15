import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/database.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/i18n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await db.seedDefaultCategories();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const SchlichtApp(),
    ),
  );
}

class SchlichtApp extends ConsumerWidget {
  const SchlichtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Schlicht',
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizationsWrapper.localizationsDelegates,
      supportedLocales: AppLocalizationsWrapper.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
