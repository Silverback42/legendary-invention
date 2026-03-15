import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// SharedPreferences provider – overridden in ProviderScope (see main.dart)
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override sharedPreferencesProvider in ProviderScope'),
);

// ---------------------------------------------------------------------------
// Input mode
// ---------------------------------------------------------------------------

enum InputMode { single, monthly }

// ---------------------------------------------------------------------------
// Settings value object
// ---------------------------------------------------------------------------

class AppSettings {
  final String currency;
  final InputMode inputMode;
  final Locale? locale;

  const AppSettings({
    this.currency = 'EUR',
    this.inputMode = InputMode.single,
    this.locale,
  });

  AppSettings copyWith({
    String? currency,
    InputMode? inputMode,
    Object? locale = _sentinel,
  }) =>
      AppSettings(
        currency: currency ?? this.currency,
        inputMode: inputMode ?? this.inputMode,
        locale: identical(locale, _sentinel) ? this.locale : locale as Locale?,
      );
}

const _sentinel = Object();

// ---------------------------------------------------------------------------
// Keys
// ---------------------------------------------------------------------------

const _keyCurrency = 'currency';
const _keyInputMode = 'input_mode';
const _keyLocale = 'locale';

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final localeCode = prefs.getString(_keyLocale);
    return AppSettings(
      currency: prefs.getString(_keyCurrency) ?? 'EUR',
      inputMode: InputMode.values[prefs.getInt(_keyInputMode) ?? 0],
      locale: localeCode != null ? Locale(localeCode) : null,
    );
  }

  Future<void> setCurrency(String value) async {
    await _prefs.setString(_keyCurrency, value);
    state = state.copyWith(currency: value);
  }

  Future<void> setInputMode(InputMode value) async {
    await _prefs.setInt(_keyInputMode, value.index);
    state = state.copyWith(inputMode: value);
  }

  Future<void> setLocale(Locale? value) async {
    if (value == null) {
      await _prefs.remove(_keyLocale);
    } else {
      await _prefs.setString(_keyLocale, value.languageCode);
    }
    state = state.copyWith(locale: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
