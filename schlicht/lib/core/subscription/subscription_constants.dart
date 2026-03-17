/// RevenueCat Konfiguration fuer Schlicht.
///
/// TODO: API-Keys nach Erstellung des RevenueCat-Projekts eintragen.
abstract class SubscriptionConstants {
  // RevenueCat API-Keys — via --dart-define oder direkt ersetzen.
  static const String revenueCatApiKeyIos =
      String.fromEnvironment('RC_IOS_KEY', defaultValue: 'appl_YOUR_IOS_API_KEY');
  static const String revenueCatApiKeyAndroid =
      String.fromEnvironment('RC_ANDROID_KEY', defaultValue: 'goog_YOUR_ANDROID_API_KEY');

  /// Prueft ob echte API-Keys konfiguriert sind.
  static bool get hasValidKeys =>
      !revenueCatApiKeyIos.contains('YOUR_') &&
      !revenueCatApiKeyAndroid.contains('YOUR_');

  // Entitlement-ID (muss in RevenueCat Dashboard identisch sein)
  static const String premiumEntitlement = 'premium';

  // Produkt-IDs (muessen in App Store Connect / Google Play Console identisch sein)
  static const String monthlyProductId = 'schlicht_premium_monthly';
  static const String yearlyProductId = 'schlicht_premium_yearly';

  // Trial-Dauer in Tagen
  static const int trialDurationDays = 14;
}
