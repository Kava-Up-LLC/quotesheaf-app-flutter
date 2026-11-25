import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/core/utils/money.dart';
import 'package:quote_generator_app/features/quotes/data/models/line_item.dart';

LineItem _line(String id, int price, double qty, {bool taxable = true}) =>
    LineItem(id: id, name: id, unitPrice: price, quantity: qty, taxable: taxable);

void main() {
  test('PRD sample Q-0038: subtotal \$650.50 · GET 4.5% \$29.27 · total \$679.77', () {
    final lines = [
      _line('diagnostic', 12900, 1),
      _line('capacitor', 8900, 1),
      _line('r410a', 8500, 2),
      _line('labor', 12500, 1.5),
      _line('drain', 7500, 1),
    ];
    final t = QuoteTotals.of(lines, 4.5);
    expect(t.subtotal, 65050);
    expect(t.tax, 2927);
    expect(t.total, 67977);
    expect(Money.format(t.total), r'$679.77');
  });

  test('tax applies only to taxable lines', () {
    final t = QuoteTotals.of([_line('a', 10000, 1), _line('b', 10000, 1, taxable: false)], 4.5);
    expect(t.subtotal, 20000);
    expect(t.tax, 450);
    expect(t.total, 20450);
  });

  test('line total rounds to the nearest cent', () {
    expect(Money.lineTotal(333, 1.5), 500); // 499.5 → 500
    expect(Money.fromDollars(129), 12900);
  });

  test('formatters', () {
    expect(Money.format(145000), r'$1,450.00');
    expect(Money.formatShort(12900), r'$129');
    expect(Money.formatRate(4.5), '4.5');
    expect(Money.formatRate(4), '4');
    expect(Money.formatQty(1.5), '1.5');
    expect(Money.formatQty(2.0), '2');
  });
}
