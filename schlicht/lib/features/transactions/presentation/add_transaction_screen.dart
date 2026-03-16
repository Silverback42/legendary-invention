import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/utils/category_icon.dart';

/// Quick-Entry screen – Phase 1a.
///
/// Allows the user to add a transaction in ≤ 3 taps:
/// 1. Enter amount via numpad
/// 2. Select category
/// 3. Tap save
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  /// Raw digits entered (in cents). E.g. "1250" = 12,50 €.
  String _amountCents = '';
  int? _selectedCategoryId;
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  double get _amount {
    if (_amountCents.isEmpty) return 0;
    return int.parse(_amountCents) / 100;
  }

  String _displayAmount(AppSettings settings) {
    final formatted = NumberFormat('#,##0.00', settings.fullLocale).format(_amount);
    return '$formatted ${settings.currencySymbol}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumpadTap(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'backspace') {
        if (_amountCents.isNotEmpty) {
          _amountCents = _amountCents.substring(0, _amountCents.length - 1);
        }
      } else {
        // Limit to 9999999 (99.999,99 €)
        if (_amountCents.length < 7) {
          _amountCents += key;
        }
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;

    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationAmountPositive)),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationCategoryRequired)),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);
      await db.insertTransaction(TransactionsCompanion(
        amount: Value(_amount),
        categoryId: Value(_selectedCategoryId!),
        note: Value(_noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim()),
        date: Value(_selectedDate),
      ));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    }
  }

  String _formatDateLabel(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = DateTime(date.year, date.month, date.day);

    if (picked == today) return l10n.today;
    if (picked == today.subtract(const Duration(days: 1))) {
      return l10n.yesterday;
    }
    final settings = ref.read(appSettingsProvider);
    return DateFormat.yMMMd(settings.fullLocale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionAddTitle),
        actions: [
          TextButton(
            onPressed: (_saving || _amount <= 0 || _selectedCategoryId == null)
                ? null
                : _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Amount display ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _displayAmount(settings),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),

          // --- Category grid ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<List<Category>>(
              stream: db.watchAllCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return const SizedBox(height: 80);
                }
                return _CategoryGrid(
                  categories: categories,
                  selectedId: _selectedCategoryId,
                  onSelect: (id) =>
                      setState(() => _selectedCategoryId = id),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // --- Note field ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: l10n.note,
                prefixIcon: const Icon(Icons.notes, size: 20),
                isDense: true,
              ),
              textInputAction: TextInputAction.done,
              maxLength: 100,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            ),
          ),

          // --- Date selector ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _selectDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _formatDateLabel(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // --- Numpad ---
          _Numpad(onTap: _onNumpadTap),

          const SizedBox(height: 16),

          // --- Save button ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: ElevatedButton(
              onPressed: (_saving || _amount <= 0 || _selectedCategoryId == null)
                  ? null
                  : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category grid
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = cat.id == selectedId;
        final color = Color(cat.colorValue);

        return GestureDetector(
          onTap: () => onSelect(cat.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  categoryIconData(cat.icon),
                  color: color,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : null,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Custom numpad
// ---------------------------------------------------------------------------

class _Numpad extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _Numpad({required this.onTap});

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'backspace'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: _keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 72, height: 56);
              }
              return _NumpadKey(
                label: key,
                onTap: () => onTap(key),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == 'backspace';
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 56,
        child: Center(
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, size: 24)
              : Text(
                  label,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
        ),
      ),
    );
  }
}
