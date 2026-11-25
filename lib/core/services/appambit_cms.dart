import 'dart:convert';
import 'dart:io';

import 'package:appambit_sdk_flutter/appambit_cms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../errors/failure.dart';

part 'appambit_cms.g.dart';

/// Reads published CMS entries (read-only) and caches them on the device
/// so the app can still browse the profile and catalog offline (PRD §11).
abstract interface class CmsService {
  Future<List<Map<String, dynamic>>> list(String contentType);

  /// Downloads a CMS media URL once and returns the cached bytes.
  Future<Uint8List?> media(String url);
}

class AppAmbitCmsService implements CmsService {
  const AppAmbitCmsService({this.typeSuffix = ''});

  /// Appended to every content type slug. AppAmbit content types are unique per
  /// team and linked to one app, so each platform app has its own copy
  /// (e.g. `business_profile` on iOS, `business_profile_android` on Android).
  final String typeSuffix;

  static const _perPage = 100;

  /// The native SDK may never answer when the CMS returns an error (seen on
  /// Android with a 404), so reads are bounded and fall back to the cache.
  static const _timeout = Duration(seconds: 15);

  @override
  Future<List<Map<String, dynamic>>> list(String baseType) async {
    final contentType = '$baseType$typeSuffix';
    final cache = await _file('cms_$contentType.json');
    try {
      final items = await AppAmbitCms.content<Map<String, dynamic>>(contentType, fromJson: _normalize)
          .getPerPage(_perPage)
          .getList()
          .timeout(_timeout);
      if (items.isNotEmpty) {
        await cache.writeAsString(jsonEncode(items));
        return items;
      }
    } catch (_) {
      // Fall back to the local cache below.
    }
    if (await cache.exists()) {
      final decoded = jsonDecode(await cache.readAsString()) as List;
      return decoded.map((e) => _normalize(e as Map)).toList();
    }
    throw const Failure(Failure.loadFailed);
  }

  @override
  Future<Uint8List?> media(String url) async {
    final file = await _file('media_${url.hashCode.toUnsigned(32)}');
    if (await file.exists()) return file.readAsBytes();
    try {
      final client = HttpClient();
      final res = await (await client.getUrl(Uri.parse(url))).close();
      if (res.statusCode != 200) return null;
      final bytes = Uint8List.fromList(await res.expand((b) => b).toList());
      client.close();
      await file.writeAsBytes(bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Entries may arrive flat or wrapped in `data`; always return flat fields
  /// plus `id` when present.
  static Map<String, dynamic> _normalize(Map raw) {
    final map = raw.map((k, v) => MapEntry('$k', v));
    final data = map['data'];
    if (data is Map) {
      return {
        ...data.map((k, v) => MapEntry('$k', v)),
        if (map['id'] != null) 'id': map['id'],
        if (map['uuid'] != null) 'id': map['uuid'],
      };
    }
    return map;
  }

  static Future<File> _file(String name) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$name');
  }
}

@Riverpod(keepAlive: true)
CmsService cmsService(Ref ref) => AppAmbitCmsService(
      typeSuffix: switch (defaultTargetPlatform) {
            TargetPlatform.android => dotenv.maybeGet('APPAMBIT_ANDROID_CMS_SUFFIX'),
            _ => dotenv.maybeGet('APPAMBIT_IOS_CMS_SUFFIX'),
          } ??
          '',
    );
