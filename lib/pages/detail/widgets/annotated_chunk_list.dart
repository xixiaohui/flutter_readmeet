import 'package:flutter/material.dart';
import '../../../models/annotation.dart';
import '../../../services/annotation_store.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import 'markdown_ast.dart';

class AnnotatedChunkList extends StatelessWidget {
  final List<String> chunks;
  final ReaderSettingsService settingsService;
  final AnnotationStore annotationStore;

  const AnnotatedChunkList({
    super.key,
    required this.chunks,
    required this.settingsService,
    required this.annotationStore,
  });

  @override
  Widget build(BuildContext context) {
    if (chunks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: annotationStore,
          builder: (context, _) {
            final s = settingsService;

            return SliverList.separated(
              itemCount: chunks.length,
              itemBuilder: (context, index) {
                final segments = parseMarkdownToSegments(chunks[index]);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final seg in segments)
                        _buildSegment(seg, s),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, _) =>
                  SizedBox(height: settingsService.paragraphSpacing),
            );
          },
        );
      },
    );
  }

  Widget _buildSegment(MarkdownSegment seg, ReaderSettingsService s) {
    final isDark = s.backgroundColor == 'dark';
    final textColor = isDark ? AppColors.onDark : AppColors.ink;
    final scale = s.fontSize / ReaderSettingsService.defaultFontSize;
    double? topPad;

    // Determine padding per style
    switch (seg.style) {
      case MdStyle.h1:
        topPad = AppSpacing.xl;
        break;
      case MdStyle.h2:
        topPad = AppSpacing.lg;
        break;
      case MdStyle.h3:
        topPad = AppSpacing.md;
        break;
      default:
        break;
    }

    // Code block: special container
    if (seg.style == MdStyle.code) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? AppColors.inkMuted80 : AppColors.canvasParchment,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: SelectableText(
            seg.text,
            style: TextStyle(fontSize: 15, color: textColor),
          ),
        ),
      );
    }

    // Blockquote: special container with left border
    if (seg.style == MdStyle.blockquote) {
      return Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md, top: 4, bottom: 4),
        child: Container(
          decoration: const BoxDecoration(
            border:
                Border(left: BorderSide(color: AppColors.primary, width: 3)),
          ),
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: SelectableText(
            seg.text,
            style: TextStyle(
              fontSize: s.fontSize,
              height: s.lineHeight,
              color: textColor,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              fontFamily: s.fontFamily,
            ),
          ),
        ),
      );
    }

    // Normal text segments with font styling
    final ts = TextStyle(
      fontSize: seg.style == MdStyle.h1
          ? AppText.displayMdSize * scale
          : seg.style == MdStyle.h2
              ? AppText.taglineSize * scale
              : seg.style == MdStyle.h3
                  ? AppText.bodySize * scale
                  : s.fontSize,
      height: seg.style == MdStyle.h1
          ? 1.15
          : seg.style == MdStyle.h2
              ? 1.2
              : seg.style == MdStyle.h3
                  ? 1.3
                  : s.lineHeight,
      color: textColor,
      fontFamily: s.fontFamily,
      fontWeight: seg.style == MdStyle.bold ||
              seg.style == MdStyle.h1 ||
              seg.style == MdStyle.h2 ||
              seg.style == MdStyle.h3
          ? FontWeight.w600
          : FontWeight.w400,
      fontStyle:
          seg.style == MdStyle.italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: seg.style == MdStyle.h1 ? -0.3 : null,
    );

    // Apply annotation decorations
    final anns = annotationStore.annotationsInRange(
        seg.globalOffset, seg.globalOffset + seg.text.length);
    var style = ts;
    for (final a in anns) {
      if (a.type == AnnotationType.highlight) {
        style = style.copyWith(backgroundColor: Color(a.color));
      }
      if (a.type == AnnotationType.underline) {
        style = style.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: Color(a.color),
          decorationThickness: 2,
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: topPad ?? 0),
      child: SelectableText(seg.text, style: style),
    );
  }
}
