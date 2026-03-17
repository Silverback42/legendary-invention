import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../settings/app_settings.dart';
import 'subscription_constants.dart';
import 'subscription_status.dart';

/// Wrapper fuer RevenueCat + lokalen Trial-State.
///
/// Dualer Ansatz:
/// - Trial laeuft offline via `trialStartDate` in AppSettings
/// - RevenueCat ist Source-of-Truth fuer echte Kaeufe
/// - Graceful Degradation ohne Netzwerk
class SubscriptionService {
  final AppSettingsNotifier _settingsNotifier;
  bool _initialized = false;

  SubscriptionService(this._settingsNotifier);

  /// RevenueCat initialisieren. Muss einmal beim App-Start aufgerufen werden.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final apiKey = Platform.isIOS
          ? SubscriptionConstants.revenueCatApiKeyIos
          : SubscriptionConstants.revenueCatApiKeyAndroid;

      await Purchases.configure(PurchasesConfiguration(apiKey));
      _initialized = true;
    } catch (e) {
      // RevenueCat nicht verfuegbar (z.B. Emulator ohne Play Services).
      // App funktioniert trotzdem — Trial laeuft offline.
      debugPrint('RevenueCat init failed: $e');
    }
  }

  /// Aktuellen Abo-Status ermitteln.
  ///
  /// Prueft zuerst RevenueCat (echte Kaeufe), dann lokalen Trial-State.
  Future<SubscriptionStatus> getStatus() async {
    // 1. RevenueCat pruefen (wenn verfuegbar)
    if (_initialized) {
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        final entitlement =
            customerInfo.entitlements.all[SubscriptionConstants.premiumEntitlement];

        if (entitlement != null && entitlement.isActive) {
          return const SubscriptionStatus(tier: SubscriptionTier.premium);
        }
      } catch (e) {
        debugPrint('RevenueCat getCustomerInfo failed: $e');
      }
    }

    // 2. Lokalen Trial pruefen
    final trialStart = _settingsNotifier.state.trialStartDate;
    if (trialStart != null) {
      final daysElapsed = DateTime.now().difference(trialStart).inDays;
      final daysRemaining =
          SubscriptionConstants.trialDurationDays - daysElapsed;

      if (daysRemaining > 0) {
        return SubscriptionStatus(
          tier: SubscriptionTier.trial,
          trialDaysRemaining: daysRemaining,
        );
      }
    }

    // 3. Free-Tier
    return SubscriptionStatus.free;
  }

  /// Trial starten (wird beim Onboarding aufgerufen).
  Future<void> startTrial() async {
    await _settingsNotifier.startTrial();
  }

  /// Ob der Trial noch aktiv ist.
  bool isTrialActive() {
    final trialStart = _settingsNotifier.state.trialStartDate;
    if (trialStart == null) return false;

    final daysElapsed = DateTime.now().difference(trialStart).inDays;
    return daysElapsed < SubscriptionConstants.trialDurationDays;
  }

  /// Verfuegbare Angebote von RevenueCat laden.
  Future<Offerings?> getOfferings() async {
    if (!_initialized) return null;

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return null;
    }
  }

  /// Kauf eines Pakets durchfuehren.
  Future<bool> purchasePackage(Package package) async {
    if (!_initialized) return false;

    try {
      final result = await Purchases.purchasePackage(package);
      final entitlement =
          result.entitlements.all[SubscriptionConstants.premiumEntitlement];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  /// Kaeufe wiederherstellen (z.B. nach Geraetewechsel).
  Future<bool> restorePurchases() async {
    if (!_initialized) return false;

    try {
      final customerInfo = await Purchases.restorePurchases();
      final entitlement =
          customerInfo.entitlements.all[SubscriptionConstants.premiumEntitlement];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }
}
