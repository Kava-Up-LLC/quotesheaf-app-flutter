import '../../../../core/errors/failure.dart';

/// Contractor profile from the CMS `business_profile` content type (PRD §9.1).
class BusinessProfile {
  const BusinessProfile({
    required this.name,
    this.logoUrl,
    this.tradeLabel,
    this.licenseNo,
    this.address,
    this.phone,
    this.email,
    required this.taxLabel,
    required this.taxRate,
    this.taxName,
    required this.quotePrefix,
    required this.validDays,
    this.approvalNote,
    this.smsTemplate,
    this.emailSubject,
    this.emailTemplate,
  });

  final String name;
  final String? logoUrl;
  final String? tradeLabel;
  final String? licenseNo;
  final String? address;
  final String? phone;
  final String? email;
  final String taxLabel;

  /// Percent, e.g. 4.5 for 4.5%.
  final double taxRate;
  final String? taxName;
  final String quotePrefix;
  final int validDays;
  final String? approvalNote;
  final String? smsTemplate;
  final String? emailSubject;
  final String? emailTemplate;

  /// Short name for the header kicker: "Czanelle's Airconditioning…" → "Czanelle's".
  String get shortName => name.split(RegExp(r'\s+')).first;

  /// Throws [Failure] naming the required CMS fields that are empty — the app
  /// has no built-in business values (each contractor sets theirs in the CMS).
  factory BusinessProfile.fromJson(Map<String, dynamic> j) {
    String? s(String k) {
      final v = j[k];
      if (v == null) return null;
      final str = '$v'.trim();
      return str.isEmpty ? null : str;
    }

    num? n(String k) => switch (j[k]) { num v => v, String v => num.tryParse(v), _ => null };

    final missing = [
      for (final k in ['name', 'tax_label', 'quote_prefix']) if (s(k) == null) k,
      for (final k in ['tax_rate', 'valid_days']) if (n(k) == null) k,
    ];
    if (missing.isNotEmpty) {
      throw Failure('Complete your business profile in the AppAmbit CMS: ${missing.join(', ')}.');
    }

    final logo = j['logo'];
    return BusinessProfile(
      name: s('name')!,
      logoUrl: switch (logo) {
        String v when v.isNotEmpty => v,
        Map m => (m['url'] ?? m['original_url'])?.toString(),
        List l when l.isNotEmpty && l.first is Map => ((l.first as Map)['url'])?.toString(),
        _ => null,
      },
      tradeLabel: s('trade_label'),
      licenseNo: s('license_no'),
      address: s('address'),
      phone: s('phone'),
      email: s('email'),
      taxLabel: s('tax_label')!,
      taxRate: n('tax_rate')!.toDouble(),
      taxName: s('tax_name'),
      quotePrefix: s('quote_prefix')!,
      validDays: n('valid_days')!.toInt(),
      approvalNote: s('approval_note'),
      smsTemplate: s('sms_template'),
      emailSubject: s('email_subject'),
      emailTemplate: s('email_template'),
    );
  }
}
