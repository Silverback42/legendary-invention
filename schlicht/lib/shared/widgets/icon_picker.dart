import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/category_icon.dart';

/// Shows a grid dialog for picking a category icon.
/// Returns the icon name string key, or null if cancelled.
Future<String?> showIconPicker(BuildContext context, {String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _IconPickerSheet(current: current),
  );
}

class _IconPickerSheet extends StatelessWidget {
  final String? current;
  const _IconPickerSheet({this.current});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entries = allCategoryIcons.entries.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.chooseIcon,
                style: theme.textTheme.titleMedium),
          ),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: entries.length,
              itemBuilder: (ctx, index) {
                final entry = entries[index];
                final isSelected = entry.key == current;
                return GestureDetector(
                  onTap: () => Navigator.pop(ctx, entry.key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.12)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary, width: 2)
                          : Border.all(color: theme.dividerColor),
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
