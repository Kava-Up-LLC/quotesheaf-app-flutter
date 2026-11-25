import 'dart:io';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/failure.dart';
import '../../../core/services/appambit_cms.dart';
import '../../../core/services/analytics.dart';
import '../../../core/services/data_version.dart';
import '../../../core/services/email_composer.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/sms_composer.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/money.dart';
import '../../business/data/models/business_profile.dart';
import '../../business/data/repositories/business_repository.dart';
import '../data/models/quote.dart';
import '../data/models/sent_via.dart';
import '../data/repositories/quote_repository.dart';

part 'quote_preview_viewmodel.g.dart';

class QuotePreviewState {
  const QuotePreviewState({
    required this.quote,
    required this.pdf,
    required this.file,
    required this.profile,
    required this.deviceCanMail,
    this.sending,
  });

  final Quote quote;

  /// Exactly the bytes that will be attached.
  final Uint8List pdf;
  final File file;

  /// Current CMS profile: message templates.
  final BusinessProfile profile;
  final bool deviceCanMail;

  /// Channel whose composer is opening.
  final SentVia? sending;

  String? get _email => quote.customer?.email ?? quote.customerEmail;

  bool get canEmail => _email != null && deviceCanMail && sending == null;

  /// Why Email is disabled; null when it can be sent.
  String? get disabledReason => _email == null
      ? 'Add an email to this customer to send by Email'
      : !deviceCanMail
          ? 'Set up an email account on this device to send by Email'
          : null;

  /// `{{first_name}}`, `{{number}}`, `{{business}}`, `{{total}}`, `{{business_phone}}`.
  Map<String, String> get _values => {
        'first_name': Fmt.firstName(quote.customerName),
        'number': quote.number,
        'business': quote.business.name,
        'total': Money.format(quote.total),
        'business_phone': quote.business.phone ?? profile.phone ?? '',
      };

  String get emailSubject => Fmt.fillTemplate(profile.emailSubject ?? 'Quote {{number}}', _values);
  String get emailBody => Fmt.fillTemplate(profile.emailTemplate ?? profile.smsTemplate ?? '', _values);

  QuotePreviewState copyWith({SentVia? Function()? sending}) => QuotePreviewState(
        quote: quote,
        pdf: pdf,
        file: file,
        profile: profile,
        deviceCanMail: deviceCanMail,
        sending: sending != null ? sending() : this.sending,
      );
}

@riverpod
class QuotePreviewViewModel extends _$QuotePreviewViewModel {
  @override
  Future<QuotePreviewState> build(String quoteId) async {
    ref.watch(dataVersionProvider);
    final quote = await ref.read(quoteRepositoryProvider).byId(quoteId);
    if (quote == null) throw const Failure('This quote no longer exists.');
    final pdf = ref.read(pdfServiceProvider);
    final logo = quote.business.logo == null ? null : await ref.read(cmsServiceProvider).media(quote.business.logo!);
    final c = quote.customer;
    // Quotes saved before the CMS footer existed have none in their snapshot:
    // print the current "How to pay" from the CMS instead of the old approval note.
    final snap = quote.business;
    final hasFooter = (snap.footerTitle ?? '').isNotEmpty || snap.paymentMethods.isNotEmpty;
    final footer = hasFooter ? null : await ref.read(businessRepositoryProvider).footer();
    final bytes = await pdf.build(PdfQuote(
      businessName: quote.business.name,
      tradeLabel: quote.business.tradeLabel,
      businessPhone: quote.business.phone,
      businessEmail: quote.business.email,
      businessAddress: quote.business.address,
      licenseNo: quote.business.licenseNo,
      approvalNote: quote.business.approvalNote,
      footerTitle: footer?.title ?? snap.footerTitle,
      footerNote: (footer?.note ?? snap.footerNote)?.replaceAll('{{number}}', quote.number),
      paymentColumns: [
        for (final m in footer?.methods ?? snap.paymentMethods) (label: m.label, value: m.value),
      ],
      logo: logo,
      number: quote.number,
      issueDate: quote.issueDate,
      validUntil: quote.validUntil,
      validDays: quote.validDays,
      customerName: c?.name ?? quote.customerName,
      customerAddress: c?.address,
      customerPhone: switch (c?.phone ?? quote.customerPhone) { final p? => Fmt.phone(p), null => null },
      customerEmail: c?.email ?? quote.customerEmail,
      lines: [
        for (final l in quote.lines)
          PdfLine(
            name: l.name,
            description: l.description,
            quantity: l.quantity,
            unit: l.unit,
            unitPrice: l.unitPrice,
            amount: l.lineTotal,
          ),
      ],
      subtotal: quote.subtotal,
      taxLabel: '${quote.taxLabel} ${Money.formatRate(quote.taxRate)}%',
      taxAmount: quote.taxAmount,
      total: quote.total,
    ));
    final file = await pdf.saveToTemp(bytes, PdfService.fileName(quote.business.name, quote.number));
    final (profile, canMail) =
        await (ref.read(businessRepositoryProvider).profile(), ref.read(smsComposerProvider).canSendMail()).wait;
    return QuotePreviewState(
      quote: quote,
      pdf: bytes,
      file: file,
      profile: profile,
      deviceCanMail: canMail,
    );
  }

  /// Opens Mail with email, subject, body and PDF. flutter_email_sender does not
  /// report the outcome, so nothing is recorded.
  Future<void> sendByEmail() async {
    final s = state.value;
    if (s == null || !s.canEmail) return;
    _setSending(SentVia.email);
    try {
      await ref.read(emailComposerProvider).send(
            to: s.quote.customer?.email ?? s.quote.customerEmail!,
            subject: s.emailSubject,
            body: s.emailBody,
            attachment: s.file,
          );
      ref.read(analyticsServiceProvider).track('quote_email_opened', {'number': s.quote.number});
    } finally {
      _setSending(null);
    }
  }

  void _setSending(SentVia? via) {
    final s = state.value;
    if (s != null && ref.mounted) state = AsyncData(s.copyWith(sending: () => via));
  }
}
