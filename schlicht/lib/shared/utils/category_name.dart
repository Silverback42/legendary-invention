import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Returns the localized display name for a category.
/// Uses [code] to look up the l10n string for built-in categories;
/// falls back to [storedName] for user-added categories.
String categoryDisplayName(
  AppLocalizations l10n,
  String code,
  String storedName,
) =>
    switch (code) {
      'groceries' => l10n.categoryGroceries,
      'housing'   => l10n.categoryHousing,
      'transport' => l10n.categoryTransport,
      'leisure'   => l10n.categoryLeisure,
      'health'    => l10n.categoryHealth,
      'shopping'  => l10n.categoryShopping,
      'dine_out'  => l10n.categoryDiningOut,
      'other'     => l10n.categoryOther,
      _           => storedName,
    };
