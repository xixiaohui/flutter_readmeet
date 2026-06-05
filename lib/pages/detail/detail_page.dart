import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../models/annotation.dart';
import '../../models/card_item.dart';
import '../../models/reading_progress.dart';
import '../../services/annotation_store.dart';
import '../../services/api_service.dart';
import '../../services/content_cache_service.dart';
import '../../services/favorite_service.dart';
import '../../services/reader_settings_service.dart';
import '../../services/reading_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/page_reader.dart';
import 'widgets/markdown_ast.dart';
import 'services/page_calculator.dart';
import 'annotation_summary_page.dart';
import 'widgets/poster_generator.dart';

class DetailPage extends StatefulWidget {
  final ApiService apiService;
  final String blogId;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const DetailPage({
    super.key,
    required this.apiService,
    required this.blogId,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _progressService = ReadingProgressService();
  final _annotationStore = AnnotationStore();

  CardItem? _blog;
  String? _error;
  String? _errorCode;
  List<MarkdownSegment>? _allSegments;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    widget.settingsService.load();
    _loadDetail();
  }

  @override
  void dispose() {
    _saveProgress();
    _annotationStore.flush();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _error = null;
      _blog = null;
      _allSegments = null;
    });

    // 1. Try cache first — show instantly if available
    try {
      final cache = ContentCacheService();
      final cached = await cache.get(widget.blogId);
      if (cached != null && cached.content != null && mounted) {
        final segments = _parseContent(cached.content!);
        setState(() {
          _blog = cached;
          _allSegments = segments;
        });
        _annotationStore.load(widget.blogId);
        _restoreProgress();
      }
    } catch (_) {}

