import 'package:appambit_sdk_flutter/appambit_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../errors/failure.dart';

part 'appambit_db.g.dart';

typedef DbRow = Map<String, dynamic>;

/// One SQL statement with positional `?` params.
class Sql {
  const Sql(this.sql, [this.params]);
  final String sql;
  final List<Object?>? params;
}

/// Thin wrapper around the AppAmbit DB SDK — the only place that touches it.
abstract interface class DbService {
  Future<List<DbRow>> query(String sql, [List<Object?>? params]);
  Future<void> execute(String sql, [List<Object?>? params]);

  /// Runs all statements atomically; returns the rows of each statement.
  Future<List<List<DbRow>>> transaction(List<Sql> statements);
}

class AppAmbitDbService implements DbService {
  const AppAmbitDbService();

  @override
  Future<List<DbRow>> query(String sql, [List<Object?>? params]) async {
    final s = inlineNulls(Sql(sql, params));
    final r = await _guard(() => AppAmbitDb.execute(s.sql, _params(s.params)));
    return r.toMaps();
  }

  @override
  Future<void> execute(String sql, [List<Object?>? params]) async {
    final s = inlineNulls(Sql(sql, params));
    await _guard(() => AppAmbitDb.execute(s.sql, _params(s.params)));
  }

  @override
  Future<List<List<DbRow>>> transaction(List<Sql> statements) async {
    final List<DbResult> results;
    try {
      results = await AppAmbitDb.batchInTransaction(statements.map(inlineNulls).map((s) {
        return DbStatement.of(s.sql, _params(s.params));
      }).toList());
    } catch (e) {
      throw Failure(Failure.saveFailed, e);
    }
    final failed = results.where((r) => r.hasError);
    if (failed.isNotEmpty) throw Failure(Failure.saveFailed, failed.first.error);
    return results.map((r) => r.toMaps()).toList();
  }

  /// Replaces each `?` bound to `null` with a literal `NULL` and drops that param.
  /// The Android SDK crashes serializing null params (NullPointerException in
  /// `JsonConvertUtils.collectionToJson`); `?` inside quoted literals is ignored.
  static Sql inlineNulls(Sql s) {
    final params = s.params;
    if (params == null || !params.contains(null)) return s;
    final out = StringBuffer();
    final kept = <Object?>[];
    var i = 0;
    String? quote;
    for (final ch in s.sql.split('')) {
      if (quote != null) {
        if (ch == quote) quote = null;
        out.write(ch);
      } else if (ch == "'" || ch == '"') {
        quote = ch;
        out.write(ch);
      } else if (ch == '?') {
        final v = i < params.length ? params[i] : null;
        i++;
        if (v == null) {
          out.write('NULL');
        } else {
          out.write('?');
          kept.add(v);
        }
      } else {
        out.write(ch);
      }
    }
    return Sql(out.toString(), kept);
  }

  static List<Object?>? _params(List<Object?>? p) =>
      p?.map((v) => v is bool ? (v ? 1 : 0) : v).toList();

  static Future<DbResult> _guard(Future<DbResult> Function() run) async {
    final DbResult r;
    try {
      r = await run();
    } catch (e) {
      throw Failure(Failure.loadFailed, e);
    }
    if (r.hasError) throw Failure(Failure.loadFailed, r.error);
    return r;
  }
}

/// Lenient readers: the DB bridge may return numbers as int, double or String.
abstract final class DbValue {
  static int asInt(Object? v, [int fallback = 0]) => switch (v) {
        int i => i,
        num n => n.round(),
        String s => num.tryParse(s)?.round() ?? fallback,
        _ => fallback,
      };

  static double asDouble(Object? v, [double fallback = 0]) => switch (v) {
        num n => n.toDouble(),
        String s => double.tryParse(s) ?? fallback,
        _ => fallback,
      };

  static String? asString(Object? v) => v == null ? null : '$v';

  static bool asBool(Object? v) => switch (v) {
        bool b => b,
        num n => n != 0,
        String s => s == '1' || s.toLowerCase() == 'true',
        _ => false,
      };

  static DateTime? asDate(Object? v) => v == null ? null : DateTime.tryParse('$v');
}

@Riverpod(keepAlive: true)
DbService dbService(Ref ref) => const AppAmbitDbService();
