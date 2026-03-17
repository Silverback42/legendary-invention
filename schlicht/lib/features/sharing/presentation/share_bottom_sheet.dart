import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../../../shared/widgets/category_donut_chart.dart';
import '../services/share_image_service.dart';
import 'share_image_widget.dart';

/// BottomSheet fuer Format-Auswahl und Teilen der Monatsuebersicht.
class ShareBottomSheet extends StatefulWidget {
  final ShareData data;

  const ShareBottomSheet({required this.data, super.key});

  /// Zeigt das Share-BottomSheet an.
  static Future<void> show(BuildContext context, ShareData data) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareBottomSheet(data: data),
    );
  }

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  ShareFormat _format = ShareFormat.story;
  bool _isGenerating = false;

  Future<void> _share() async {
    setState(() => _isGenerating = true);

    try {
      final imageWidget = ShareImageWidget(
        data: widget.data,
        format: _format,
      );

      final file = _format == ShareFormat.story
          ? await ShareImageService.generateStoryImage(imageWidget)
          : await ShareImageService.generateSquareImage(imageWidget);

      await ShareImageService.shareImage(file);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag-Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Titel
          Text(
            l10n.shareChooseFormat,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          // Format-Auswahl
          Row(
            children: [
              Expanded(
                child: _FormatOption(
                  label: l10n.shareFormatStory,
                  subtitle: '9:16',
                  icon: Icons.smartphone,
                  isSelected: _format == ShareFormat.story,
                  onTap: () => setState(() => _format = ShareFormat.story),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormatOption(
                  label: l10n.shareFormatSquare,
                  subtitle: '1:1',
                  icon: Icons.crop_square,
                  isSelected: _format == ShareFormat.square,
                  onTap: () => setState(() => _format = ShareFormat.square),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Vorschau
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: FittedBox(
              child: SizedBox(
                width: _format == ShareFormat.story ? 1080 : 1080,
                height: _format == ShareFormat.story ? 1920 : 1080,
                child: ShareImageWidget(
                  data: widget.data,
                  format: _format,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Teilen-Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _share,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share),
              label: Text(
                _isGenerating ? l10n.shareGenerating : l10n.shareButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Einzelne Format-Option (Story oder Quadratisch).
class _FormatOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: isSelected ? primary.withOpacity(0.08) : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? primary : theme.colorScheme.onSurface,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
