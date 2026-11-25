import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: AppText.family,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.ink,
          onPrimary: AppColors.onInk,
          surface: AppColors.bg,
          onSurface: AppColors.ink,
          outline: AppColors.hairline,
          error: AppColors.error,
        ),
        dividerTheme: const DividerThemeData(color: AppColors.hairline, thickness: 1, space: 1),
        splashFactory: NoSplash.splashFactory,
        highlightColor: AppColors.soft,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.ink,
          contentTextStyle: TextStyle(fontFamily: AppText.family, fontSize: 15, color: AppColors.onInk),
          actionTextColor: AppColors.onInk,
          behavior: SnackBarBehavior.floating,
        ),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.ink),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      );
}
