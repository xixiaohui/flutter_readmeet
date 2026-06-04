import 'package:flutter/cupertino.dart';
import '../../../models/annotation.dart';
import '../../../services/annotation_store.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import 'markdown_ast.dart';

/// Build a [TextSpan] tree from markdown segments, applying annotation
/// decorations (highlight backgrounds, underlines) where they overlap.
TextSpan buildAnnotatedSpans({
  required List<MarkdownSegment> segments,
  required AnnotationStore store,
  required ReaderSettingsService settings,
}) {
  final s = settings;
  final scale = s.fontSize / ReaderSettingsService.defaultFontSize;
  final isDark = s.backgroundColor == 'dark';
  final textColor = isDark ? AppColors.onDark : AppColors.ink;
  final spans = <InlineSpan>[];

  for (final seg in segments) {
    final start = seg.globalOffset;
    final end = start + seg.text.length;
    final anns = store.annotationsInRange(start, end);

    final baseStyle = _textStyleFor(seg.style, s, textColor, scale);

    if (anns.isEmpty) {
      spans.add(TextSpan(text: seg.text, style: baseStyle));
    } else {
      spans.add(_buildAnnotatedSpan(seg.text, baseStyle, anns));
    }
  }

  return TextSpan(children: spans);
}

InlineSpan _buildAnnotatedSpan(
    String text, TextStyle baseStyle, List<Annotation> anns) {
  TextStyle style = baseStyle;

  // Separate highlights and underlines
  final highlights = anns.where((a) => a.type == AnnotationType.highlight);
  final underlines = anns.where((a) => a.type == AnnotationType.underline);

  // Apply background colors (last highlight wins for full-segment coverage)
  for (final h in highlights) {
    style = style.copyWith(backgroundColor: Color(h.color));
  }

  // Apply underline decoration
  if (underlines.isNotEmpty) {
    final u = underlines.last;
    style = style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: Color(u.color),
      decorationThickness: 2,
    );
  }

  // If any annotation has a note, attach comment badge
  final noteAnns = anns.where((a) => a.hasNote).toList();
  if (noteAnns.isNotEmpty) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: _AnnotationBadge(
        annotation: noteAnns.first,
        child: Text.rich(TextSpan(text: text, style: style)),
      ),
    );
  }

  return TextSpan(text: text, style: style);
}

TextStyle _textStyleFor(
    MdStyle style, ReaderSettingsService s, Color textColor, double scale) {
  final base = TextStyle(
    fontWeight: FontWeight.w400,
    color: textColor,
    fontFamily: s.fontFamily,
  );

  switch (style) {
    case MdStyle.body:
      return base.copyWith(
          fontSize: s.fontSize, height: s.lineHeight, fontWeight: FontWeight.w400);
    case MdStyle.h1:
      return base.copyWith(
          fontSize: AppText.displayMdSize * scale,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.15);
    case MdStyle.h2:
      return base.copyWith(
          fontSize: AppText.taglineSize * scale,
          fontWeight: FontWeight.w600,
          height: 1.2);
    case MdStyle.h3:
      return base.copyWith(
          fontSize: AppText.bodySize * scale,
          fontWeight: FontWeight.w600,
          height: 1.3);
    case MdStyle.bold:
      return base.copyWith(
          fontSize: s.fontSize,
          height: s.lineHeight,
          fontWeight: FontWeight.w600);
    case MdStyle.italic:
      return base.copyWith(
          fontSize: s.fontSize,
          height: s.lineHeight,
          fontStyle: FontStyle.italic);
    case MdStyle.code:
      final isDark = s.backgroundColor == 'dark';
      return base.copyWith(
        fontSize: 15,
        backgroundColor:
            isDark ? AppColors.inkMuted80 : AppColors.canvasParchment,
      );
    case MdStyle.blockquote:
      return base.copyWith(
          fontSize: s.fontSize,
          height: s.lineHeight,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic);
  }
}

/// Inline badge shown after annotated text that has a comment.
class _AnnotationBadge extends StatelessWidget {
  final Annotation annotation;
  final Widget child;

  const _AnnotationBadge({required this.annotation, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNotePopup(context, annotation),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          child,
          const SizedBox(width: 2),
          const Icon(CupertinoIcons.text_bubble,
              size: 14, color: AppColors.primary),
        ],
      ),
    );
  }

  void _showNotePopup(BuildContext context, Annotation ann) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('笔记'),
        content: Text(ann.note ?? ''),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
