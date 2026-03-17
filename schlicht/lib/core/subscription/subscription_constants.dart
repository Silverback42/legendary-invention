/// RevenueCat Konfiguration fuer Schlicht.
///
/// TODO: API-Keys nach Erstellung des RevenueCat-Projekts eintragen.
abstract class SubscriptionConstants {
  // RevenueCat API-Keys
  static const String revenueCatApiKeyIos = 'appl_YOUR_IOS_API_KEY';
  static const String revenueCatApiKeyAndroid = 'goog_YOUR_ANDROID_API_KEY';

  // Entitlement-ID (muss in RevenueCat Dashboard identisch sein)
  static const String premiumEntitlement = 'premium';

  // Produkt-IDs (muessen in App Store Connect / Google Play Console identisch sein)
  static const String monthlyProductId = 'schlicht_premium_monthly';
  static const String yearlyProductId = 'schlicht_premium_yearly';

  // Trial-Dauer in Tagen
  static const int trialDurationDays = 14;
}
