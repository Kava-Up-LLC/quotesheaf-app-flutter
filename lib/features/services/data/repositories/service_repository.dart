import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/appambit_cms.dart';
import '../../../../core/services/appambit_db.dart';
import '../models/service.dart';

part 'service_repository.g.dart';

class ServiceRepository {
  ServiceRepository(this._cms, this._db);

  final CmsService _cms;
  final DbService _db;

  static const itemType = 'catalog_item';
  static const categoryType = 'service_category';
  static const unitType = 'unit';

  Catalog? _cached;

  /// Active catalog items (A–Z), active categories (by sort order) and units —
  /// all from the CMS. Kept in memory after the first read; [refresh] re-reads.
  Future<Catalog> catalog({bool refresh = false}) async {
    if (_cached != null && !refresh) return _cached!;
    final results = await Future.wait([_cms.list(itemType), _cms.list(categoryType), _cms.list(unitType)]);
    final services = results[0].map(Service.fromJson).where((s) => s.active && s.name.isNotEmpty).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final categories = results[1].map(ServiceCategory.fromJson).whereType<ServiceCategory>().toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final units = {
      for (final u in results[2].map(Unit.fromJson).whereType<Unit>()) u.code: u,
    };
    return _cached = Catalog(services: services, categories: categories, units: units);
  }

  /// Service ids most recently added to quotes (newest first).
  Future<List<String>> recentServiceIds({int limit = 5}) async {
    try {
      final rows = await _db.query(
        'SELECT li.service_id AS service_id, MAX(q.updated_at) AS last_used FROM line_items li '
        'JOIN quotes q ON q.id = li.quote_id WHERE li.service_id IS NOT NULL '
        'GROUP BY li.service_id ORDER BY last_used DESC LIMIT ?',
        [limit],
      );
      return rows.map((r) => '${r['service_id']}').toList();
    } catch (_) {
      return const [];
    }
  }
}

@Riverpod(keepAlive: true)
ServiceRepository serviceRepository(Ref ref) =>
    ServiceRepository(ref.watch(cmsServiceProvider), ref.watch(dbServiceProvider));
