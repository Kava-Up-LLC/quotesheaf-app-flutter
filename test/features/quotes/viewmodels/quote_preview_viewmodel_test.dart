import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/core/services/analytics.dart';
import 'package:quote_generator_app/core/services/appambit_cms.dart';
import 'package:quote_generator_app/core/services/appambit_db.dart';
import 'package:quote_generator_app/core/services/email_composer.dart';
import 'package:quote_generator_app/core/services/pdf_service.dart';
import 'package:quote_generator_app/core/services/sms_composer.dart';
import 'package:quote_generator_app/features/quotes/viewmodels/quote_preview_viewmodel.dart';

import '../../../helpers/fakes.dart';

class _Sms implements SmsComposer {
  _Sms(this.result, {this.mail = true});
  final ComposeResult result;
  final bool mail;
  String? body;
  @override
  Future<bool> canSendText() async => true;
  @override
  Future<bool> canSendMail() async => mail;
  @override
  Future<ComposeResult> sendText({required String phone, required String body, required File attachment}) async {
    this.body = body;
    return result;
  }
}

class _Email implements EmailComposer {
  String? subject;
  @override
  Future<void> send({required String to, required String subject, required String body, required File attachment}) async =>
      this.subject = subject;
}

class _Pdf extends PdfService {
  PdfQuote? last;
  @override
  Future<Uint8List> build(PdfQuote q) async {
    last = q;
    return Uint8List.fromList([1, 2, 3]);
  }
  @override
  Future<File> saveToTemp(Uint8List bytes, String fileName) async => File(fileName);
}

class _Analytics implements AnalyticsService {
  @override
  void track(String event, [Map<String, String> properties = const {}]) {}
}

const _profile = {
  ...businessProfileJson,
  'sms_template': 'Hi {{first_name}}, quote {{number}} from {{business}} for {{total}}. Call {{business_phone}}.',
  'email_subject': 'Your quote {{number}}',
};

DbRow _quoteRow({String? phone = '+18085550187', String? email = 'leilani@example.com'}) => {
      'id': 'q1',
      'number': 'Q-0038',
      'customer_id': 'c1',
      'customer_name': 'Leilani Kahale',
      'customer_phone': phone,
      'customer_email': email,
      'issue_date': '2026-09-23',
      'valid_until': '2026-10-07',
      'business_snapshot': '{"name":"Czanelle\u0027s","phone":"(808) 555-0142"}',
      'tax_label': 'GET',
      'tax_rate': 4.5,
      'subtotal': 65050,
      'tax_amount': 2927,
      'total': 67977,
      'created_at': '2026-09-23T00:00:00Z',
      'updated_at': '2026-09-23T00:00:00Z',
    };

void main() {
  ProviderContainer make(FakeDbService db, SmsComposer sms, [EmailComposer? email, _Pdf? pdf]) =>
      ProviderContainer(overrides: [
        dbServiceProvider.overrideWithValue(db),
        cmsServiceProvider.overrideWithValue(FakeCmsService({
          'business_profile': [_profile],
          'quote_footer': [
            {'title': 'How to pay', 'note': 'Please include quote {{number}} with your payment.'},
          ],
          'payment_method': [
            {'label': 'Zelle', 'value': '(808) 555-0142', 'sort_order': 1},
          ],
        })),
        smsComposerProvider.overrideWithValue(sms),
        emailComposerProvider.overrideWithValue(email ?? _Email()),
        pdfServiceProvider.overrideWithValue(pdf ?? _Pdf()),
        analyticsServiceProvider.overrideWithValue(_Analytics()),
      ]);

  List<DbRow> Function(String, List<Object?>?) rows(DbRow quote) =>
      (sql, _) => sql.contains('FROM quotes q') ? [quote] : const [];

  test('PDF: validity in days, and old quotes get the current CMS "How to pay" footer', () async {
    final pdf = _Pdf();
    final c = make(FakeDbService(rows(_quoteRow())), _Sms(ComposeResult.sent), null, pdf);
    addTearDown(c.dispose);
    final p = quotePreviewViewModelProvider('q1');
    final sub = c.listen(p, (_, _) {});
    await c.read(p.future);
    expect(pdf.last!.validDays, 14);
    expect(pdf.last!.footerTitle, 'How to pay');
    expect(pdf.last!.footerNote, 'Please include quote Q-0038 with your payment.');
    expect(pdf.last!.paymentColumns.single.label, 'Zelle');
    sub.close();
  });

  test('Email opens Mail with the CMS subject', () async {
    final email = _Email();
    final c = make(FakeDbService(rows(_quoteRow())), _Sms(ComposeResult.sent), email);
    addTearDown(c.dispose);
    final p = quotePreviewViewModelProvider('q1');
    final sub = c.listen(p, (_, _) {});
    await c.read(p.future);
    await c.read(p.notifier).sendByEmail();
    expect(email.subject, 'Your quote Q-0038');
    sub.close();
  });

  test('Email: disabled with a reason when the customer has no email or the device has no Mail', () async {
    final c = make(FakeDbService(rows(_quoteRow(email: null))), _Sms(ComposeResult.sent));
    addTearDown(c.dispose);
    final p = quotePreviewViewModelProvider('q1');
    final sub = c.listen(p, (_, _) {});
    final s = await c.read(p.future);
    expect(s.canEmail, isFalse);
    expect(s.disabledReason, 'Add an email to this customer to send by Email');
    sub.close();

    final c2 = make(FakeDbService(rows(_quoteRow())), _Sms(ComposeResult.sent, mail: false));
    addTearDown(c2.dispose);
    final sub2 = c2.listen(p, (_, _) {});
    final s2 = await c2.read(p.future);
    expect(s2.canEmail, isFalse);
    expect(s2.disabledReason, 'Set up an email account on this device to send by Email');
    sub2.close();

    final c3 = make(FakeDbService(rows(_quoteRow())), _Sms(ComposeResult.sent));
    addTearDown(c3.dispose);
    final sub3 = c3.listen(p, (_, _) {});
    final s3 = await c3.read(p.future);
    expect(s3.canEmail, isTrue);
    expect(s3.disabledReason, isNull);
    sub3.close();
  });
}
