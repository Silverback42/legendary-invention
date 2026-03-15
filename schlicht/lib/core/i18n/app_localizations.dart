import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// The generated AppLocalizations class lives in .dart_tool/flutter_gen/gen_l10n/
// and is accessible via the synthetic package after running `flutter gen-l10n`.
// Re-export so callers can import this single file.
export 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Supported locales and delegates for Schlicht.
/// Renamed from AppLocalizations to avoid colliding with the generated class.
abstract class AppLocalizationsWrapper {
  static const List<Locale> supportedLocales = [
    Locale('de'),
    Locale('en'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
