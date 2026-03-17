import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/subscription/subscription_constants.dart';
import '../../../core/subscription/subscription_provider.dart';

/// Fullscreen Paywall nach dem Onboarding.
///
/// Zeigt Feature-Vergleich (Free vs Premium), Preis-Karten,
/// Trial-CTA, Wiederherstellen-Link und Skip-Option.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offerings? _offerings;
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final service = ref.read(subscriptionServiceProvider);
      final offerings = await service.getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
          _loading = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _offerings = null;
          _loading = false;
        });
      }
    }
  }

  Future<void> _startTrial() async {
    setState(() => _purchasing = true);
    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.startTrial();
      ref.invalidate(subscriptionStatusProvider);
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _purchasing = true);
    try {
      final service = ref.read(subscriptionServiceProvider);
      final success = await service.purchasePackage(package);
      if (success && mounted) {
        ref.invalidate(subscriptionStatusProvider);
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      final service = ref.read(subscriptionServiceProvider);
      final success = await service.restorePurchases();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        if (success) {
          ref.invalidate(subscriptionStatusProvider);
          context.go(AppRoutes.dashboard);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.restoreNoPurchases)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _skip() => context.go(AppRoutes.dashboard);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const trialDays = SubscriptionConstants.trialDurationDays;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Header
              Text(
                l10n.paywallTitle,
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paywallSubtitle,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Feature-Vergleich
              Expanded(
                child: ListView(
                  children: [
                    _FeatureRow(
                      label: l10n.featureUnlimitedHistory,
                      freeValue: l10n.featureLimited,
                      premiumValue: l10n.featureUnlimited,
                    ),
                    _FeatureRow(
                      label: l10n.featureCategories,
                      freeValue: '8',
                      premiumValue: l10n.featureUnlimited,
                    ),
                    _FeatureRow(
                      label: l10n.featureHomeWidget,
                      freeValue: '–',
                      premiumValue: '✓',
                    ),
                    _FeatureRow(
                      label: l10n.featureWeeklyDigest,
                      freeValue: '–',
                      premiumValue: '✓',
                    ),
                    const SizedBox(height: 24),

                    // Preis-Karten (nur wenn Offerings geladen)
                    if (!_loading && _offerings?.current != null) ...[
                      for (final package
                          in _offerings!.current!.availablePackages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PriceCard(
                            package: package,
                            onTap: _purchasing ? null : () => _purchase(package),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // Trial-CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _purchasing ? null : _startTrial,
                  child: _purchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.trialStart(trialDays)),
                ),
              ),
              const SizedBox(height: 12),

              // Wiederherstellen + Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _purchasing ? null : _restore,
                    child: Text(l10n.restorePurchases),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _purchasing ? null : _skip,
                    child: Text(l10n.paywallSkip),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Hilfs-Widgets ---

class _FeatureRow extends StatelessWidget {
  final String label;
  final String freeValue;
  final String premiumValue;

  const _FeatureRow({
    required this.label,
    required this.freeValue,
    required this.premiumValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              freeValue,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              premiumValue,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Package package;
  final VoidCallback? onTap;

  const _PriceCard({required this.package, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = package.storeProduct;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Text(
                product.priceString,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
