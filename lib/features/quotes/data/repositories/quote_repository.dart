import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/appambit_db.dart';
import '../../../../core/services/data_version.dart';
import '../../../../core/utils/formatters.dart';
import '../../../customers/data/repositories/customer_repository.dart';
import '../models/line_item.dart';
import '../models/quote.dart';
import '../models/sent_via.dart';

part 'quote_repository.g.dart';

class QuoteRepository {
  QuoteRepository(this._db, this._customers, this._onChanged);

  final DbService _db;
  final CustomerRepository _customers;
  final void Function() _onChanged;

  static const _listSql = 'SELECT q.*, c.name AS customer_name, c.phone AS customer_phone, '
      'c.email AS customer_email FROM quotes q JOIN customers c ON c.id = q.customer_id';

  /// All quotes, sorted by customer name then newest first.
  Future<List<Quote>> all() async {
    final rows = await _db.query('$_listSql ORDER BY c.name COLLATE NOCASE, q.created_at DESC');
    return rows.map(Quote.fromRow).toList();
  }

  Future<List<Quote>> byCustomer(String customerId) async {
    final rows = await _db.query('$_listSql WHERE q.customer_id = ? ORDER BY q.created_at DESC', [customerId]);
    return rows.map(Quote.fromRow).toList();
  }

  /// Quote with its line items and customer.
  Future<Quote?> byId(String id) async {
    final rows = await _db.query('$_listSql WHERE q.id = ?', [id]);
    if (rows.isEmpty) return null;
    final lineRows = await _db.query('SELECT * FROM line_items WHERE quote_id = ? ORDER BY sort', [id]);
    final customer = await _customers.byId('${rows.first['customer_id']}');
    return Quote.fromRow(rows.first, lines: lineRows.map(LineItem.fromRow).toList(), customer: customer);
  }

  /// Inserts or updates the quote and replaces its line items in one DB transaction.
  /// A new quote takes the next number from `counters` inside the same transaction,
  /// so numbers are never skipped by abandoned quotes and two devices never collide.
  /// Returns the quote id.
  Future<String> save(QuoteDraft d) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = d.id ?? const Uuid().v4();
    final t = d.totals;
    final statements = <Sql>[
      if (d.id == null) ...[
        const Sql("UPDATE counters SET value = value + 1 WHERE name = 'quote'"),
        Sql(
          'INSERT INTO quotes (id, number, customer_id, issue_date, valid_until, business_snapshot, '
          'tax_label, tax_rate, tax_name, subtotal, tax_amount, total, created_at, updated_at) '
          "VALUES (?, (SELECT ? || printf('%04d', value) FROM counters WHERE name = 'quote'), "
          '?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [id, d.numberPrefix, d.customerId, Fmt.isoDate(d.issueDate), Fmt.isoDate(d.validUntil),
            d.business.encode(), d.taxLabel, d.taxRate, d.taxName, t.subtotal, t.tax, t.total, now, now],
        ),
      ] else
        Sql(
          'UPDATE quotes SET customer_id = ?, subtotal = ?, tax_amount = ?, total = ?, updated_at = ? WHERE id = ?',
          [d.customerId, t.subtotal, t.tax, t.total, now, id],
        ),
      Sql('DELETE FROM line_items WHERE quote_id = ?', [id]),
      for (final (i, l) in d.lines.indexed)
        Sql(
          'INSERT INTO line_items (id, quote_id, service_id, name, description, unit_price, quantity, unit, '
          'taxable, line_total, sort) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [const Uuid().v4(), id, l.serviceId, l.name, l.description, l.unitPrice, l.quantity, l.unit,
            l.taxable ? 1 : 0, l.lineTotal, i],
        ),
    ];
    await _db.transaction(statements);
    _onChanged();
    return id;
  }

  /// The number the DB gave the quote.
  Future<String> numberOf(String id) async {
    final rows = await _db.query('SELECT number FROM quotes WHERE id = ?', [id]);
    if (rows.isEmpty) throw const Failure(Failure.loadFailed);
    return '${rows.first['number']}';
  }

  /// Records the last send (called after the native composer reports "sent").
  Future<void> markSent(String id, SentVia via) async {
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      await _db.execute('UPDATE quotes SET sent_via = ?, sent_at = ?, updated_at = ? WHERE id = ?',
          [via.name, now, now, id]);
    } on Failure catch (f) {
      throw Failure(Failure.saveFailed, f.cause);
    }
    _onChanged();
  }
}

@Riverpod(keepAlive: true)
QuoteRepository quoteRepository(Ref ref) => QuoteRepository(
      ref.watch(dbServiceProvider),
      ref.watch(customerRepositoryProvider),
      () => ref.read(dataVersionProvider.notifier).bump(),
    );
