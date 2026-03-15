/// Shared widgets used by both AddTransactionScreen and EditTransactionScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/db/database.dart';
import '../../../shared/utils/category_name.dart';
import '../../../shared/widgets/category_icon.dart';

// ---------------------------------------------------------------------------
// Category grid tile
// ---------------------------------------------------------------------------

class TransactionCategoryTile extends StatelessWidget {
  final Category cat;
  final bool selected;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const TransactionCategoryTile({
    super.key,
    required this.cat,
    required this.selected,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: selected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(cat.colorValue),
                      width: 2.5,
                    ),
                  )
                : null,
            padding: const EdgeInsets.all(3),
            child:
                CategoryIcon(iconName: cat.icon, colorValue: cat.colorValue),
          ),
          const SizedBox(height: 4),
          Text(
            categoryDisplayName(l10n, cat.code, cat.name),
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Number pad
// ---------------------------------------------------------------------------

class TransactionNumPad extends StatelessWidget {
  final void Function(String key) onKey;

  const TransactionNumPad({super.key, required this.onKey});

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _rows
            .map(
              (row) => Row(
                children: row
                    .map((key) => Expanded(
                          child: _NumKey(
                              label: key, onTap: () => onKey(key)),
                        ))
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Center(
          child: label == '⌫'
              ? const Icon(Icons.backspace_outlined, size: 22)
              : Text(label,
                  style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }
}
