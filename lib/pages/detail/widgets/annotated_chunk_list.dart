import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        AdaptiveTextSelectionToolbar,
        EditableTextState,
        Icons,
        SelectionChangedCause,
        SelectableText;
import '../../../models/annotation.dart';
import '../../../services/annotation_store.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import 'markdown_ast.dart';

typedef AnnotationCallback = void Function({
  required String selectedText,
  required int startOffset,
  required int endOffset,
  required AnnotationType type,
  required int color,
  List<String> notes,
});

class AnnotatedChunkList extends StatelessWidget {
  final List<String> chunks;
  final ReaderSettingsService settingsService;
  final AnnotationStore annotationStore;
  final AnnotationCallback onAnnotate;
  final void Function(String text, int start, int end)? onAddNote;
  final void Function(String text, int start, int end)? onPoster;

  const AnnotatedChunkList({
    super.key,
    required this.chunks,
    required this.settingsService,
    required this.annotationStore,
    required this.onAnnotate,
    this.onAddNote,
    this.onPoster,
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
            int cumulativeOffset = 0;
            return SliverList.separated(
              itemCount: chunks.length,
              itemBuilder: (context, index) {
                final parsed = parseMarkdownToSegments(chunks[index]);

                // Recalculate offsets sequentially by summing segment text
                // lengths — the parser's own offset values are unreliable
                // because markdown syntax chars confuse inline processing.
                int running = cumulativeOffset;
                final segments = parsed.map((seg) {
                  final s = MarkdownSegment(
                    text: seg.text,
                    style: seg.style,
                    isBlockEnd: seg.isBlockEnd,
                    globalOffset: running,
                  );
                  running += seg.text.length;
                  return s;
                }).toList();

                final chunkBase = cumulativeOffset;
                cumulativeOffset = running;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final seg in segments)
                        _buildSegment(seg, s, chunkBase),
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

  Widget _buildSegment(
      MarkdownSegment seg, ReaderSettingsService s, int chunkBaseOffset) {
    final isDark = s.backgroundColor == 'dark';
    final textColor = isDark ? AppColors.onDark : AppColors.ink;
    final scale = s.fontSize / ReaderSettingsService.defaultFontSize;
    final trueGlobalOffset = chunkBaseOffset + seg.globalOffset;
    double? topPad;

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
            contextMenuBuilder:
                (ctx, st) => _buildMenu(ctx, st, trueGlobalOffset),
            style: TextStyle(fontSize: 15, color: textColor),
          ),
        ),
      );
    }

    if (seg.style == MdStyle.blockquote) {
      return Padding(
        padding:
            const EdgeInsets.only(left: AppSpacing.md, top: 4, bottom: 4),
        child: Container(
          decoration: const BoxDecoration(
            border:
                Border(left: BorderSide(color: AppColors.primary, width: 3)),
          ),
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: SelectableText(
            seg.text,
            contextMenuBuilder:
                (ctx, st) => _buildMenu(ctx, st, trueGlobalOffset),
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

    // Annotation decorations
    final anns = annotationStore.annotationsInRange(
        trueGlobalOffset, trueGlobalOffset + seg.text.length);
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
      child: SelectableText(
        seg.text,
        contextMenuBuilder: (ctx, st) => _buildMenu(ctx, st, trueGlobalOffset),
        style: style,
      ),
    );
  }

  Widget _buildMenu(
      BuildContext ctx, EditableTextState st, int localBaseOffset) {
    return AdaptiveTextSelectionToolbar(
      anchors: st.contextMenuAnchors,
      children: [
        _MenuBtn(
          icon: Icons.copy,
          label: '复制',
          onTap: () {
            st.copySelection(SelectionChangedCause.toolbar);
            st.hideToolbar();
          },
        ),
        _MenuBtn(
          icon: Icons.select_all,
          label: '全选',
          onTap: () {
            st.selectAll(SelectionChangedCause.toolbar);
            st.hideToolbar();
          },
        ),
        const SizedBox(width: 6),
        _MenuBtn(
          icon: Icons.format_paint,
          label: '高亮',
          onTap: () =>
              _onSelectAction(ctx, st, localBaseOffset, AnnotationType.highlight),
        ),
        _MenuBtn(
          icon: Icons.format_underline,
          label: '下划线',
          onTap: () =>
              _onSelectAction(ctx, st, localBaseOffset, AnnotationType.underline),
        ),
        _MenuBtn(
          icon: Icons.notes,
          label: '笔记',
          onTap: () {
            final sel = st.textEditingValue.selection;
            if (!sel.isValid || sel.isCollapsed) return;
            final text = st.textEditingValue.text;
            final selectedText = text.substring(sel.start, sel.end);
            st.hideToolbar();
            onAddNote?.call(selectedText, localBaseOffset + sel.start,
                localBaseOffset + sel.end);
          },
        ),
        const SizedBox(width: 6),
        _MenuBtn(
          icon: Icons.image,
          label: '海报',
          onTap: () {
            final sel = st.textEditingValue.selection;
            if (!sel.isValid || sel.isCollapsed) return;
            final text = st.textEditingValue.text;
            final selectedText = text.substring(sel.start, sel.end);
            st.hideToolbar();
            onPoster?.call(selectedText, localBaseOffset + sel.start,
                localBaseOffset + sel.end);
          },
        ),
      ],
    );
  }

  void _onSelectAction(BuildContext ctx, EditableTextState st,
      int localBaseOffset, AnnotationType type) {
    final sel = st.textEditingValue.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final text = st.textEditingValue.text;
    final selectedText = text.substring(sel.start, sel.end);
    final globalStart = localBaseOffset + sel.start;
    final globalEnd = localBaseOffset + sel.end;
    st.hideToolbar();

    // Show color picker, then call onAnnotate
    final colors = type == AnnotationType.highlight
        ? AnnotationColors.highlightColors
        : AnnotationColors.underlineColors;
    showCupertinoModalPopup<int>(
      context: ctx,
      builder: (_) => _ColorPickerSheet(colors: colors),
    ).then((selectedColor) {
      if (selectedColor != null) {
        onAnnotate(
          selectedText: selectedText,
          startOffset: globalStart,
          endOffset: globalEnd,
          type: type,
          color: selectedColor,
        );
      }
    });
  }
}

class _MenuBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.ink),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.ink)),
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
