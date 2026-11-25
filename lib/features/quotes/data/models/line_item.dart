import '../../../../core/services/appambit_db.dart';
import '../../../../core/utils/money.dart';

/// One quote line (DB `line_items`); CMS values are copied in (snapshot).
class LineItem {
  const LineItem({
    required this.id,
    this.serviceId,
    required this.name,
    this.description,
    required this.unitPrice,
    required this.quantity,
    this.unit = 'ea',
    this.taxable = true,
  });

  final String id;
  final String? serviceId;
  final String name;
  final String? description;

  /// Cents.
  final int unitPrice;
  final double quantity;
  final String unit;
  final bool taxable;

  /// Cents: `round(unit_price × quantity)`.
  int get lineTotal => Money.lineTotal(unitPrice, quantity);

  LineItem copyWith({String? description, int? unitPrice, double? quantity, bool? taxable}) => LineItem(
        id: id,
        serviceId: serviceId,
        name: name,
        description: description ?? this.description,
        unitPrice: unitPrice ?? this.unitPrice,
        quantity: quantity ?? this.quantity,
        unit: unit,
        taxable: taxable ?? this.taxable,
      );

  factory LineItem.fromRow(DbRow r) => LineItem(
        id: '${r['id']}',
        serviceId: DbValue.asString(r['service_id']),
        name: '${r['name'] ?? ''}',
        description: DbValue.asString(r['description']),
        unitPrice: DbValue.asInt(r['unit_price']),
        quantity: DbValue.asDouble(r['quantity'], 1),
        unit: DbValue.asString(r['unit']) ?? 'ea',
        taxable: DbValue.asBool(r['taxable']),
      );

  @override
  bool operator ==(Object other) =>
      other is LineItem &&
      other.id == id &&
      other.description == description &&
      other.unitPrice == unitPrice &&
      other.quantity == quantity &&
      other.taxable == taxable;

  @override
  int get hashCode => Object.hash(id, description, unitPrice, quantity, taxable);
}

/// Subtotal / tax / total for a set of lines (integer cents, PRD §9.2).
class QuoteTotals {
  const QuoteTotals({required this.subtotal, required this.tax, required this.total});

  final int subtotal;
  final int tax;
  final int total;

  factory QuoteTotals.of(List<LineItem> lines, double taxRatePercent) {
    final subtotal = lines.fold<int>(0, (s, l) => s + l.lineTotal);
    final taxable = lines.where((l) => l.taxable).fold<int>(0, (s, l) => s + l.lineTotal);
    final tax = Money.tax(taxable, taxRatePercent);
    return QuoteTotals(subtotal: subtotal, tax: tax, total: subtotal + tax);
  }
}
