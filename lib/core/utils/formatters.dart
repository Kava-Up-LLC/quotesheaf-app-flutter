import 'package:intl/intl.dart';

abstract final class Fmt {
  static final _short = DateFormat('MMM d', 'en_US');
  static final _long = DateFormat('MMM d, yyyy', 'en_US');
  static final _dateTime = DateFormat('MMM d, h:mm a', 'en_US');
  static final _iso = DateFormat('yyyy-MM-dd');

  /// "Sep 23"
  static String shortDate(DateTime d) => _short.format(d.toLocal());

  /// "Sep 23, 2026"
  static String longDate(DateTime d) => _long.format(d.toLocal());

  /// "Sep 23, 10:42 AM"
  static String dateTime(DateTime d) => _dateTime.format(d.toLocal());

  /// "2026-09-23" (DB date column).
  static String isoDate(DateTime d) => _iso.format(d);

  /// Quote number from counter value: 38 → "Q-0038".
  static String quoteNumber(String prefix, int value) => '$prefix${value.toString().padLeft(4, '0')}';

  /// "+18085550187" → "+1 808 555 0187" (US numbers only; others unchanged).
  static String phone(String e164) {
    final m = RegExp(r'^\+1(\d{3})(\d{3})(\d{4})$').firstMatch(e164);
    return m == null ? e164 : '+1 ${m[1]} ${m[2]} ${m[3]}';
  }

  static String firstName(String name) => name.trim().split(RegExp(r'\s+')).first;

  /// Replaces `{{key}}` placeholders in a CMS template.
  static String fillTemplate(String template, Map<String, String> values) =>
      template.replaceAllMapped(RegExp(r'\{\{\s*(\w+)\s*\}\}'), (m) => values[m[1]] ?? m[0]!);
}
