import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'tables.dart';

/// 8 default categories as specified in the PRD.
/// Icons are stored as Material Symbol names (e.g., 'shopping_cart') — mapped to codepoints in the UI layer.
const List<CategoriesCompanion> defaultCategories = [
  CategoriesCompanion(
    name: Value('Lebensmittel'),
    code: Value('groceries'),
    icon: Value('shopping_cart'),
    colorValue: Value(0xFF4CAF82),  // green
    sortOrder: Value(0),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Wohnen'),
    code: Value('housing'),
    icon: Value('home'),
    colorValue: Value(0xFF5C6BC0),  // indigo
    sortOrder: Value(1),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Transport'),
    code: Value('transport'),
    icon: Value('directions_car'),
    colorValue: Value(0xFF26A69A),  // teal
    sortOrder: Value(2),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Freizeit'),
    code: Value('leisure'),
    icon: Value('sports_soccer'),
    colorValue: Value(0xFFAB47BC),  // purple
    sortOrder: Value(3),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Gesundheit'),
    code: Value('health'),
    icon: Value('favorite'),
    colorValue: Value(0xFFEF5350),  // red
    sortOrder: Value(4),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Shopping'),
    code: Value('shopping'),
    icon: Value('local_mall'),
    colorValue: Value(0xFFFF7043),  // deep orange
    sortOrder: Value(5),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Essen gehen'),
    code: Value('dine_out'),
    icon: Value('restaurant'),
    colorValue: Value(0xFFFFB300),  // amber
    sortOrder: Value(6),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Sonstiges'),
    code: Value('other'),
    icon: Value('more_horiz'),
    colorValue: Value(0xFF78909C),  // blue-grey
    sortOrder: Value(7),
    isDefault: Value(true),
  ),
];
