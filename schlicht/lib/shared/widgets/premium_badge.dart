import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/subscription/subscription_provider.dart';
import '../../core/subscription/subscription_status.dart';
import '../../l10n/generated/app_localizations.dart';

/// Badge das den Premium-/Trial-/Free-Status anzeigt.
///
/// - Premium: gruener Chip "Premium"
/// - Trial: oranger Chip "Trial: X Tage"
/// - Free: Lock-Icon
class PremiumBadge extends ConsumerWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final l10n = AppLocalizations.of(context)!;

    return statusAsync.when(
      data: (status) => _buildBadge(context, status, l10n),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    SubscriptionStatus status,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    switch (status.tier) {
      case SubscriptionTier.premium:
        return Chip(
          label: Text(
            l10n.premiumLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: theme.colorScheme.secondary,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide.none,
        );

      case SubscriptionTier.trial:
        return Chip(
          label: Text(
            l10n.trialDaysRemaining(status.trialDaysRemaining),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.orange.withOpacity(0.15),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide.none,
        );

      case SubscriptionTier.free:
        return Icon(
          Icons.lock_outline,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        );
    }
  }
}
