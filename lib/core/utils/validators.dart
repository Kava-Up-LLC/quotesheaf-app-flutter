abstract final class Validators {
  static final _e164 = RegExp(r'^\+[1-9]\d{7,14}$');
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Strips spaces, dashes, dots and parentheses: "+1 808 555-0187" → "+18085550187".
  /// US numbers typed without a country code get +1: "(808) 555-0187" → "+18085550187".
  static String normalizePhone(String input) {
    final p = input.replaceAll(RegExp(r'[\s\-().]'), '');
    if (RegExp(r'^\d{10}$').hasMatch(p)) return '+1$p';
    if (RegExp(r'^1\d{10}$').hasMatch(p)) return '+$p';
    return p;
  }

  static bool isE164(String phone) => _e164.hasMatch(phone);

  static bool isEmail(String email) => _email.hasMatch(email.trim());
}
