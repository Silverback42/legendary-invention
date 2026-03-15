import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'seed_data.dart';

part 'database.g.dart';

/// Main Drift database. Offline-First source of truth.
@DriftDatabase(tables: [Categories, Transactions, Budgets, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(categories, categories.code);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Future<List<Category>> getAllCategories() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Stream<List<Category>> watchAllCategories() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).watch();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<bool> updateCategory(Category entry) =>
      update(categories).replace(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------------------

  Stream<List<Transaction>> watchTransactionsForMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startDate) &
              t.date.isSmallerThanValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<Transaction>> getTransactionsForMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startDate) &
              t.date.isSmallerThanValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateTransaction(Transaction entry) =>
      update(transactions).replace(entry);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  /// Returns total spending per category for a given month via a grouped SQL query.
  Future<Map<int, double>> getSpendingByCategory(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final catId = transactions.categoryId;
    final amt = transactions.amount;

    final query = selectOnly(transactions)
      ..addColumns([catId, amt.sum()])
      ..where(
        transactions.date.isBiggerOrEqualValue(startDate) &
        transactions.date.isSmallerThanValue(endDate),
      )
      ..groupBy([catId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(catId)!: (row.read(amt.sum()) ?? 0.0),
    };
  }

  // ---------------------------------------------------------------------------
  // Budgets
  // ---------------------------------------------------------------------------

  Stream<List<Budget>> watchBudgetsForMonth(int year, int month) =>
      (select(budgets)
            ..where((b) => b.year.equals(year) & b.month.equals(month)))
          .watch();

  /// Upserts a budget row while preserving the existing row's id on conflict.
  Future<int> insertBudget(BudgetsCompanion entry) async {
    final existing = await (select(budgets)
          ..where(
            (b) =>
                b.categoryId.equals(entry.categoryId.value) &
                b.month.equals(entry.month.value) &
                b.year.equals(entry.year.value),
          ))
        .getSingleOrNull();

    if (existing != null) {
      final updated = entry.copyWith(id: Value(existing.id));
      await update(budgets).replace(updated);
      return existing.id;
    }
    return into(budgets).insert(entry);
  }

  Future<int> deleteBudget(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Accounts
  // ---------------------------------------------------------------------------

  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();

  Future<int> insertAccount(AccountsCompanion entry) =>
      into(accounts).insert(entry);

  // ---------------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------------

  Future<void> seedDefaultCategories() async {
    final existing = await getAllCategories();
    if (existing.isNotEmpty) return;

    await transaction(() async {
      await batch((b) => b.insertAll(categories, defaultCategories));
    });
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  /// Clears all transactional and budget data.
  /// Deliberately preserves [categories] and [accounts] as they represent
  /// user configuration, not transactional records.
  Future<void> clearAllData() async {
    await delete(transactions).go();
    await delete(budgets).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'schlicht.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Provider for dependency injection
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
