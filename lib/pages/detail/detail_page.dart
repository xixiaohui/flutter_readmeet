import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show AdaptiveTextSelectionToolbar, Icons, SelectionArea;
import 'package:flutter/services.dart';
import '../../models/annotation.dart';
import '../../models/card_item.dart';
import '../../models/reading_progress.dart';
import '../../services/annotation_store.dart';
import '../../services/api_service.dart';
import '../../services/reader_settings_service.dart';
import '../../services/reading_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/markdown_chunker.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/hero_image.dart';
import 'widgets/content_card.dart';
import 'widgets/annotated_chunk_list.dart';
import 'annotation_summary_page.dart';
import 'widgets/poster_generator.dart';

class DetailPage extends StatefulWidget {
  final ApiService apiService;
  final String blogId;
  final ReaderSettingsService settingsService;

  const DetailPage({
    super.key,
    required this.apiService,
    required this.blogId,
    required this.settingsService,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _scrollController = ScrollController();
  final _progressService = ReadingProgressService();
  final _annotationStore = AnnotationStore();
  Timer? _debounceTimer;

  CardItem? _blog;
  String? _error;
  List<String>? _chunks;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveProgress();
    _annotationStore.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _error = null;
      _blog = null;
      _chunks = null;
    });
    try {
      final blog = await widget.apiService.getBlogDetail(widget.blogId);
      if (!mounted) return;
      setState(() {
        _blog = blog;
        _chunks = blog.content != null && blog.content!.isNotEmpty
            ? MarkdownChunker.chunk(blog.content!)
            : [];
      });
      _annotationStore.load(widget.blogId);
      _restoreProgress();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _restoreProgress() async {
    final saved = await _progressService.get(widget.blogId);
    if (!mounted || saved == null) return;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(saved.scrollOffset);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(saved.scrollOffset);
        }
      });
    }
  }

  void _onScroll() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _saveProgress);
  }

  void _saveProgress() {
    if (!mounted) return;
    final blog = _blog;
    if (blog == null) return;
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final progress =
        maxExtent > 0 ? (offset / maxExtent).clamp(0.0, 1.0) : 0.0;

    _progressService.save(ReadingProgress(
      blogId: widget.blogId,
      scrollOffset: offset,
      progress: progress,
      blogTitle: blog.title,
      coverImg: blog.img,
      updatedAt: DateTime.now(),
    ));
  }

  // ── Context Menu ──

  Widget _buildContextMenu(
      BuildContext context, SelectableRegionState state) {
    return AdaptiveTextSelectionToolbar(
      anchors: state.contextMenuAnchors,
      children: [
        _MenuBtn(
          icon: Icons.copy,
          label: '复制',
          onTap: () {
            state.copySelection(SelectionChangedCause.toolbar);
            state.hideToolbar();
          },
        ),
        _MenuBtn(
          icon: Icons.select_all,
          label: '全选',
          onTap: () {
            state.selectAll(SelectionChangedCause.toolbar);
            state.hideToolbar();
          },
        ),
        const SizedBox(width: 6),
        _MenuBtn(
          icon: Icons.format_paint,
          label: '高亮',
          onTap: () => _onAnnotate(context, state, AnnotationType.highlight),
        ),
        _MenuBtn(
          icon: Icons.format_underline,
          label: '下划线',
          onTap: () => _onAnnotate(context, state, AnnotationType.underline),
        ),
        _MenuBtn(
          icon: Icons.notes,
          label: '笔记',
          onTap: () => _onAddNote(context, state),
        ),
        const SizedBox(width: 6),
        _MenuBtn(
          icon: Icons.image,
          label: '海报',
          onTap: () => _onPoster(context, state),
        ),
      ],
    );
  }

  void _onAnnotate(
      BuildContext context,
      SelectableRegionState state,
      AnnotationType type) async {
    final navigator = Navigator.of(context);
    state.copySelection(SelectionChangedCause.toolbar);
    await Future.delayed(const Duration(milliseconds: 50));
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    state.hideToolbar();

    if (text.isEmpty) return;

    final colors = type == AnnotationType.highlight
        ? AnnotationColors.highlightColors
        : AnnotationColors.underlineColors;
    final selectedColor = await showCupertinoModalPopup<int>(
      context: navigator.context,
      builder: (_) => _ColorPickerSheet(colors: colors),
    );

    if (selectedColor != null && mounted) {
      _annotationStore.add(
        selectedText: text,
        startOffset: 0,
        endOffset: text.length,
        type: type,
        color: selectedColor,
      );
    }
  }

  void _onAddNote(
      BuildContext context, SelectableRegionState state) async {
    final navigator = Navigator.of(context);
    state.copySelection(SelectionChangedCause.toolbar);
    await Future.delayed(const Duration(milliseconds: 50));
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    state.hideToolbar();

    if (text.isEmpty) return;

    final note = await showCupertinoDialog<String>(
      context: navigator.context,
      builder: (_) => _NoteInputDialog(initialText: text),
    );

    if (note != null && note.isNotEmpty && mounted) {
      _annotationStore.add(
        selectedText: text,
        startOffset: 0,
        endOffset: text.length,
        type: AnnotationType.highlight,
        color: AnnotationColors.yellow,
        note: note,
      );
    }
  }

  void _onPoster(
      BuildContext context, SelectableRegionState state) async {
    final navigator = Navigator.of(context);
    state.copySelection(SelectionChangedCause.toolbar);
    await Future.delayed(const Duration(milliseconds: 50));
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    state.hideToolbar();

    if (text.isEmpty || _blog == null) return;

    final blog = _blog!;
    final date = blog.createdAt ?? '';
    final formattedDate = date.length >= 10 ? date.substring(0, 10) : date;

    if (!mounted) return;
    navigator.push(
      CupertinoPageRoute(
        builder: (_) => PosterPreview(
          quote: text,
          articleTitle: blog.title,
          authorName: blog.authorName,
          date: formattedDate,
        ),
      ),
    );
  }

  Color _bgColor() {
    switch (widget.settingsService.backgroundColor) {
      case 'white':
        return AppColors.canvas;
      case 'dark':
        return AppColors.surfaceTile1;
      case 'parchment':
      default:
        return AppColors.canvasParchment;
    }
  }

  Color _navBgColor() {
    switch (widget.settingsService.backgroundColor) {
      case 'dark':
        return AppColors.surfaceTile1.withValues(alpha: 0.9);
      default:
        return AppColors.canvas.withValues(alpha: 0.9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsService,
      builder: (context, _) {
        return CupertinoPageScaffold(
          backgroundColor: _bgColor(),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: _navBgColor(),
            border: null,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.back,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '返回',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: AppText.bodySize,
                    ),
                  ),
                ],
              ),
            ),
            trailing: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => AnnotationSummaryPage(
                        store: _annotationStore),
                  ),
                );
              },
              child: ListenableBuilder(
                listenable: _annotationStore,
                builder: (_, child) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.pencil,
                        color: AppColors.primary, size: 18),
                    if (_annotationStore.count > 0) ...[
                      const SizedBox(width: 2),
                      Text(
                        '${_annotationStore.count}',
                        style: const TextStyle(
                          fontSize: AppText.finePrintSize,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          child: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _loadDetail);
    }

    if (_blog == null) {
      return const LoadingIndicator(message: '加载中...');
    }

    final blog = _blog!;
    final hasCover = blog.img != null && blog.img!.isNotEmpty;
    final chunks = _chunks ?? [];

    return SelectionArea(
      contextMenuBuilder: (context, state) =>
          _buildContextMenu(context, state),
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: DetailHeroImage(imageUrl: blog.img),
            ),
            SliverToBoxAdapter(
              child: ContentHeader(blog: blog, hasCover: hasCover),
            ),
            if (chunks.isNotEmpty)
              AnnotatedChunkList(
                chunks: chunks,
                settingsService: widget.settingsService,
                annotationStore: _annotationStore,
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Context Menu Helpers ──

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

class _NoteInputDialog extends StatefulWidget {
  final String initialText;
  const _NoteInputDialog({required this.initialText});

  @override
  State<_NoteInputDialog> createState() => _NoteInputDialogState();
}

class _NoteInputDialogState extends State<_NoteInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('添加笔记'),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: CupertinoTextField(
          controller: _controller,
          autofocus: true,
          maxLines: 4,
          placeholder: '写下你的想法...',
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
