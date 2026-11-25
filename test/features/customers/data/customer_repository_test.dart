import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/features/customers/data/models/customer.dart';
import 'package:quote_generator_app/features/customers/data/repositories/customer_repository.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('findDuplicate never sends empty-string params (the DB bridge turns them into NULL)', () async {
    final db = FakeDbService();
    final repo = CustomerRepository(db, () {});

    await repo.findDuplicate(const CustomerInput(name: 'Grace', email: 'LEILANI@example.com'));
    await repo.findDuplicate(const CustomerInput(name: 'David', phone: '808 555 0187'), excludeId: 'c1');

    expect(db.calls, hasLength(2));
    expect(db.calls[0].params, ['leilani@example.com']);
    expect(db.calls[0].sql, isNot(contains('id <>')));
    expect(db.calls[1].params, ['+18085550187', 'c1']);
    for (final c in db.calls) {
      expect(c.params, isNot(contains('')));
    }
  });

  test('findDuplicate returns the existing customer', () async {
    final db = FakeDbService((sql, _) => [
          {'id': 'c1', 'name': 'Leilani Kahale', 'phone': '+18085550187', 'created_at': '2026-09-23T00:00:00Z'},
        ]);
    final dup = await CustomerRepository(db, () {}).findDuplicate(const CustomerInput(name: 'X', phone: '8085550187'));
    expect(dup?.name, 'Leilani Kahale');
  });
}
