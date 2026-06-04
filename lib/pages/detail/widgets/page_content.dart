import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Divider, EditableTextState, Icons, SelectionChangedCause, SelectableText;
import '../../../models/annotation.dart';
import '../../../models/card_item.dart';
import '../../../services/annotation_store.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import '../services/page_calculator.dart';
import 'hero_image.dart';
import 'content_card.dart';
import 'markdown_ast.dart';

typedef AnnotationCallback = void Function({
  required String selectedText,
  required int startOffset,
  required int endOffset,
  required AnnotationType type,
  required int color,
  List<String> notes,
});

class PageContent extends StatelessWidget {
  final PageSlice slice;
  final List<MarkdownSegment> allSegments;
  final CardItem? blog;
  final ReaderSettingsService settings;
  final AnnotationStore annotationStore;
  final AnnotationCallback onAnnotate;
  final void Function(String, int, int)? onAddNote;
  final void Function(String, int, int)? onPoster;

  const PageContent({
    super.key,
    required this.slice,
    required this.allSegments,
    this.blog,
    required this.settings,
    required this.annotationStore,
    required this.onAnnotate,
    this.onAddNote,
    this.onPoster,
  });

  @override
  Widget build(BuildContext context) {
    final s = settings;
    final isDark = s.backgroundColor == 'dark';
    final textColor = isDark ? AppColors.onDark : AppColors.ink;

    // Collect all segment indices for this page
    final indices = slice.segmentIndices;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slice.isFirstPage && blog != null) ...[
            DetailHeroImage(imageUrl: blog!.img),
            ContentHeader(
                blog: blog!,
                hasCover: blog!.img != null && blog!.img!.isNotEmpty),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
            child: _buildRichText(indices, s, textColor, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRichText(
      List<int> indices, ReaderSettingsService s, Color textColor, bool isDark) {
    final scale = s.fontSize / ReaderSettingsService.defaultFontSize;
    final spans = <InlineSpan>[];

    // Build concatenated spans with paragraph separation
    for (int i = 0; i < indices.length; i++) {
      final seg = allSegments[indices[i]];
      final segStyle = _baseStyle(seg, s, textColor, scale, isDark);
      final annSpans = _buildAnnotatedSpans(
          text: seg.text, baseStyle: segStyle, annotationStore: annotationStore);

      // Spacing BEFORE block-level headings
      if (_isBlockStyle(seg.style) && spans.isNotEmpty) {
        spans.add(TextSpan(text: '\n', style: _spacerStyle(segStyle)));
      }

      spans.addAll(annSpans);

      // Paragraph break after body paragraphs
      if (i < indices.length - 1) {
        final nextSeg = allSegments[indices[i + 1]];
        if (_isBlockStyle(seg.style) || _isBlockStyle(nextSeg.style)) {
          spans.add(TextSpan(text: '\n', style: _spacerStyle(segStyle)));
        }
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      contextMenuBuilder: (ctx, st) =>
          _buildMenu(ctx, st, indices),
    );
  }

  TextStyle _baseStyle(MarkdownSegment seg, ReaderSettingsService s,
      Color textColor, double scale, bool isDark) {
    return TextStyle(
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
          : seg.style == MdStyle.blockquote
              ? FontWeight.w300
              : FontWeight.w400,
      fontStyle: seg.style == MdStyle.italic || seg.style == MdStyle.blockquote
          ? FontStyle.italic
          : FontStyle.normal,
      letterSpacing: seg.style == MdStyle.h1 ? -0.3 : null,
    );
  }

  TextStyle _spacerStyle(TextStyle base) =>
      base.copyWith(fontSize: base.fontSize! * 0.6, height: 1.0);

  bool _isBlockStyle(MdStyle style) {
    switch (style) {
      case MdStyle.h1:
      case MdStyle.h2:
      case MdStyle.h3:
      case MdStyle.blockquote:
      case MdStyle.code:
        return true;
      default:
        return false;
    }
  }

  /// Find the global offset for a given local position in the concatenated text.
  int _localToGlobal(int localPos, List<int> indices) {
    int localCursor = 0;
    for (int i = 0; i < indices.length; i++) {
      final seg = allSegments[indices[i]];
      final segLen = seg.text.length;
      if (localPos <= localCursor + segLen) {
        return seg.globalOffset + (localPos - localCursor);
      }
      localCursor += segLen;
      // Account for separator newlines
      if (_isBlockStyle(seg.style) && i > 0) localCursor += 1;
      if (i < indices.length - 1) {
        final nextSeg = allSegments[indices[i + 1]];
        if (_isBlockStyle(seg.style) || _isBlockStyle(nextSeg.style)) {
          localCursor += 1;
        }
      }
    }
    return allSegments[indices.last].globalOffset;
  }

  List<TextSpan> _buildAnnotatedSpans({
    required String text,
    required TextStyle baseStyle,
    required AnnotationStore annotationStore,
  }) {
    final matches = <_TextMatch>[];
    for (final a in annotationStore.annotations) {
      int pos = 0;
      while ((pos = text.indexOf(a.selectedText, pos)) != -1) {
        matches.add(_TextMatch(
            start: pos, end: pos + a.selectedText.length, annotation: a));
        pos += a.selectedText.length;
      }
    }
    matches.sort((a, b) => a.start.compareTo(b.start));

    if (matches.isEmpty) return [TextSpan(text: text, style: baseStyle)];

    final spans = <TextSpan>[];
    int cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) {
        spans.add(
            TextSpan(text: text.substring(cursor, m.start), style: baseStyle));
      }
      var style = baseStyle;
      final a = m.annotation;
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
      spans.add(
          TextSpan(text: text.substring(m.start, m.end), style: style));
      cursor = m.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }
    return spans;
  }

  Widget _buildMenu(
      BuildContext ctx, EditableTextState st, List<int> indices) {
    final sel = st.textEditingValue.selection;
    final selLen = sel.isValid && !sel.isCollapsed
        ? (sel.end - sel.start).abs()
        : 0;

    if (selLen < 2) return const SizedBox.shrink();

    // Convert local selection offsets to global article offsets
    final globalStart = _localToGlobal(sel.start, indices);
    final globalEnd = _localToGlobal(sel.end, indices);
    final text = st.textEditingValue.text;
    final selectedText =
        (sel.start < text.length && sel.end <= text.length)
            ? text.substring(sel.start, sel.end)
            : '';

    return _DropdownMenu(
      ctx: ctx,
      onCopy: () {
        st.copySelection(SelectionChangedCause.toolbar);
        st.hideToolbar();
      },
      onSelectAll: () {
        st.selectAll(SelectionChangedCause.toolbar);
        st.hideToolbar();
      },
      onHide: () => st.hideToolbar(),
      selectedText: selectedText,
      startOffset: globalStart,
      endOffset: globalEnd,
      onAnnotateCall: onAnnotate,
      onAddNoteCall: onAddNote,
      onPosterCall: onPoster,
    );
  }
}

class _TextMatch {
  final int start;
  final int end;
  final Annotation annotation;
  const _TextMatch(
      {required this.start, required this.end, required this.annotation});
}

class _DropdownMenu extends StatelessWidget {
  final BuildContext ctx;
  final VoidCallback onCopy;
  final VoidCallback onSelectAll;
  final VoidCallback onHide;
  final String selectedText;
  final int startOffset;
  final int endOffset;
  final AnnotationCallback onAnnotateCall;
  final void Function(String, int, int)? onAddNoteCall;
  final void Function(String, int, int)? onPosterCall;

