import '../../../../core/services/appambit_db.dart';
import '../../../customers/data/models/customer.dart';
import 'business_snapshot.dart';
import 'line_item.dart';
import 'sent_via.dart';

/// A quote (DB `quotes`). [lines] and [customer] are loaded only by detail queries.
class Quote {
  const Quote({
    required this.id,
    required this.number,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.issueDate,
    required this.validUntil,
    required this.business,
    required this.taxLabel,
    required this.taxRate,
    this.taxName,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    this.sentVia,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
    this.lines = const [],
    this.customer,
  });

  final String id;
  final String number;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final DateTime issueDate;
  final DateTime validUntil;
  final BusinessSnapshot business;
  final String taxLabel;
  final double taxRate;
  final String? taxName;
  final int subtotal;
  final int taxAmount;
  final int total;
  final SentVia? sentVia;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<LineItem> lines;
  final Customer? customer;

  /// Days the quote is valid for (`valid_until - issue_date`), as set by
  /// `BusinessProfile.valid_days` when the quote was created.
  int get validDays => DateTime.utc(validUntil.year, validUntil.month, validUntil.day)
      .difference(DateTime.utc(issueDate.year, issueDate.month, issueDate.day))
      .inDays;

  factory Quote.fromRow(DbRow r, {List<LineItem> lines = const [], Customer? customer}) => Quote(
        id: '${r['id']}',
        number: '${r['number']}',
        customerId: '${r['customer_id']}',
        customerName: '${r['customer_name'] ?? customer?.name ?? ''}',
        customerPhone: DbValue.asString(r['customer_phone']) ?? customer?.phone,
        customerEmail: DbValue.asString(r['customer_email']) ?? customer?.email,
        issueDate: DbValue.asDate(r['issue_date']) ?? DateTime.now(),
        validUntil: DbValue.asDate(r['valid_until']) ?? DateTime.now(),
        business: BusinessSnapshot.decode(r['business_snapshot']),
        taxLabel: DbValue.asString(r['tax_label']) ?? '',
        taxRate: DbValue.asDouble(r['tax_rate']),
        taxName: DbValue.asString(r['tax_name']),
        subtotal: DbValue.asInt(r['subtotal']),
        taxAmount: DbValue.asInt(r['tax_amount']),
        total: DbValue.asInt(r['total']),
        sentVia: SentVia.parse(r['sent_via']),
        sentAt: DbValue.asDate(r['sent_at']),
        createdAt: DbValue.asDate(r['created_at']) ?? DateTime.now(),
        updatedAt: DbValue.asDate(r['updated_at']) ?? DateTime.now(),
        lines: lines,
        customer: customer,
      );
}

/// Everything the editor saves; the repository assigns ids/timestamps.
class QuoteDraft {
  const QuoteDraft({
    this.id,
    required this.numberPrefix,
    required this.customerId,
    required this.issueDate,
    required this.validUntil,
    required this.business,
    required this.taxLabel,
    required this.taxRate,
    this.taxName,
    required this.lines,
  });

  /// Null for a quote that is not in the DB yet.
  final String? id;

  /// CMS quote prefix ("Q-"); the number is assigned by the DB on first save.
  final String numberPrefix;
  final String customerId;
  final DateTime issueDate;
  final DateTime validUntil;
  final BusinessSnapshot business;
  final String taxLabel;
  final double taxRate;
  final String? taxName;
  final List<LineItem> lines;

  QuoteTotals get totals => QuoteTotals.of(lines, taxRate);
}
