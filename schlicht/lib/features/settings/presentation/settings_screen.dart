import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/database.dart';
import '../../../core/notifications/notification_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/subscription/subscription_provider.dart';
import '../../../core/subscription/subscription_status.dart';

/// Settings screen – Phase 1a.
///
/// Allows the user to configure:
/// - Currency (EUR / CHF)
/// - Language (DE / EN)
/// - Input mode (single transaction / monthly totals)
/// - Clear all data
/// - App version
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // --- Currency ---
          _SectionHeader(l10n.currency),
          RadioListTile<String>(
            title: Text(l10n.currencyEur),
            value: 'EUR',
            groupValue: settings.currency,
            onChanged: (v) => notifier.setCurrency(v!),
          ),
          RadioListTile<String>(
            title: Text(l10n.currencyChf),
            value: 'CHF',
            groupValue: settings.currency,
            onChanged: (v) => notifier.setCurrency(v!),
          ),
          const Divider(),

          // --- Language ---
          _SectionHeader(l10n.language),
          RadioListTile<String>(
            title: Text(l10n.languageDe),
            value: 'de',
            groupValue: settings.locale,
            onChanged: (v) => notifier.setLocale(v!),
          ),
          RadioListTile<String>(
            title: Text(l10n.languageEn),
            value: 'en',
            groupValue: settings.locale,
            onChanged: (v) => notifier.setLocale(v!),
          ),
          const Divider(),

          // --- Input mode ---
          _SectionHeader(l10n.inputMode),
          RadioListTile<String>(
            title: Text(l10n.inputModeSingle),
            value: 'single',
            groupValue: settings.inputMode,
            onChanged: (v) => notifier.setInputMode(v!),
          ),
          RadioListTile<String>(
            title: Text(l10n.inputModeMonthly),
            value: 'monthly',
            groupValue: settings.inputMode,
            onChanged: (v) => notifier.setInputMode(v!),
          ),
          const Divider(),

          // --- Categories ---
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l10n.manageCategories),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.categories),
          ),
          const Divider(),

          // --- Subscription ---
          _SectionHeader(l10n.subscriptionTitle),
          _SubscriptionTile(),
          const Divider(),

          // --- Notifications ---
          _SectionHeader(l10n.notificationsTitle),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.weeklyDigestToggle),
            subtitle: Text(l10n.weeklyDigestSubtitle),
            value: settings.weeklyDigestEnabled,
            onChanged: (enabled) async {
              if (enabled) {
                final granted = await NotificationService.requestPermission();
                if (!granted) return;
              }
              await notifier.setWeeklyDigestEnabled(enabled);
              final db = ref.read(databaseProvider);
              await syncDigestSchedule(
                settings: ref.read(appSettingsProvider),
                db: db,
              );
            },
          ),
          const Divider(),

          // --- Clear data ---
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.clearAllData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _confirmClearData(context, ref, l10n),
          ),
          const Divider(),

          // --- App version ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appVersion),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.clearAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dataCleared)),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Abo-Status und Aktionen in den Settings.
class _SubscriptionTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusAsync = ref.watch(subscriptionStatusProvider);

    return statusAsync.when(
      loading: () => const ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('…'),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        final String statusLabel;
        final IconData statusIcon;

        switch (status.tier) {
          case SubscriptionTier.premium:
            statusLabel = l10n.premiumLabel;
            statusIcon = Icons.star;
          case SubscriptionTier.trial:
            statusLabel = l10n.trialDaysRemaining(status.trialDaysRemaining);
            statusIcon = Icons.hourglass_top;
          case SubscriptionTier.free:
            statusLabel = l10n.freeLabel;
            statusIcon = Icons.lock_outline;
        }

        return Column(
          children: [
            ListTile(
              leading: Icon(statusIcon),
              title: Text(statusLabel),
            ),
            if (status.tier == SubscriptionTier.free) ...[
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(l10n.unlockPremium),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.paywall),
              ),
            ],
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l10n.restorePurchases),
              onTap: () async {
                final service = ref.read(subscriptionServiceProvider);
                final success = await service.restorePurchases();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? l10n.premiumLabel : l10n.restoreNoPurchases,
                      ),
                    ),
                  );
                  if (success) ref.invalidate(subscriptionStatusProvider);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
