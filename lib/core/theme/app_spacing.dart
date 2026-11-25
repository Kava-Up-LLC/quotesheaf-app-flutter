/// DESIGN.md §2.3 — spacing and radius tokens.
abstract final class AppSpacing {
  static const side = 24.0;
  static const sideDock = 20.0;
  static const rowV = 15.0;
  static const labelTop = 22.0;
  static const labelBottom = 8.0;
  static const gapTitle = 4.0;
  static const gapButtons = 10.0;
  static const gapFields = 12.0;
  static const gapSheet = 16.0;
  static const dockBottom = 32.0;

  /// Bottom padding for docks / fixed CTAs: clear of the home indicator (iOS)
  /// or gesture / 3-button bar (Android), whose insets differ (34pt vs ~24dp).
  static double dockBottomFor(double systemInset) =>
      systemInset > 0 ? (systemInset + 12).clamp(dockBottom, 60).toDouble() : dockBottom;
  static const tap = 44.0;

  static const radiusField = 12.0;
  static const radiusChip = 16.0;
  static const radiusSheet = 24.0;
}
