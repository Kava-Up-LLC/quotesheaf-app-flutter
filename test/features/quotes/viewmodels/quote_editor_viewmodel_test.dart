import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/core/router/routes.dart';
import 'package:quote_generator_app/core/services/analytics.dart';
import 'package:quote_generator_app/core/services/appambit_cms.dart';
import 'package:quote_generator_app/core/services/appambit_db.dart';
import 'package:quote_generator_app/features/customers/data/models/customer.dart';
import 'package:quote_generator_app/features/quotes/viewmodels/quote_editor_viewmodel.dart';
import 'package:quote_generator_app/features/services/data/models/service.dart';

import '../../../helpers/fakes.dart';

class _Analytics implements AnalyticsService {
  final events = <String>[];
  @override
  void track(String event, [Map<String, String> properties = const {}]) => events.add(event);
}

void main() {
  late FakeDbService db;
  late _Analytics analytics;
  late ProviderContainer container;

  setUp(() {
    db = FakeDbService((sql, _) => sql.startsWith('SELECT number FROM quotes') ? [{'number': 'Q-0038'}] : const []);
    analytics = _Analytics();
    container = ProviderContainer(overrides: [
      dbServiceProvider.overrideWithValue(db),
      cmsServiceProvider.overrideWithValue(FakeCmsService({
        ...catalogCms,
        'business_profile': [businessProfileJson],
        'quote_footer': [
          {'title': 'How to pay', 'note': 'Please include quote {{number}} with your payment.'},
        ],
        'payment_method': [
          {'label': 'Check', 'value': 'Payable to Czanelle', 'sort_order': 2},
          {'label': 'Zelle', 'value': '(808) 555-0142', 'sort_order': 1},
          {'label': 'Old', 'value': 'x', 'active': false},
        ],
      })),
      analyticsServiceProvider.overrideWithValue(analytics),
    ]);
  });

  tearDown(() => container.dispose());

  final provider = quoteEditorViewModelProvider(AppRoutes.newQuoteKey, null);

  Service svc(String name, int price, String unit) => Service(id: name, name: name, unit: unit, unitPrice: price);

  ServiceSelection sel(Service s, double qty) =>
      ServiceSelection(service: s, description: '', quantity: qty, unitPrice: s.unitPrice, taxable: true);

  test('opening a new quote reserves no number and snapshots the CMS profile', () async {
    final sub = container.listen(provider, (_, _) {});
    final s = await container.read(provider.future);
    expect(s.number, isNull);
    expect(db.calls, isEmpty);
    expect(s.validUntil.difference(s.issueDate).inDays, 14);
    expect(s.taxDisplay, 'GET 4.5%');
    expect(s.business.approvalNote, 'Reply YES to this text or call (808) 555-0142.');
    expect(s.business.footerTitle, 'How to pay');
    expect(s.business.paymentMethods.map((m) => m.label), ['Zelle', 'Check']);
    sub.close();
  });

  test('PRD sample totals; save numbers the quote inside the same transaction', () async {
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final vm = container.read(provider.notifier);

    expect(container.read(provider).value!.canPreview, isFalse);
    vm.setCustomer(Customer(id: 'c1', name: 'Leilani Kahale', createdAt: DateTime(2026)));
    vm
      ..addServices([
        sel(svc('AC Diagnostic / Service Call', 12900, 'ea'), 1),
        sel(svc('Dual Run Capacitor 45/5 µF', 8900, 'ea'), 1),
      ])
      ..addServices([
        sel(svc('Refrigerant Recharge R-410A', 8500, 'lb'), 2),
        sel(svc('Split / Ductless AC Repair — Labor', 12500, 'hr'), 1.5),
        sel(svc('Condensate Drain Line Flush', 7500, 'ea'), 1),
      ]);

    final s = container.read(provider).value!;
    expect(s.totals.subtotal, 65050);
    expect(s.totals.tax, 2927);
    expect(s.totals.total, 67977);
    expect(s.canPreview, isTrue);
    expect(s.stepFor(s.lines[2]), 0.5); // lb step from the CMS unit

    final removed = s.lines[1];
    final i = vm.removeLine(removed.id);
    expect(container.read(provider).value!.totals.subtotal, 65050 - 8900);
    vm.restoreLine(i, removed);
    expect(container.read(provider).value!.lines[1].id, removed.id);

    final id = await vm.save();
    expect(id, isNotNull);
    expect(db.calls[0].sql, contains('UPDATE counters SET value = value + 1'));
    expect(db.calls[1].sql, startsWith('INSERT INTO quotes'));
    expect(db.calls[1].sql, contains("printf('%04d', value)"));
    expect(db.calls.where((c) => c.sql.startsWith('INSERT INTO line_items')), hasLength(5));
    expect(db.calls.any((c) => c.sql.contains('status')), isFalse);
    final saved = container.read(provider).value!;
    expect(saved.number, 'Q-0038');
    expect(saved.dirty, isFalse);
    expect(analytics.events, ['quote_created']);

    db.calls.clear();
    expect(await vm.save(), id);
    expect(db.calls, isEmpty);
    sub.close();
  });
}