  const _DropdownMenu({
    required this.ctx,
    required this.onCopy,
    required this.onSelectAll,
    required this.onHide,
    required this.selectedText,
    required this.startOffset,
    required this.endOffset,
    required this.onAnnotateCall,
    this.onAddNoteCall,
    this.onPosterCall,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(icon: Icons.copy, label: '复制', onTap: () {
        onCopy();
        onHide();
      }),
      _MenuItem(icon: Icons.select_all, label: '全选', onTap: () {
        onSelectAll();
        onHide();
      }),
      _MenuItem.divider,
      _MenuItem(icon: Icons.format_paint, label: '高亮标记', onTap: () {
        onHide();
        _onSelectAction(AnnotationType.highlight);
      }),
      _MenuItem(icon: Icons.format_underline, label: '下划线', onTap: () {
        onHide();
        _onSelectAction(AnnotationType.underline);
      }),
      _MenuItem(icon: Icons.notes, label: '添加笔记', onTap: () {
        onHide();
        onAddNoteCall?.call(selectedText, startOffset, endOffset);
      }),
      _MenuItem.divider,
      _MenuItem(icon: Icons.image, label: '生成海报', onTap: () {
        onHide();
        onPosterCall?.call(selectedText, startOffset, endOffset);
      }),
    ];

    return Align(
      child: SizedBox(
        width: 240,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemBackground, ctx),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items.map((item) {
              if (identical(item, _MenuItem.divider)) {
                return const Divider(height: 1, indent: 16, endIndent: 16);
              }
              return _DropdownRow(item: item);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _onSelectAction(AnnotationType type) {
    final colors = type == AnnotationType.highlight
        ? AnnotationColors.highlightColors
        : AnnotationColors.underlineColors;
    showCupertinoModalPopup<int>(
      context: ctx,
      builder: (_) => _ColorPickerSheet(colors: colors),
    ).then((selectedColor) {
      if (selectedColor != null) {
        onAnnotateCall(
          selectedText: selectedText,
          startOffset: startOffset,
          endOffset: endOffset,
          type: type,
          color: selectedColor,
        );
      }
    });
  }
}

class _MenuItem {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  const _MenuItem({this.icon, this.onTap, required this.label});
  static const _MenuItem divider =
      _MenuItem(icon: null, onTap: null, label: '');
}

class _DropdownRow extends StatelessWidget {
  final _MenuItem item;
  const _DropdownRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 12),
            ],
            Text(item.label,
                style: const TextStyle(fontSize: 15, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerSheet extends StatelessWidget {
  final List<int> colors;
  const _ColorPickerSheet({required this.colors});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('选择颜色'),
      actions: colors
          .map((c) => CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context, c),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(c),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.hairline, width: 0.5),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
    );
  }
}
