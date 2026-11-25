import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/core/utils/formatters.dart';
import 'package:quote_generator_app/core/utils/validators.dart';
import 'package:quote_generator_app/features/customers/data/models/customer.dart';

void main() {
  group('phone', () {
    test('normalizes to E.164', () {
      expect(Validators.normalizePhone('+1 808 555-0187'), '+18085550187');
      expect(Validators.normalizePhone('(808) 555-0187'), '+18085550187');
      expect(Validators.normalizePhone('1 808 555 0187'), '+18085550187');
    });

    test('validates E.164', () {
      expect(Validators.isE164('+18085550187'), isTrue);
      expect(Validators.isE164('808555'), isFalse);
    });

    test('formats US numbers for display', () {
      expect(Fmt.phone('+18085550187'), '+1 808 555 0187');
    });
  });

  test('email', () {
    expect(Validators.isEmail('leilani.kahale@example.com'), isTrue);
    expect(Validators.isEmail('leilani@bad'), isFalse);
  });

  group('CustomerInput.validate', () {
    test('only the name is required', () {
      expect(const CustomerInput(name: ' ').validate().keys, ['name']);
      expect(const CustomerInput(name: 'Pualani').validate(), isEmpty);
    });

    test('bad phone and email are reported', () {
      final e = const CustomerInput(name: 'X', phone: '808555', email: 'x@y').validate();
      expect(e.keys, containsAll(['phone', 'email']));
    });
  });

  test('quote number and templates', () {
    expect(Fmt.quoteNumber('Q-', 38), 'Q-0038');
    expect(
      Fmt.fillTemplate('Hi {{first_name}}, quote {{number}}', {'first_name': 'Leilani', 'number': 'Q-0038'}),
      'Hi Leilani, quote Q-0038',
    );
  });
}
