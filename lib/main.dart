import 'dart:io';

import 'package:appambit_sdk_flutter/appambit_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status and navigation bars on every Android version.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(App.systemBars);
  await dotenv.load();
  // Each platform has its own AppAmbit app (same DB, same CMS content).
  final appKey = Platform.isIOS
      ? dotenv.env['APPAMBIT_IOS_APP_KEY']
      : Platform.isAndroid
          ? dotenv.env['APPAMBIT_ANDROID_APP_KEY']
          : null;
  if (appKey != null) await AppAmbitSdk.start(appKey: appKey);
  runApp(const ProviderScope(child: App()));
}
