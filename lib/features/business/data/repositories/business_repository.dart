import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/services/appambit_cms.dart';
import '../../../../core/services/appambit_db.dart';
import '../models/business_profile.dart';
import '../models/quote_footer.dart';

part 'business_repository.g.dart';

class BusinessRepository {
  BusinessRepository(this._cms, this._db);

  final CmsService _cms;
  final DbService _db;
  BusinessProfile? _cached;

  static const contentType = 'business_profile';

  /// The CMS has no singleton type: the app reads the first entry.
  Future<BusinessProfile> profile({bool refresh = false}) async {
    if (_cached != null && !refresh) return _cached!;
    final items = await _cms.list(contentType);
    if (items.isEmpty) throw const Failure('No business profile in the CMS yet.');
    return _cached = BusinessProfile.fromJson(items.first);
  }

  /// Footer heading/note and payment methods (active, CMS order).
  Future<QuoteFooter> footer() async {
    final (footers, methods) = await (_cms.list('quote_footer'), _cms.list('payment_method')).wait;
    String? str(Object? v) => v == null || '$v'.trim().isEmpty ? null : '$v'.trim();
    num sortOf(Map<String, dynamic> m) => switch (m['sort_order']) { num n => n, String s => num.tryParse(s) ?? 0, _ => 0 };
    final active = methods.where((m) => m['active'] != false && m['active'] != 0).toList()
      ..sort((a, b) => sortOf(a).compareTo(sortOf(b)));
    final f = footers.isEmpty ? const <String, dynamic>{} : footers.first;
    return QuoteFooter(
      title: str(f['title']),
      note: str(f['note']),
      methods: active.map(PaymentMethod.fromJson).whereType<PaymentMethod>().toList(),
    );
  }

  Future<Uint8List?> logoBytes(BusinessProfile p) async =>
      p.logoUrl == null ? null : await _cms.media(p.logoUrl!);

  /// Next counter value that will be assigned (for the Business screen).
  Future<int> nextQuoteValue() async {
    final rows = await _db.query("SELECT value FROM counters WHERE name = 'quote'");
    return (rows.isEmpty ? 0 : DbValue.asInt(rows.first['value'])) + 1;
  }
}

@Riverpod(keepAlive: true)
BusinessRepository businessRepository(Ref ref) =>
    BusinessRepository(ref.watch(cmsServiceProvider), ref.watch(dbServiceProvider));
