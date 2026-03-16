import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Predefined color palette for categories.
const List<int> categoryColors = [
  0xFF4CAF82, // green
  0xFF5C6BC0, // indigo
  0xFF26A69A, // teal
  0xFFAB47BC, // purple
  0xFFEF5350, // red
  0xFFFF7043, // deep orange
  0xFFFFB300, // amber
  0xFF78909C, // blue-grey
  0xFF42A5F5, // blue
  0xFF66BB6A, // light green
  0xFFEC407A, // pink
  0xFF29B6F6, // light blue
  0xFF7E57C2, // deep purple
  0xFF8D6E63, // brown
  0xFFD4E157, // lime
  0xFF26C6DA, // cyan
];

/// Shows a bottom sheet for picking a category color.
/// Returns the ARGB int value, or null if cancelled.
Future<int?> showColorPicker(BuildContext context, {int? current}) {
  return showModalBottomSheet<int>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _ColorPickerSheet(current: current),
  );
}

class _ColorPickerSheet extends StatelessWidget {
  final int? current;
  const _ColorPickerSheet({this.current});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.chooseColor, style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categoryColors.map((colorValue) {
              final isSelected = colorValue == current;
              return GestureDetector(
                onTap: () => Navigator.pop(context, colorValue),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(colorValue),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Color(colorValue).computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
