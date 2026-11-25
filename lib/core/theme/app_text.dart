import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// DESIGN.md §2.2 — type scale (Hanken Grotesk).
abstract final class AppText {
  static const family = 'HankenGrotesk';
  static const _tabular = [FontFeature.tabularFigures()];

  static const display = TextStyle(
      fontFamily: family, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: AppColors.ink);
  static const title = TextStyle(
      fontFamily: family, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: AppColors.ink);
  static const titleDetail = TextStyle(
      fontFamily: family, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: AppColors.ink);
  static const amountLg = TextStyle(
      fontFamily: family, fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink, fontFeatures: _tabular);
  static const sheetTitle =
      TextStyle(fontFamily: family, fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const body = TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.ink);
  static const bodyStrong = TextStyle(
      fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink, fontFeatures: _tabular);
  static const button = TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const callout = TextStyle(fontFamily: family, fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink);
  static const small = TextStyle(
      fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.muted, fontFeatures: _tabular);
  static const caption = TextStyle(fontFamily: family, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.muted);
  static const captionStrong =
      TextStyle(fontFamily: family, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted);
  static const micro = TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted);
  static const error = TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.error);
}
