import '../../../../core/utils/money.dart';

bool _bool(Object? v, bool fallback) => switch (v) {
      bool x => x,
      num x => x != 0,
      String x => x == '1' || x.toLowerCase() == 'true',
      _ => fallback,
    };

num? _num(Object? v) => switch (v) { num x => x, String x => num.tryParse(x), _ => null };

String? _str(Object? v) => v == null || '$v'.trim().isEmpty ? null : '$v'.trim();

/// A catalog item from the CMS `catalog_item` content type (read-only).
class Service {
  const Service({
    required this.id,
    required this.name,
    this.sku,
    this.category,
    this.description,
    required this.unit,
    required this.unitPrice,
    this.taxable = true,
    this.active = true,
  });

  final String id;
  final String name;
  final String? sku;

  /// A [ServiceCategory.name].
  final String? category;
  final String? description;

  /// A [Unit.code].
  final String unit;

  /// Cents.
  final int unitPrice;
  final bool taxable;
  final bool active;

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: '${j['id'] ?? j['uuid'] ?? j['name']}',
        name: _str(j['name']) ?? '',
        sku: _str(j['sku']),
        category: _str(j['category']),
        description: _str(j['description']),
        unit: _str(j['unit']) ?? '',
        unitPrice: Money.fromDollars(_num(j['unit_price']) ?? 0),
        taxable: _bool(j['taxable'], true),
        active: _bool(j['active'], true),
      );
}

/// A picker filter from the CMS `service_category` content type.
class ServiceCategory {
  const ServiceCategory({required this.name, required this.sortOrder});

  final String name;
  final int sortOrder;

  static ServiceCategory? fromJson(Map<String, dynamic> j) {
    final name = _str(j['name']);
    if (name == null || !_bool(j['active'], true)) return null;
    return ServiceCategory(name: name, sortOrder: _num(j['sort_order'])?.toInt() ?? 0);
  }
}

/// A unit of measure from the CMS `unit` content type.
class Unit {
  const Unit({required this.code, required this.step});

  final String code;

  /// Quantity stepper increment (e.g. 0.5 for hours).
  final double step;

  static Unit? fromJson(Map<String, dynamic> j) {
    final code = _str(j['code']);
    final step = _num(j['qty_step'])?.toDouble();
    if (code == null || step == null || step <= 0) return null;
    return Unit(code: code, step: step);
  }
}

/// Everything the Add service picker needs, read from the CMS.
class Catalog {
  const Catalog({required this.services, required this.categories, required this.units});

  final List<Service> services;
  final List<ServiceCategory> categories;
  final Map<String, Unit> units;

  /// Stepper increment for a unit code; 1 when the unit is not in the CMS.
  double stepFor(String unit) => units[unit]?.step ?? 1;
}

/// What the Add service sheet returns to the quote editor.
class ServiceSelection {
  const ServiceSelection({
    required this.service,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.taxable,
  });

  final Service service;
  final String description;
  final double quantity;
  final int unitPrice;
  final bool taxable;
}