    // 2. Fetch from API to get latest content
    try {
      final blog = await widget.apiService.getBlogDetail(widget.blogId);
      if (!mounted) return;
      final segments = _parseContent(blog.content ?? '');
      setState(() {
        _blog = blog;
        _allSegments = segments;
      });
      _annotationStore.load(widget.blogId);
      _restoreProgress();
      // Cache the fresh data
      ContentCacheService().set(widget.blogId, blog);
    } catch (e) {
      if (!mounted) return;
      if (_blog == null) setState(() {
        _error = e.toString();
        _errorCode = (e is ApiException) ? e.errorCode : null;
      });
    }
  }

  List<MarkdownSegment> _parseContent(String content) {
    final rawSegments = parseMarkdownToSegments(content);
    int running = 0;
    return rawSegments.map((seg) {
      final s = MarkdownSegment(
        text: seg.text,
        style: seg.style,
        isBlockEnd: seg.isBlockEnd,
        globalOffset: running,
      );
      running += seg.text.length;
      return s;
    }).toList();
  }

  Future<void> _restoreProgress() async {
    final saved = await _progressService.get(widget.blogId);
    if (!mounted || saved == null) return;
    _currentPage = saved.pageIndex;
  }

  void _saveProgress() {
    if (!mounted) return;
    final blog = _blog;
    if (blog == null || _totalPages == 0) return;
    final total = _totalPages;
    _progressService.save(ReadingProgress(
      blogId: widget.blogId,
      pageIndex: _currentPage,
      totalPages: total,
      progress: total > 0 ? (_currentPage / total).clamp(0.0, 1.0) : 0.0,
      blogTitle: blog.title,
      coverImg: blog.img,
      updatedAt: DateTime.now(),
    ));
  }

  List<PageSlice> _calculatePages(double availableHeight, double availableWidth) {
    final segments = _allSegments;
    if (segments == null || segments.isEmpty) return [];
    return PageCalculator.paginate(
      segments: segments,
      pageHeight: availableHeight,
      pageWidth: availableWidth,
      settings: widget.settingsService,
    );
  }

  // ── Annotation callbacks ──

  void _onAnnotate({
    required String selectedText,
    required int startOffset,
    required int endOffset,
    required AnnotationType type,
    required int color,
    List<String> notes = const [],
  }) {
    _annotationStore.add(
      selectedText: selectedText,
      startOffset: startOffset,
      endOffset: endOffset,
      type: type,
      color: color,
      notes: notes,
      blogTitle: _blog?.title,
    );
  }

  void _onAddNoteCallback(String text, int start, int end) async {
    final note = await showCupertinoDialog<String>(
      context: context,
      builder: (_) => _NoteInputDialog(initialText: ''),
    );
    if (note != null && note.isNotEmpty && mounted) {
      _annotationStore.add(
        selectedText: text,
        startOffset: start,
        endOffset: end,
        type: AnnotationType.highlight,
        color: AnnotationColors.yellow,
        notes: [note],
        blogTitle: _blog?.title,
      );
    }
  }

  void _onPosterCallback(String text, int start, int end) {
    if (_blog == null) return;
    final blog = _blog!;
    final date = blog.createdAt ?? '';
    final formattedDate = date.length >= 10 ? date.substring(0, 10) : date;
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (_) => PosterPreview(
        quote: text,
        articleTitle: blog.title,
        authorName: blog.authorName ?? '未知作者',
        date: formattedDate,
        settings: widget.settingsService,
      ),
    ));
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
        return CupertinoDynamicColor.resolve(
            CupertinoColors.darkBackgroundGray, context);
      default:
        return CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsService,
      builder: (context, _) {
        final isDark = widget.settingsService.backgroundColor == 'dark';
        SystemChrome.setSystemUIOverlayStyle(
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        );
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.back,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)?.back ?? '返回',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: AppText.bodySize)),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Favorite toggle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final blog = _blog;
                    if (blog == null) return;
                    widget.favoriteService.toggle(
                      blogId: blog.id,
                      title: blog.title,
                      authorName: blog.authorName ?? '未知作者',
                      coverImg: blog.img,
                    );
                  },
                  child: ListenableBuilder(
                    listenable: widget.favoriteService,
                    builder: (_, _a) {
                      final isFav = widget.favoriteService
                          .isFavorited(widget.blogId);
                      return Icon(
                        isFav
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: isFav
                            ? CupertinoColors.destructiveRed
                            : AppColors.primary,
                        size: 20,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Annotation button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) {
                        final blog = _blog!;
                        final date = blog.createdAt ?? '';
                        return AnnotationSummaryPage(
                          store: _annotationStore,
                          settings: widget.settingsService,
                          articleTitle: blog.title,
                          authorName: blog.authorName ?? '未知作者',
                          date: date.length >= 10
                              ? date.substring(0, 10)
                              : date,
                        );
                      },
                    ));
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
                          Flexible(
                            child: Text('${_annotationStore.count}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: AppText.finePrintSize,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Subtract safety margin: TextPainter estimates may be off
              // by ~1-2px per segment. With 10+ segments, this accumulates.
              final pageHeight = constraints.maxHeight - 24;
              final slices = _calculatePages(pageHeight, constraints.maxWidth);
              return _buildBody(slices);
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(List<PageSlice> slices) {
    if (_error != null) {
      return ErrorView(message: _error!, errorCode: _errorCode, onRetry: _loadDetail);
    }

    if (_blog == null) {
      return LoadingIndicator(message: AppLocalizations.of(context)?.loading ?? '加载中...');
    }

    if (_allSegments == null || _allSegments!.isEmpty) {
      return const EmptyView();
    }

    if (slices.isEmpty) {
      return LoadingIndicator(message: AppLocalizations.of(context)?.typesetting ?? '排版中...');
    }

    _totalPages = slices.length;
    return PageReader(
      slices: slices,
      allSegments: _allSegments!,
      blog: _blog,
      settingsService: widget.settingsService,
      annotationStore: _annotationStore,
      onAnnotate: _onAnnotate,
      onAddNote: _onAddNoteCallback,
      onPoster: _onPosterCallback,
      initialPage: _currentPage,
      onPageChanged: (page) {
        _currentPage = page;
        _saveProgress();
      },
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
      title: Text(AppLocalizations.of(context)?.addNote ?? '添加笔记'),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: CupertinoTextField(
          controller: _controller,
          autofocus: true,
          maxLines: 4,
          placeholder: AppLocalizations.of(context)?.writeNote ?? '写下你的想法...',
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)?.cancel ?? '取消'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(AppLocalizations.of(context)?.save ?? '保存'),
        ),
      ],
    );
  }
}
