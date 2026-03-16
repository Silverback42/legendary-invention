import 'package:intl/intl.dart';

/// Formats an amount as a currency string.
/// Uses locale-aware formatting with the specified symbol.
String formatCurrency(double amount, {String symbol = '€', String locale = 'de_DE'}) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

/// Formats an amount without the currency symbol (e.g. "12,50").
String formatAmount(double amount, {String locale = 'de_DE'}) {
  final formatter = NumberFormat('#,##0.00', locale);
  return formatter.format(amount);
}
