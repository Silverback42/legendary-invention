import 'package:flutter/material.dart';

/// Maps stored icon names (Material Symbol names) to [IconData].
///
/// Seed-data icons use snake_case names such as 'shopping_cart',
/// matching the Material Icons constant naming convention.
IconData categoryIconData(String iconName) {
  return allCategoryIcons[iconName] ?? Icons.circle_outlined;
}

/// Full icon map exposed for the icon picker and template system.
const Map<String, IconData> allCategoryIcons = {
  // Default category icons
  'shopping_cart': Icons.shopping_cart,
  'home': Icons.home,
  'directions_car': Icons.directions_car,
  'sports_soccer': Icons.sports_soccer,
  'favorite': Icons.favorite,
  'local_mall': Icons.local_mall,
  'restaurant': Icons.restaurant,
  'more_horiz': Icons.more_horiz,

  // Template-specific icons
  'school': Icons.school,
  'savings': Icons.savings,
  'child_care': Icons.child_care,
  'shield': Icons.shield,
  'beach_access': Icons.beach_access,
  'work': Icons.work,
  'family_restroom': Icons.family_restroom,
  'person': Icons.person,

  // Extended icon set for icon picker
  'fitness_center': Icons.fitness_center,
  'local_bar': Icons.local_bar,
  'coffee': Icons.coffee,
  'phone_android': Icons.phone_android,
  'wifi': Icons.wifi,
  'movie': Icons.movie,
  'music_note': Icons.music_note,
  'book': Icons.book,
  'checkroom': Icons.checkroom,
  'build': Icons.build,
  'card_giftcard': Icons.card_giftcard,
  'electric_bolt': Icons.electric_bolt,
  'water_drop': Icons.water_drop,
  'local_gas_station': Icons.local_gas_station,
  'local_pharmacy': Icons.local_pharmacy,
  'park': Icons.park,
  'flight': Icons.flight,
  'attach_money': Icons.attach_money,
  'volunteer_activism': Icons.volunteer_activism,
  'pets': Icons.pets,
  'local_cafe': Icons.local_cafe,
  'directions_bus': Icons.directions_bus,
  'train': Icons.train,
  'directions_bike': Icons.directions_bike,
  'smoking_rooms': Icons.smoking_rooms,
  'celebration': Icons.celebration,
  'cleaning_services': Icons.cleaning_services,
  'medical_services': Icons.medical_services,
  'spa': Icons.spa,
  'receipt_long': Icons.receipt_long,
  'account_balance': Icons.account_balance,
  'storefront': Icons.storefront,
  'theater_comedy': Icons.theater_comedy,
  'headphones': Icons.headphones,
  'camera_alt': Icons.camera_alt,
  'brush': Icons.brush,
  'child_friendly': Icons.child_friendly,
  'emoji_objects': Icons.emoji_objects,
};
