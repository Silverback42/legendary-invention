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
  final bool hasCompletedOnboarding;
  final DateTime? trialStartDate;
  final bool weeklyDigestEnabled;
  final String themeMode; // 'system', 'light', 'dark'

  const AppSettings({
    this.currency = 'EUR',
    this.locale = 'de',
    this.inputMode = 'single',
    this.hasCompletedOnboarding = false,
    this.trialStartDate,
    this.weeklyDigestEnabled = false,
    this.themeMode = 'system',
  });

  String get currencySymbol => currency == 'CHF' ? 'CHF' : '€';

  /// Full locale string for NumberFormat / DateFormat (e.g. 'de_DE', 'en_US').
  String get fullLocale => locale == 'en' ? 'en_US' : 'de_DE';

  AppSettings copyWith({
    String? currency,
    String? locale,
    String? inputMode,
    bool? hasCompletedOnboarding,
    DateTime? trialStartDate,
    bool clearTrialStartDate = false,
    bool? weeklyDigestEnabled,
    String? themeMode,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      inputMode: inputMode ?? this.inputMode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      trialStartDate:
          clearTrialStartDate ? null : (trialStartDate ?? this.trialStartDate),
      weeklyDigestEnabled:
          weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'locale': locale,
        'inputMode': inputMode,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'trialStartDate': trialStartDate?.toIso8601String(),
        'weeklyDigestEnabled': weeklyDigestEnabled,
        'themeMode': themeMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final trialStr = json['trialStartDate'] as String?;
    return AppSettings(
      currency: json['currency'] as String? ?? 'EUR',
      locale: json['locale'] as String? ?? 'de',
      inputMode: json['inputMode'] as String? ?? 'single',
      hasCompletedOnboarding:
          json['hasCompletedOnboarding'] as bool? ?? false,
      trialStartDate: trialStr != null ? DateTime.tryParse(trialStr) : null,
      weeklyDigestEnabled:
          json['weeklyDigestEnabled'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
    );
  }
}

/// Notifier that manages [AppSettings] with JSON file persistence.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _init = load();
  }

  File? _file;
  late final Future<void> _init;

  /// Await this to ensure settings are loaded before routing decisions.
  Future<void> get initialized => _init;

  Future<void> load() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File(p.join(dir.path, 'schlicht_settings.json'));
    if (await _file!.exists()) {
      try {
        final json = jsonDecode(await _file!.readAsString());
        state = AppSettings.fromJson(json as Map<String, dynamic>);
      } on FormatException catch (e) {
        debugPrint('Failed to parse settings: $e');
      } catch (e) {
        debugPrint('Unexpected error loading settings: $e');
      }
    }
  }

  Future<void> _persist() async {
    await _init;
    await _file!.writeAsString(jsonEncode(state.toJson()));
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

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await _persist();
  }

  Future<void> startTrial() async {
    // Trial nur einmal starten — verhindert Neustart/Verlaengerung.
    if (state.trialStartDate != null) return;
    state = state.copyWith(trialStartDate: DateTime.now());
    await _persist();
  }

  Future<void> setWeeklyDigestEnabled(bool enabled) async {
    state = state.copyWith(weeklyDigestEnabled: enabled);
    await _persist();
  }

  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
