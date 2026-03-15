import 'package:drift/drift.dart';

/// Database tables for Schlicht.
/// Schema v1 – Phase 0.

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get code => text().withDefault(const Constant(''))(); // stable slug, e.g. 'groceries'
  TextColumn get icon => text().withLength(min: 1, max: 50)();  // icon name / code point
  IntColumn get colorValue => integer()();                       // ARGB int
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();                             // in user's currency
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// null = single transaction, non-null = recurring series id
  IntColumn get recurringId => integer().nullable()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real().customConstraint('NOT NULL CHECK (amount >= 0)')();
  IntColumn get month => integer().customConstraint('NOT NULL CHECK (month BETWEEN 1 AND 12)')();   // 1–12
  IntColumn get year => integer().customConstraint('NOT NULL CHECK (year >= 0)')();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoryId, month, year},
      ];
}

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text().withDefault(const Constant('checking'))();  // checking | credit | cash | savings
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}
