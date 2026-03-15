import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// This file re-exports the generated AppLocalizations and adds convenience helpers.
// The actual generated code lives in lib/l10n/ (created by `flutter gen-l10n`).

// Re-export generated class when build_runner runs:
// export 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Supported locales for Schlicht.
abstract class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('de'),
    Locale('en'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    // AppLocalizations.delegate, // Uncomment after running flutter gen-l10n
  ];
}
