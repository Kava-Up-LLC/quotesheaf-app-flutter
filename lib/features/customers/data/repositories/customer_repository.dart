import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/appambit_db.dart';
import '../../../../core/services/data_version.dart';
import '../models/customer.dart';

part 'customer_repository.g.dart';

class CustomerRepository {
  CustomerRepository(this._db, this._onChanged);

  final DbService _db;
  final void Function() _onChanged;

  static const _listSql = 'SELECT c.*, (SELECT COUNT(*) FROM quotes q WHERE q.customer_id = c.id) AS quote_count '
      'FROM customers c';

  /// All customers A–Z with their quote counts.
  Future<List<Customer>> all() async {
    final rows = await _db.query('$_listSql ORDER BY c.name COLLATE NOCASE');
    return rows.map(Customer.fromRow).toList();
  }

  /// Most recently used customers (last quote first, then newest).
  Future<List<Customer>> recent({int limit = 5}) async {
    final rows = await _db.query(
      '$_listSql ORDER BY COALESCE((SELECT MAX(q.updated_at) FROM quotes q WHERE q.customer_id = c.id), c.created_at) DESC LIMIT ?',
      [limit],
    );
    return rows.map(Customer.fromRow).toList();
  }

  Future<Customer?> byId(String id) async {
    final rows = await _db.query('$_listSql WHERE c.id = ?', [id]);
    return rows.isEmpty ? null : Customer.fromRow(rows.first);
  }

  /// Existing customer with the same phone or email (duplicate warning).
  /// Built without empty-string params: the DB bridge sends '' as NULL.
  Future<Customer?> findDuplicate(CustomerInput input, {String? excludeId}) async {
    final p = input.normalizedPhone;
    final e = input.normalizedEmail;
    final match = [if (p.isNotEmpty) 'phone = ?', if (e.isNotEmpty) 'lower(email) = ?'];
    if (match.isEmpty) return null;
    final rows = await _db.query(
      'SELECT * FROM customers WHERE (${match.join(' OR ')})${excludeId == null ? '' : ' AND id <> ?'} LIMIT 1',
      [if (p.isNotEmpty) p, if (e.isNotEmpty) e, ?excludeId],
    );
    return rows.isEmpty ? null : Customer.fromRow(rows.first);
  }

  Future<Customer> create(CustomerInput input) async {
    final id = const Uuid().v4();
    try {
      await _db.execute(
        'INSERT INTO customers (id, name, phone, email, address, notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [id, input.name.trim(), _n(input.normalizedPhone), _n(input.normalizedEmail), _n(input.address.trim()),
          _n(input.notes.trim()), DateTime.now().toUtc().toIso8601String()],
      );
    } on Failure catch (f) {
      throw Failure(Failure.saveFailed, f.cause);
    }
    _onChanged();
    return (await byId(id))!;
  }

  Future<Customer> update(String id, CustomerInput input) async {
    try {
      await _db.execute(
        'UPDATE customers SET name = ?, phone = ?, email = ?, address = ?, notes = ? WHERE id = ?',
        [input.name.trim(), _n(input.normalizedPhone), _n(input.normalizedEmail), _n(input.address.trim()),
          _n(input.notes.trim()), id],
      );
    } on Failure catch (f) {
      throw Failure(Failure.saveFailed, f.cause);
    }
    _onChanged();
    return (await byId(id))!;
  }

  static String? _n(String s) => s.isEmpty ? null : s;
}

@Riverpod(keepAlive: true)
CustomerRepository customerRepository(Ref ref) => CustomerRepository(
      ref.watch(dbServiceProvider),
      () => ref.read(dataVersionProvider.notifier).bump(),
    );
