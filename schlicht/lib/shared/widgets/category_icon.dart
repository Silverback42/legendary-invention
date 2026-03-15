import 'package:flutter/material.dart';

/// Maps a stored icon name to its [IconData].
/// Falls back to [Icons.label_outline] for unknown names.
IconData categoryIconData(String name) => _iconMap[name] ?? Icons.label_outline;

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

/// Circular avatar with a tinted background and the category's icon.
class CategoryIcon extends StatelessWidget {
  final String iconName;
  final int colorValue;
  final double size;

  const CategoryIcon({
    super.key,
    required this.iconName,
    required this.colorValue,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return CircleAvatar(
      radius: size * 0.75,
      backgroundColor: color.withOpacity(0.15),
      child: Icon(categoryIconData(iconName), color: color, size: size),
    );
  }
}
