/// Abo-Stufe des Users.
enum SubscriptionTier {
  /// Kostenlose Version mit eingeschraenktem Funktionsumfang.
  free,

  /// 14-Tage Trial mit vollem Funktionsumfang.
  trial,

  /// Bezahltes Premium-Abo.
  premium,
}

/// Aktueller Abo-Status des Users.
class SubscriptionStatus {
  final SubscriptionTier tier;

  /// Verbleibende Trial-Tage (nur relevant wenn tier == trial).
  final int trialDaysRemaining;

  const SubscriptionStatus({
    required this.tier,
    this.trialDaysRemaining = 0,
  });

  /// Ob der User Premium-Features nutzen darf (Trial oder bezahlt).
  bool get isPremium =>
      tier == SubscriptionTier.premium || tier == SubscriptionTier.trial;

  /// Standard: Free-Tier.
  static const free = SubscriptionStatus(tier: SubscriptionTier.free);
}
