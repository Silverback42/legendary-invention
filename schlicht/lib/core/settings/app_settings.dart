import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// User-configurable settings, persisted as a JSON file.
class AppSettings {
  final String currency; // 'EUR' or 'CHF'
  final String locale; // 'de' or 'en'
  final String inputMode; // 'single' or 'monthly'

  const AppSettings({
    this.currency = 'EUR',
    this.locale = 'de',
    this.inputMode = 'single',
  });

  String get currencySymbol => currency == 'CHF' ? 'CHF' : '€';

  AppSettings copyWith({
    String? currency,
    String? locale,
    String? inputMode,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      inputMode: inputMode ?? this.inputMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'locale': locale,
        'inputMode': inputMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currency: json['currency'] as String? ?? 'EUR',
      locale: json['locale'] as String? ?? 'de',
      inputMode: json['inputMode'] as String? ?? 'single',
    );
  }
}

/// Notifier that manages [AppSettings] with JSON file persistence.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  File? _file;

  Future<void> load() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File(p.join(dir.path, 'schlicht_settings.json'));
    if (await _file!.exists()) {
      try {
        final json = jsonDecode(await _file!.readAsString());
        state = AppSettings.fromJson(json as Map<String, dynamic>);
      } catch (_) {
        // Corrupted file – keep defaults
      }
    }
  }

  Future<void> _persist() async {
    if (_file != null) {
      await _file!.writeAsString(jsonEncode(state.toJson()));
    }
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    await _persist();
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _persist();
  }

  Future<void> setInputMode(String mode) async {
    state = state.copyWith(inputMode: mode);
    await _persist();
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
