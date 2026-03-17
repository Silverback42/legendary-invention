import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'seed_data.dart';

part 'database.g.dart';

/// Drift-Datenbank. Offline-First Datenquelle.
@DriftDatabase(tables: [Categories, Transactions, Budgets, Accounts, RecurringExpenses, Referrals])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

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
        if (from < 3) {
          await m.addColumn(transactions, transactions.receiptPath);
          await m.createTable(recurringExpenses);
          await m.createTable(referrals);
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

  /// Batch-updates [sortOrder] for all categories in the given ID order.
  Future<void> reorderCategories(List<int> orderedIds) {
    return transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(categories)..where((c) => c.id.equals(orderedIds[i])))
            .write(CategoriesCompanion(sortOrder: Value(i)));
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------------------

  Stream<List<Transaction>> watchTransactionsForMonth(int year, int month) {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startDate) &
              t.date.isSmallerThanValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<Transaction>> getTransactionsForMonth(int year, int month) {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);
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
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    final catId = transactions.categoryId;
    final total = transactions.amount.sum();

    final query = selectOnly(transactions)
      ..addColumns([catId, total])
      ..where(
        transactions.date.isBiggerOrEqualValue(startDate) &
        transactions.date.isSmallerThanValue(endDate),
      )
      ..groupBy([catId]);

    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(catId)!: (row.read(total) ?? 0.0),
    };
  }

  /// Returns total spending for a given month (sum of all transactions).
  Future<double> getTotalSpendingForMonth(int year, int month) async {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    final total = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([total])
      ..where(
        transactions.date.isBiggerOrEqualValue(startDate) &
        transactions.date.isSmallerThanValue(endDate),
      );

    final row = await query.getSingle();
    return row.read(total) ?? 0.0;
  }

  // ---------------------------------------------------------------------------
  // Budgets
  // ---------------------------------------------------------------------------

  Stream<List<Budget>> watchBudgetsForMonth(int year, int month) =>
      (select(budgets)
            ..where((b) => b.year.equals(year) & b.month.equals(month)))
          .watch();

  /// Upserts a budget row while preserving the existing row's id on conflict.
  /// The entire read-then-write is wrapped in a transaction to prevent races.
  Future<int> insertBudget(BudgetsCompanion entry) {
    return transaction(() async {
      final existing = await (select(budgets)
            ..where(
              (b) =>
                  b.categoryId.equals(entry.categoryId.value) &
                  b.month.equals(entry.month.value) &
                  b.year.equals(entry.year.value),
            ))
          .getSingleOrNull();

      if (existing != null) {
        final updated = BudgetsCompanion(
          id: Value(existing.id),
          categoryId: entry.categoryId,
          amount: entry.amount,
          month: entry.month,
          year: entry.year,
        );
        await update(budgets).replace(updated);
        return existing.id;
      }
      return into(budgets).insert(entry);
    });
  }

  Future<int> deleteBudget(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();

  /// Alle Budgets fuer einen Monat laden (nicht-Stream-Variante).
  Future<List<Budget>> getAllBudgets(int year, int month) =>
      (select(budgets)
            ..where((b) => b.year.equals(year) & b.month.equals(month)))
          .get();

  // ---------------------------------------------------------------------------
  // Transactions (Date Range)
  // ---------------------------------------------------------------------------

  /// Transaktionen in einem beliebigen Zeitraum laden.
  ///
  /// [start] muss vor [end] liegen.
  Future<List<Transaction>> getTransactionsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    if (!start.isBefore(end)) {
      throw ArgumentError('start ($start) muss vor end ($end) liegen');
    }
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

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
  // Wiederkehrende Ausgaben
  // ---------------------------------------------------------------------------

  Stream<List<RecurringExpense>> watchAllRecurringExpenses() =>
      (select(recurringExpenses)..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();

  Future<List<RecurringExpense>> getAllActiveRecurringExpenses() =>
      (select(recurringExpenses)..where((r) => r.isActive.equals(true))).get();

  Future<int> insertRecurringExpense(RecurringExpensesCompanion entry) =>
      into(recurringExpenses).insert(entry);

  Future<bool> updateRecurringExpense(RecurringExpense entry) =>
      update(recurringExpenses).replace(entry);

  Future<int> deleteRecurringExpense(int id) =>
      (delete(recurringExpenses)..where((r) => r.id.equals(id))).go();

  /// Generiert Transaktionen fuer alle faelligen Perioden wiederkehrender Ausgaben.
  /// Berechnet die Serie geplanter Daten zwischen letzter Generierung und jetzt.
  Future<int> generateDueRecurringTransactions() async {
    final activeExpenses = await getAllActiveRecurringExpenses();
    final now = DateTime.now();
    var generated = 0;

    for (final expense in activeExpenses) {
      final occurrences = _computeOccurrences(expense, now);
      if (occurrences.isEmpty) continue;

      await transaction(() async {
        for (final scheduledDate in occurrences) {
          await into(transactions).insert(TransactionsCompanion(
            amount: Value(expense.amount),
            categoryId: Value(expense.categoryId),
            note: Value(expense.note),
            date: Value(scheduledDate),
            recurringId: Value(expense.id),
          ));
          generated++;
        }

        await (update(recurringExpenses)..where((r) => r.id.equals(expense.id)))
            .write(RecurringExpensesCompanion(lastGeneratedAt: Value(occurrences.last)));
      });
    }
    return generated;
  }

  /// Berechnet alle faelligen Occurrence-Daten zwischen letzter Generierung und [now].
  List<DateTime> _computeOccurrences(RecurringExpense expense, DateTime now) {
    final occurrences = <DateTime>[];
    var cursor = expense.lastGeneratedAt ?? expense.createdAt;

    for (var i = 0; i < 365; i++) {
      final nextDue = _nextScheduledDate(expense, cursor);
      if (nextDue == null) break;
      if (now.isBefore(nextDue)) break;
      occurrences.add(nextDue);
      cursor = nextDue;
    }
    return occurrences;
  }

  /// Berechnet das naechste geplante Datum basierend auf [cursor].
  /// Clamped dayOfPeriod um Monatsüberlauf zu vermeiden.
  DateTime? _nextScheduledDate(RecurringExpense expense, DateTime cursor) {
    switch (expense.frequency) {
      case 'weekly':
        return cursor.add(const Duration(days: 7));
      case 'monthly':
        final targetYear = cursor.month == 12 ? cursor.year + 1 : cursor.year;
        final targetMonth = cursor.month == 12 ? 1 : cursor.month + 1;
        final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
        final day = min(expense.dayOfPeriod, lastDay);
        return DateTime(targetYear, targetMonth, day);
      case 'yearly':
        final targetYear = cursor.year + 1;
        final targetMonth = cursor.month;
        final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
        final day = min(expense.dayOfPeriod, lastDay);
        return DateTime(targetYear, targetMonth, day);
      default:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Referrals
  // ---------------------------------------------------------------------------

  Future<Referral?> getMyReferral() =>
      (select(referrals)..limit(1)).getSingleOrNull();

  Future<int> insertReferral(ReferralsCompanion entry) =>
      into(referrals).insert(entry);

  Future<void> incrementReferralCount(int id) async {
    await customUpdate(
      'UPDATE referrals SET successful_count = successful_count + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {referrals},
    );
  }

  // ---------------------------------------------------------------------------
  // Transaktionen – Alle laden (fuer CSV-Export)
  // ---------------------------------------------------------------------------

  /// Alle Transaktionen laden, optional gefiltert nach Zeitraum und Kategorie.
  Future<List<Transaction>> getFilteredTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
  }) {
    final query = select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)]);

    if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.date.isSmallerThanValue(endDate));
    }
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }

    return query.get();
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  /// Loescht alle transaktionalen Daten inkl. Kassenbon-Dateien.
  /// Bewahrt [categories] und [accounts] als Nutzer-Konfiguration.
  Future<void> clearAllData() async {
    // Kassenbon-Dateien von der Platte entfernen
    try {
      final dir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(p.join(dir.path, 'receipts'));
      if (await receiptsDir.exists()) {
        await receiptsDir.delete(recursive: true);
      }
    } catch (_) {
      // Fehler beim Dateibereinigung nicht propagieren
    }

    await delete(transactions).go();
    await delete(budgets).go();
    await delete(recurringExpenses).go();
    await delete(referrals).go();
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
