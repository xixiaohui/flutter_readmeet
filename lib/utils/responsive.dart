import 'package:flutter/cupertino.dart';

/// Lightweight responsive breakpoints tuned for iOS devices.
class Responsive {
  Responsive._();

  static double _width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // ── Device type ──

  /// True when width < 600pt (iPhone portrait, all models).
  static bool isPhone(BuildContext context) => _width(context) < 600;

  /// True when width >= 600pt (iPad portrait / landscape, iPhone landscape).
  static bool isTablet(BuildContext context) => _width(context) >= 600;

  // ── Content ──

  /// Max reading width — prevents text lines becoming too long on iPad.
  static double contentMaxWidth(BuildContext context) =>
      isTablet(context) ? 720 : double.infinity;

  /// Horizontal padding for reading content.
  static double readingHPadding(BuildContext context) =>
      isTablet(context) ? 48.0 : 24.0;

  // ── Cards ──

  static double featuredCardWidth(BuildContext context) =>
      isTablet(context) ? 160.0 : 140.0;

  static double featuredCardHeight(BuildContext context) =>
      isTablet(context) ? 96.0 : 80.0;

  // ── Hero image ──

  static double heroImageHeight(BuildContext context) {
    final w = _width(context);
    if (w >= 1024) return 400;
    if (w >= 744) return 320;
    if (w >= 430) return 220;
    return 180;
  }

  static double heroSkeletonHeight(BuildContext context) {
    final w = _width(context);
    if (w >= 744) return 400;
    return 260;
  }

  // ── Detail hero ──

  static double detailHeroHeight(BuildContext context) {
    final w = _width(context);
    if (w >= 1024) return 360;
    if (w >= 744) return 300;
    return 220;
  }
}
