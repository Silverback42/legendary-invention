import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show DateTime;

import '../db/database.dart';

// ---------------------------------------------------------------------------
// Categories
// ---------------------------------------------------------------------------

final allCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(databaseProvider).watchAllCategories();
});

// ---------------------------------------------------------------------------
// Currently viewed month (shared between Dashboard and Transactions screens)
// ---------------------------------------------------------------------------

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// ---------------------------------------------------------------------------
// Transactions for selected month
// ---------------------------------------------------------------------------

final transactionsForMonthProvider = StreamProvider<List<Transaction>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(databaseProvider)
      .watchTransactionsForMonth(month.year, month.month);
});

// ---------------------------------------------------------------------------
// Budgets for selected month
// ---------------------------------------------------------------------------

final budgetsForMonthProvider = StreamProvider<List<Budget>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(databaseProvider)
      .watchBudgetsForMonth(month.year, month.month);
});

// ---------------------------------------------------------------------------
// Total spending for selected month (derived, reactive)
// ---------------------------------------------------------------------------

final totalSpendingProvider = Provider<double>((ref) {
  return ref.watch(transactionsForMonthProvider).whenOrNull(
        data: (txs) => txs.fold(0.0, (sum, t) => sum + t.amount),
      ) ??
      0.0;
});
