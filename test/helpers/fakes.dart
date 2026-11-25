import 'dart:typed_data';

import 'package:quote_generator_app/core/services/appambit_cms.dart';
import 'package:quote_generator_app/core/services/appambit_db.dart';

/// Records every statement and answers queries from [responder].
class FakeDbService implements DbService {
  FakeDbService([this.responder]);

  final List<DbRow> Function(String sql, List<Object?>? params)? responder;
  final calls = <Sql>[];

  @override
  Future<List<DbRow>> query(String sql, [List<Object?>? params]) async {
    calls.add(Sql(sql, params));
    return responder?.call(sql, params) ?? const [];
  }

  @override
  Future<void> execute(String sql, [List<Object?>? params]) async => calls.add(Sql(sql, params));

  @override
  Future<List<List<DbRow>>> transaction(List<Sql> statements) async {
    calls.addAll(statements);
    return [for (final s in statements) responder?.call(s.sql, s.params) ?? const <DbRow>[]];
  }
}

class FakeCmsService implements CmsService {
  FakeCmsService(this.items);

  final Map<String, List<Map<String, dynamic>>> items;

  @override
  Future<List<Map<String, dynamic>>> list(String contentType) async => items[contentType] ?? const [];

  @override
  Future<Uint8List?> media(String url) async => null;
}

const catalogCms = <String, List<Map<String, dynamic>>>{
  'catalog_item': [
    {'id': 's1', 'name': 'Refrigerant Recharge R-410A', 'category': 'Refrigerant', 'unit': 'lb', 'unit_price': 85},
    {'id': 's2', 'name': 'Old item', 'category': 'Parts', 'unit': 'ea', 'unit_price': 10, 'active': false},
    {'id': 's3', 'name': 'Contactor 30A', 'category': 'Parts', 'unit': 'ea', 'unit_price': 79},
  ],
  'service_category': [
    {'name': 'Parts', 'sort_order': 2},
    {'name': 'Refrigerant', 'sort_order': 1},
    {'name': 'Plumbing', 'sort_order': 3},
    {'name': 'Hidden', 'sort_order': 0, 'active': false},
  ],
  'unit': [
    {'code': 'ea', 'qty_step': 1},
    {'code': 'lb', 'qty_step': 0.5},
  ],
};

const businessProfileJson = <String, dynamic>{
  'name': "Czanelle's Airconditioning & Refrigeration",
  'trade_label': 'A/C & Refrigeration',
  'phone': '(808) 555-0142',
  'tax_label': 'GET',
  'tax_rate': 4.5,
  'quote_prefix': 'Q-',
  'valid_days': 14,
  'approval_note': 'Reply YES to this text or call {{business_phone}}.',
};
