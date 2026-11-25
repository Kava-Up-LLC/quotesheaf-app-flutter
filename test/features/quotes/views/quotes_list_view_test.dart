import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/core/services/appambit_cms.dart';
import 'package:quote_generator_app/core/services/appambit_db.dart';
import 'package:quote_generator_app/features/quotes/views/quotes_list_view.dart';

import '../../../helpers/fakes.dart';

Map<String, dynamic> _quote(String number, String customer, int total, {String phone = ''}) => {
      'id': number,
      'number': number,
      'customer_id': customer,
      'customer_name': customer,
      'customer_phone': phone,
      'issue_date': '2026-09-23',
      'valid_until': '2026-10-07',
      'business_snapshot': '{}',
      'tax_label': 'GET',
      'tax_rate': 4.5,
      'subtotal': total,
      'tax_amount': 0,
      'total': total,
      'created_at': '2026-09-23T00:00:00Z',
      'updated_at': '2026-09-23T00:00:00Z',
    };

Widget _app(FakeDbService db) => ProviderScope(
      overrides: [
        dbServiceProvider.overrideWithValue(db),
        cmsServiceProvider.overrideWithValue(FakeCmsService({'business_profile': [businessProfileJson]})),
      ],
      child: const MaterialApp(home: QuotesListView()),
    );

void main() {
  testWidgets('Home lists quotes by customer without statuses and searches', (tester) async {
    final db = FakeDbService((sql, _) => sql.contains('FROM quotes')
        ? [
            _quote('Q-0034', 'David Souza', 24976),
            _quote('Q-0038', 'Leilani Kahale', 67977, phone: '+18085550187'),
          ]
        : const []);
    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    expect(find.text("Czanelle's"), findsOneWidget);
    expect(find.text('All quotes · by customer'), findsOneWidget);
    expect(find.text(r'$679.77'), findsOneWidget);
    for (final gone in ['Draft', 'Sent', 'Approved', 'Declined', 'Waiting for an answer']) {
      expect(find.text(gone), findsNothing);
    }

    await tester.enterText(find.byType(TextField), '0187');
    await tester.pumpAndSettle();
    expect(find.text('Leilani Kahale'), findsOneWidget);
    expect(find.text('David Souza'), findsNothing);
  });

  testWidgets('empty state', (tester) async {
    await tester.pumpWidget(_app(FakeDbService()));
    await tester.pumpAndSettle();
    expect(find.text('No quotes yet'), findsOneWidget);
  });
}
