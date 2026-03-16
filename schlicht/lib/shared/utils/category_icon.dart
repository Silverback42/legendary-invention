import 'package:flutter/material.dart';

/// Maps stored icon names (Material Symbol names) to [IconData].
///
/// Seed-data icons use snake_case names such as 'shopping_cart',
/// matching the Material Icons constant naming convention.
IconData categoryIconData(String iconName) {
  return _iconMap[iconName] ?? Icons.circle_outlined;
}

const Map<String, IconData> _iconMap = {
  'shopping_cart': Icons.shopping_cart,
  'home': Icons.home,
  'directions_car': Icons.directions_car,
  'sports_soccer': Icons.sports_soccer,
  'favorite': Icons.favorite,
  'local_mall': Icons.local_mall,
  'restaurant': Icons.restaurant,
  'more_horiz': Icons.more_horiz,
};
