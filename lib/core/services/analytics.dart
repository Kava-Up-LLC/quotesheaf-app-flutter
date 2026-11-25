import 'package:appambit_sdk_flutter/appambit_sdk_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics.g.dart';

/// Usage analytics (PRD §10): quote created, approved / declined…
abstract interface class AnalyticsService {
  void track(String event, [Map<String, String> properties = const {}]);
}

class AppAmbitAnalyticsService implements AnalyticsService {
  const AppAmbitAnalyticsService();

  @override
  void track(String event, [Map<String, String> properties = const {}]) {
    AppAmbitSdk.trackEvent(event, properties).catchError((_) {});
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => const AppAmbitAnalyticsService();
