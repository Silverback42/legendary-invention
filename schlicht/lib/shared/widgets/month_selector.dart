import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Wiederverwendbarer Monatswähler mit Vor-/Zurück-Navigation.
class MonthSelector extends StatelessWidget {
  final int year;
  final int month;
  final String locale;
  final AppLocalizations l10n;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoBack;
  final bool canGoForward;

  const MonthSelector({
    required this.year, required this.month, required this.locale, required this.l10n, required this.onPrevious, required this.onNext, super.key,
    this.canGoBack = true,
    this.canGoForward = true,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        DateFormat.yMMMM(locale).format(DateTime(year, month));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.monthPrevious,
            onPressed: canGoBack ? onPrevious : null,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.monthNext,
            onPressed: canGoForward ? onNext : null,
          ),
        ],
      ),
    );
  }
}
