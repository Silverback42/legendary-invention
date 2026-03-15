import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers/settings_provider.dart';

// App version – updated here when pubspec version changes.
const _kAppVersion = '0.1.0+1';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          // ── Currency ────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.euro_outlined),
            title: Text(l10n.currency),
            trailing: Text(settings.currency,
                style: Theme.of(context).textTheme.bodyMedium),
            onTap: () => _pickCurrency(context, ref, l10n, settings.currency),
          ),

          // ── Language ────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            trailing: Text(
              settings.locale?.languageCode == 'en'
                  ? l10n.languageEn
                  : l10n.languageDe,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () => _pickLanguage(context, ref, l10n, settings.locale),
          ),

          const Divider(),

          // ── Input mode ──────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.input_outlined),
            title: Text(l10n.inputMode),
            trailing: Text(
              settings.inputMode == InputMode.monthly
                  ? l10n.inputModeMonthly
                  : l10n.inputModeSingle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () => _pickInputMode(context, ref, l10n, settings.inputMode),
          ),

          const Divider(),

          // ── Clear data ──────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined,
                color: Colors.red),
            title: Text(l10n.clearAllData,
                style: const TextStyle(color: Colors.red)),
            onTap: () => _confirmClearData(context, ref, l10n),
          ),

          const Divider(),

          // ── App version ─────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appVersion),
            trailing: Text(_kAppVersion,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  // ── Pickers ────────────────────────────────────────────────────────────

  Future<void> _pickCurrency(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String current,
  ) async {
    final options = [
      (code: 'EUR', label: l10n.currencyEur),
      (code: 'CHF', label: l10n.currencyChf),
    ];
    final picked = await _showOptionSheet<String>(
      context: context,
      title: l10n.currency,
      options: [
        for (final o in options)
          _SheetOption(
            value: o.code,
            label: o.label,
            selected: o.code == current,
          ),
      ],
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setCurrency(picked);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale? current,
  ) async {
    final options = [
      (code: 'de', label: l10n.languageDe),
      (code: 'en', label: l10n.languageEn),
    ];
    final picked = await _showOptionSheet<String>(
      context: context,
      title: l10n.language,
      options: [
        for (final o in options)
          _SheetOption(
            value: o.code,
            label: o.label,
            selected: current?.languageCode == o.code,
          ),
      ],
    );
    if (picked != null && context.mounted) {
      await ref
          .read(settingsProvider.notifier)
          .setLocale(Locale(picked));
    }
  }

  Future<void> _pickInputMode(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    InputMode current,
  ) async {
    final picked = await _showOptionSheet<InputMode>(
      context: context,
      title: l10n.inputMode,
      options: [
        _SheetOption(
          value: InputMode.single,
          label: l10n.inputModeSingle,
          selected: current == InputMode.single,
        ),
        _SheetOption(
          value: InputMode.monthly,
          label: l10n.inputModeMonthly,
          selected: current == InputMode.monthly,
        ),
      ],
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setInputMode(picked);
    }
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
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(databaseProvider).clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓')),
        );
      }
    }
  }

  /// Generic bottom-sheet option picker.
  Future<T?> _showOptionSheet<T>({
    required BuildContext context,
    required String title,
    required List<_SheetOption<T>> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(title,
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
              ...options.map(
                (o) => ListTile(
                  title: Text(o.label),
                  trailing: o.selected
                      ? const Icon(Icons.check, size: 20)
                      : null,
                  onTap: () => Navigator.pop(ctx, o.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOption<T> {
  final T value;
  final String label;
  final bool selected;

  const _SheetOption(
      {required this.value, required this.label, required this.selected});
}
