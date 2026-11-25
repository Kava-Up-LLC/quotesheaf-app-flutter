import 'package:intl/intl.dart';

/// Money helpers. Amounts are always integer cents (PRD §9.2).
abstract final class Money {
  static final _usd = NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2);

  /// `line_total = round(unit_price × qty)`.
  static int lineTotal(int unitPriceCents, num quantity) => (unitPriceCents * quantity).round();

  /// `tax = round(taxable subtotal × rate)`; [ratePercent] is e.g. 4.5 for 4.5%.
  static int tax(int taxableSubtotalCents, double ratePercent) =>
      (taxableSubtotalCents * ratePercent / 100).round();

  static int fromDollars(num dollars) => (dollars * 100).round();

  static String format(int cents) => _usd.format(cents / 100);

  /// "$129" for whole dollars, "$129.50" otherwise — used in compact chips.
  static String formatShort(int cents) =>
      cents % 100 == 0 ? '\$${NumberFormat('#,##0', 'en_US').format(cents ~/ 100)}' : format(cents);

  /// 4.5 → "4.5", 4.0 → "4".
  static String formatRate(double ratePercent) =>
      ratePercent == ratePercent.roundToDouble() ? ratePercent.toStringAsFixed(0) : '$ratePercent';

  /// 1 → "1", 1.5 → "1.5".
  static String formatQty(num qty) => qty == qty.roundToDouble() ? qty.toStringAsFixed(0) : qty.toString();
}
