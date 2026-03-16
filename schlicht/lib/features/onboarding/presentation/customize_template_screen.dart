import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/database.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/utils/category_icon.dart';
import '../data/budget_templates.dart';

/// Onboarding screen 3/3: customize categories & budgets, then confirm.
class CustomizeTemplateScreen extends ConsumerStatefulWidget {
  final int situationIndex;

  const CustomizeTemplateScreen({super.key, required this.situationIndex});

  @override
  ConsumerState<CustomizeTemplateScreen> createState() =>
      _CustomizeTemplateScreenState();
}

class _CustomizeTemplateScreenState
    extends ConsumerState<CustomizeTemplateScreen> {
  late List<_EditableCategory> _categories;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final index = widget.situationIndex.clamp(0, LifeSituation.values.length - 1);
    final situation = LifeSituation.values[index];
    final template = budgetTemplates[situation] ??
        budgetTemplates[LifeSituation.individual]!;
    _categories = template.categories
        .map((c) => _EditableCategory.fromTemplate(c))
        .toList();
  }

  Future<void> _confirm() async {
    if (_categories.isEmpty || _saving) return;

    // Trim names and validate before starting the save
    for (final c in _categories) {
      c.name = c.name.trim();
    }
    if (_categories.any((c) => c.name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.categoryNameRequired),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    // Snapshot the list so async mutations can't affect the transaction
    final snapshot = List<_EditableCategory>.unmodifiable(_categories);
    final db = ref.read(databaseProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final now = DateTime.now();

    try {
      await db.transaction(() async {
        // Clear existing default categories (fresh install only — the seeded ones)
        final existing = await db.getAllCategories();
        for (final cat in existing) {
          if (cat.isDefault) await db.deleteCategory(cat.id);
        }

        // Insert template categories and budgets
        for (var i = 0; i < snapshot.length; i++) {
          final c = snapshot[i];
          final catId = await db.insertCategory(CategoriesCompanion(
            name: Value(c.name),
            code: Value(c.code),
            icon: Value(c.icon),
            colorValue: Value(c.colorValue),
            sortOrder: Value(i),
            isDefault: const Value(true),
          ));

          if (c.budget > 0) {
            await db.insertBudget(BudgetsCompanion(
              categoryId: Value(catId),
              amount: Value(c.budget),
              month: Value(now.month),
              year: Value(now.year),
            ));
          }
        }
      });

      await settingsNotifier.completeOnboarding();

      if (mounted) context.go(AppRoutes.dashboard);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.genericError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.customizeTitle,
                      style: theme.textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    l10n.customizeSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.removeCategoryHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return Dismissible(
                    key: ValueKey(cat.code + index.toString()),
                    direction: _saving
                        ? DismissDirection.none
                        : DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      if (_categories.length <= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .minOneCategoryRequired),
                          ),
                        );
                        return false;
                      }
                      setState(() => _categories.removeAt(index));
                      return false; // We already removed it from state
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                    ),
                    child: IgnorePointer(
                      ignoring: _saving,
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Category icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(cat.colorValue)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  categoryIconData(cat.icon),
                                  color: Color(cat.colorValue),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name (editable)
                              Expanded(
                                child: TextFormField(
                                  initialValue: cat.name,
                                  style: theme.textTheme.bodyLarge,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (v) => cat.name = v,
                                ),
                              ),

                              // Budget amount (editable)
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: cat.budget > 0
                                      ? cat.budget.toStringAsFixed(0)
                                      : '',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '0',
                                    suffixText: settings.currencySymbol,
                                    suffixStyle: theme.textTheme.bodySmall,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (v) =>
                                      cat.budget = double.tryParse(v) ?? 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: ElevatedButton(
                onPressed: _saving ? null : _confirm,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.onboardingGetStarted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mutable wrapper around a [TemplateCategory] for editing.
class _EditableCategory {
  String name;
  final String code;
  final String icon;
  final int colorValue;
  double budget;

  _EditableCategory({
    required this.name,
    required this.code,
    required this.icon,
    required this.colorValue,
    required this.budget,
  });

  factory _EditableCategory.fromTemplate(TemplateCategory t) {
    return _EditableCategory(
      name: t.name,
      code: t.code,
      icon: t.icon,
      colorValue: t.colorValue,
      budget: t.suggestedBudget,
    );
  }
}
