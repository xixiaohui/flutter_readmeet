import 'package:flutter/cupertino.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/markdown_ast.dart';

class PageSlice {
  final List<int> segmentIndices;
  final bool isFirstPage;

  const PageSlice({
    required this.segmentIndices,
    required this.isFirstPage,
  });
}

/// Measures segment heights with [TextPainter] and assigns them to pages.
class PageCalculator {
  static const double heroHeight = 240;
  static const double headerHeight = 160; // approximate, varies

  /// Build a [TextStyle] matching what `annotated_chunk_list.dart` renders.
  static TextStyle styleForSegment(
      MarkdownSegment seg, ReaderSettingsService s) {
    final scale = s.fontSize / ReaderSettingsService.defaultFontSize;
    final isDark = s.backgroundColor == 'dark';
    final textColor = isDark ? AppColors.onDark : AppColors.ink;

    double fontSize;
    double height;
    FontWeight weight = FontWeight.w400;
    FontStyle fontStyle = FontStyle.normal;
    double? letterSpacing;

    switch (seg.style) {
      case MdStyle.h1:
        fontSize = AppText.displayMdSize * scale;
        height = 1.15;
        weight = FontWeight.w600;
        letterSpacing = -0.3;
      case MdStyle.h2:
        fontSize = AppText.taglineSize * scale;
        height = 1.2;
        weight = FontWeight.w600;
      case MdStyle.h3:
        fontSize = AppText.bodySize * scale;
        height = 1.3;
        weight = FontWeight.w600;
      case MdStyle.bold:
        fontSize = s.fontSize;
        height = s.lineHeight;
        weight = FontWeight.w600;
      case MdStyle.italic:
        fontSize = s.fontSize;
        height = s.lineHeight;
        fontStyle = FontStyle.italic;
      case MdStyle.code:
        fontSize = 15;
        height = s.lineHeight;
      case MdStyle.blockquote:
        fontSize = s.fontSize;
        height = s.lineHeight;
        weight = FontWeight.w300;
        fontStyle = FontStyle.italic;
      case MdStyle.body:
        fontSize = s.fontSize;
        height = s.lineHeight;
    }

    return TextStyle(
      fontSize: fontSize,
      height: height,
      fontWeight: weight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      color: textColor,
      fontFamily: s.fontFamily,
    );
  }

  /// Measure how tall a segment will render, given a max width.
  static double measureHeight(String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    tp.layout(maxWidth: maxWidth);
    return tp.height;
  }

  /// Paginate [segments] into pages that fit within [pageHeight].
  /// Page content width is [pageWidth] minus horizontal padding (24px × 2).
  static List<PageSlice> paginate({
    required List<MarkdownSegment> segments,
    required double pageHeight,
    required double pageWidth,
    required ReaderSettingsService settings,
  }) {
    if (segments.isEmpty) return [];

    final contentWidth = pageWidth - AppSpacing.lg * 2; // 24px padding each side
    final slices = <PageSlice>[];
    List<int> currentIndices = [];
    double remaining = pageHeight - heroHeight - headerHeight; // page 0
    int i = 0;

    // Add top padding for headings
    double topPadFor(MdStyle style) {
      switch (style) {
        case MdStyle.h1:
          return AppSpacing.xl;
        case MdStyle.h2:
          return AppSpacing.lg;
        case MdStyle.h3:
          return AppSpacing.md;
        default:
          return 0;
      }
    }

    while (i < segments.length) {
      final seg = segments[i];
      final style = styleForSegment(seg, settings);
      double segHeight = measureHeight(seg.text, style, contentWidth) +
          topPadFor(seg.style);

      // Code blocks have extra container padding
      if (seg.style == MdStyle.code) {
        segHeight += AppSpacing.sm * 2 + 8; // container padding + margin
      }
      // Blockquotes have border + padding
      if (seg.style == MdStyle.blockquote) {
        segHeight += 8; // vertical padding
      }

      if (segHeight <= remaining || currentIndices.isEmpty) {
        currentIndices.add(i);
        remaining -= segHeight;
        i++;
      } else {
        slices.add(PageSlice(
          segmentIndices: List.from(currentIndices),
          isFirstPage: slices.isEmpty,
        ));
        currentIndices = [];
        remaining = pageHeight;
      }
    }

    if (currentIndices.isNotEmpty) {
      slices.add(PageSlice(
        segmentIndices: List.from(currentIndices),
        isFirstPage: slices.isEmpty,
      ));
    }

    return slices;
  }
}
