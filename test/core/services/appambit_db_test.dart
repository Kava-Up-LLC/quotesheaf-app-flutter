import 'package:flutter_test/flutter_test.dart';
import 'package:quote_generator_app/core/services/appambit_db.dart';

void main() {
  group('inlineNulls (Android SDK crashes on null params)', () {
    test('null params become literal NULL and are dropped', () {
      final s = AppAmbitDbService.inlineNulls(const Sql(
        'INSERT INTO customers (id, name, phone, email, notes) VALUES (?, ?, ?, ?, ?)',
        ['c1', 'John M', '+5223726262', null, null],
      ));
      expect(s.sql, 'INSERT INTO customers (id, name, phone, email, notes) VALUES (?, ?, ?, NULL, NULL)');
      expect(s.params, ['c1', 'John M', '+5223726262']);
    });

    test('question marks inside quoted literals are left alone', () {
      final s = AppAmbitDbService.inlineNulls(
        const Sql("UPDATE t SET a = ?, b = 'what?' WHERE id = ?", [null, 'x']),
      );
      expect(s.sql, "UPDATE t SET a = NULL, b = 'what?' WHERE id = ?");
      expect(s.params, ['x']);
    });

    test('statements without nulls are untouched', () {
      const original = Sql('SELECT * FROM quotes WHERE id = ?', ['q1']);
      expect(identical(AppAmbitDbService.inlineNulls(original), original), isTrue);
    });
  });
}
