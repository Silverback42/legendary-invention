import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../shared/utils/category_icon.dart';
import '../../../shared/widgets/color_picker.dart';
import '../../../shared/widgets/icon_picker.dart';

/// Category management screen: rename, reorder, add, delete.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  static const int _freeTierLimit = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle),
        actions: [
          StreamBuilder<List<Category>>(
            stream: db.watchAllCategories(),
            builder: (context, snap) {
              final categories = snap.data;
              final canAdd =
                  categories != null && categories.length < _freeTierLimit;
              return IconButton(
                icon: const Icon(Icons.add),
                tooltip: l10n.addCategory,
                onPressed: canAdd ? () => _addCategory(db) : null,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: db.watchAllCategories(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.genericError),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final categories = snap.data;
          if (categories == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categories.isEmpty) {
            return Center(child: Text(l10n.noCategoriesYet));
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) =>
                _onReorder(db, categories, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _CategoryTile(
                key: ValueKey(cat.id),
                index: index,
                category: cat,
                onEdit: () => _editCategory(db, cat),
                onDelete:
                    cat.isDefault ? null : () => _deleteCategory(db, cat),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onReorder(
    AppDatabase db,
    List<Category> categories,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final list = List<Category>.from(categories);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await db.reorderCategories(list.map((c) => c.id).toList());
  }

  Future<void> _addCategory(AppDatabase db) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await _showCategoryEditor(
      context: context,
      title: l10n.addCategory,
    );
    if (result == null) return;

    final categories = await db.getAllCategories();
    if (categories.length >= _freeTierLimit) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryLimitReached)),
        );
      }
      return;
    }
    final maxSort = categories.isEmpty
        ? 0
        : categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    await db.insertCategory(CategoriesCompanion(
      name: Value(result.name),
      code: Value(result.name.toLowerCase().replaceAll(' ', '_')),
      icon: Value(result.icon),
      colorValue: Value(result.colorValue),
      sortOrder: Value(maxSort),
      isDefault: const Value(false),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categorySaved)),
      );
    }
  }

  Future<void> _editCategory(AppDatabase db, Category cat) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await _showCategoryEditor(
      context: context,
      title: l10n.editCategory,
      initialName: cat.name,
      initialIcon: cat.icon,
      initialColor: cat.colorValue,
    );
    if (result == null) return;

    await db.updateCategory(cat.copyWith(
      name: result.name,
      icon: result.icon,
      colorValue: result.colorValue,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categorySaved)),
      );
    }
  }

  Future<void> _deleteCategory(AppDatabase db, Category cat) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteCategoryConfirm),
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
    if (confirmed != true) return;

    await db.deleteCategory(cat.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryDeleted)),
      );
    }
  }

  /// Shows a bottom sheet to edit/create a category.
  Future<_CategoryEditorResult?> _showCategoryEditor({
    required BuildContext context,
    required String title,
    String initialName = '',
    String initialIcon = 'more_horiz',
    int initialColor = 0xFF78909C,
  }) {
    return showModalBottomSheet<_CategoryEditorResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CategoryEditorSheet(
        title: title,
        initialName: initialName,
        initialIcon: initialIcon,
        initialColor: initialColor,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category tile
// ---------------------------------------------------------------------------

class _CategoryTile extends StatelessWidget {
  final int index;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _CategoryTile({
    required this.index,
    required this.category,
    required this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(category.colorValue);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          categoryIconData(category.icon),
          color: color,
          size: 20,
        ),
      ),
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: theme.colorScheme.error, size: 20),
              onPressed: onDelete,
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category editor bottom sheet
// ---------------------------------------------------------------------------

class _CategoryEditorSheet extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialIcon;
  final int initialColor;

  const _CategoryEditorSheet({
    required this.title,
    required this.initialName,
    required this.initialIcon,
    required this.initialColor,
  });

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _nameCtrl;
  late String _icon;
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _icon = widget.initialIcon;
    _colorValue = widget.initialColor;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      _CategoryEditorResult(name: name, icon: _icon, colorValue: _colorValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),

          // Name field
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l10n.categoryName),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Icon + Color row
          Row(
            children: [
              // Icon picker
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(categoryIconData(_icon),
                      color: Color(_colorValue)),
                  label: Text(l10n.chooseIcon),
                  onPressed: () async {
                    final picked =
                        await showIconPicker(context, current: _icon);
                    if (picked != null) setState(() => _icon = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Color picker
              Semantics(
                label: l10n.chooseColor,
                button: true,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    final picked =
                        await showColorPicker(context, current: _colorValue);
                    if (picked != null) setState(() => _colorValue = picked);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(_colorValue),
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.dividerColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save button (disabled when name is empty)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nameCtrl,
            builder: (context, value, _) {
              final hasName = value.text.trim().isNotEmpty;
              return ElevatedButton(
                onPressed: hasName ? _save : null,
                child: Text(l10n.save),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryEditorResult {
  final String name;
  final String icon;
  final int colorValue;

  const _CategoryEditorResult({
    required this.name,
    required this.icon,
    required this.colorValue,
  });
}
