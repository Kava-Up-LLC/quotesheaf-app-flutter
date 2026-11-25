import 'dart:convert';

import '../../../business/data/models/quote_footer.dart';

/// CMS business fields copied into `quotes.business_snapshot` at save time,
/// so a saved quote never changes if the profile is edited later.
class BusinessSnapshot {
  const BusinessSnapshot({
    required this.name,
    this.tradeLabel,
    this.logo,
    this.licenseNo,
    this.phone,
    this.email,
    this.address,
    this.approvalNote,
    this.footerTitle,
    this.footerNote,
    this.paymentMethods = const [],
  });

  final String name;
  final String? tradeLabel;
  final String? logo;
  final String? licenseNo;
  final String? phone;
  final String? email;
  final String? address;
  final String? approvalNote;

  /// PDF footer ("How to pay") — see [QuoteFooter]. Older quotes fall back to [approvalNote].
  final String? footerTitle;
  final String? footerNote;
  final List<PaymentMethod> paymentMethods;

  Map<String, dynamic> toJson() => {
        'name': name,
        'trade_label': tradeLabel,
        'logo': logo,
        'license_no': licenseNo,
        'phone': phone,
        'email': email,
        'address': address,
        'approval_note': approvalNote,
        'footer_title': footerTitle,
        'footer_note': footerNote,
        'payment_methods': [for (final m in paymentMethods) m.toJson()],
      };

  String encode() => jsonEncode(toJson());

  factory BusinessSnapshot.decode(Object? raw) {
    Map<String, dynamic> j;
    try {
      j = raw is String ? (jsonDecode(raw) as Map).cast<String, dynamic>() : const {};
    } catch (_) {
      j = const {};
    }
    String? s(String k) => j[k] == null ? null : '${j[k]}';
    return BusinessSnapshot(
      name: s('name') ?? '',
      tradeLabel: s('trade_label'),
      logo: s('logo'),
      licenseNo: s('license_no'),
      phone: s('phone'),
      email: s('email'),
      address: s('address'),
      approvalNote: s('approval_note'),
      footerTitle: s('footer_title'),
      footerNote: s('footer_note'),
      paymentMethods: [
        for (final m in (j['payment_methods'] as List? ?? const []))
          if (m is Map) ?PaymentMethod.fromJson(m.cast<String, dynamic>()),
      ],
    );
  }
}
