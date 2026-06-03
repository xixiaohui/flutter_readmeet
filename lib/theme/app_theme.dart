import 'package:flutter/cupertino.dart';

/// Apple-style design tokens based on DESIGN.md
class AppColors {
  // Brand
  static const Color primary = Color(0xFF0066CC);
  static const Color primaryFocus = Color(0xFF0071E3);
  static const Color primaryOnDark = Color(0xFF2997FF);

  // Ink
  static const Color ink = Color(0xFF1D1D1F);
  static const Color inkMuted48 = Color(0xFF7A7A7A);
  static const Color inkMuted80 = Color(0xFF333333);

  // Surface
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasParchment = Color(0xFFF5F5F7);
  static const Color surfaceTile1 = Color(0xFF272729);
  static const Color surfacePeach = Color(0xFFFAFAFC);

  // Dividers
  static const Color dividerSoft = Color(0xFFF0F0F0);
  static const Color hairline = Color(0xFFE0E0E0);

  // Dark surfaces
  static const Color surfaceBlack = Color(0xFF000000);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color bodyMuted = Color(0xFFCCCCCC);

  // Highlight
  static const Color highlightYellow = Color(0xFFFFF3CD);
}

/// Typography helpers
class AppText {
  static const double bodySize = 17.0;
  static const double captionSize = 14.0;
  static const double finePrintSize = 12.0;
  static const double taglineSize = 21.0;
  static const double displayMdSize = 28.0;
  static const double displayLgSize = 40.0;

  static const String fontDisplay = '.SF Pro Display';
  static const String fontText = '.SF Pro Text';

  static const double bodyLineHeight = 1.47;
  static const double readingLineHeight = 1.8;
}

/// Spacing based on DESIGN.md 8px grid
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 17.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double section = 80.0;
}

/// Border radii
class AppRadius {
  static const double xs = 5.0;
  static const double sm = 8.0;
  static const double md = 11.0;
  static const double lg = 18.0;
  static const double pill = 9999.0;
}
