import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'tables.dart';

/// 8 default categories as specified in the PRD.
/// Icons use Material Symbols codepoints (as strings) – mapped in the UI layer.
const List<CategoriesCompanion> defaultCategories = [
  CategoriesCompanion(
    name: Value('Lebensmittel'),
    icon: Value('shopping_cart'),
    colorValue: Value(0xFF4CAF82),  // green
    sortOrder: Value(0),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Wohnen'),
    icon: Value('home'),
    colorValue: Value(0xFF5C6BC0),  // indigo
    sortOrder: Value(1),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Transport'),
    icon: Value('directions_car'),
    colorValue: Value(0xFF26A69A),  // teal
    sortOrder: Value(2),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Freizeit'),
    icon: Value('sports_soccer'),
    colorValue: Value(0xFFAB47BC),  // purple
    sortOrder: Value(3),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Gesundheit'),
    icon: Value('favorite'),
    colorValue: Value(0xFFEF5350),  // red
    sortOrder: Value(4),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Shopping'),
    icon: Value('local_mall'),
    colorValue: Value(0xFFFF7043),  // deep orange
    sortOrder: Value(5),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Essen gehen'),
    icon: Value('restaurant'),
    colorValue: Value(0xFFFFB300),  // amber
    sortOrder: Value(6),
    isDefault: Value(true),
  ),
  CategoriesCompanion(
    name: Value('Sonstiges'),
    icon: Value('more_horiz'),
    colorValue: Value(0xFF78909C),  // blue-grey
    sortOrder: Value(7),
    isDefault: Value(true),
  ),
];
