import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import '../../../models/card_item.dart';
import '../../../services/annotation_store.dart';
import '../../../services/reader_settings_service.dart';
import '../services/page_calculator.dart';
import 'markdown_ast.dart';
import 'page_content.dart';

class PageReader extends StatefulWidget {
  final List<PageSlice> slices;
  final List<MarkdownSegment> allSegments;
  final CardItem? blog;
  final ReaderSettingsService settingsService;
  final AnnotationStore annotationStore;
  final AnnotationCallback onAnnotate;
  final void Function(String, int, int)? onAddNote;
  final void Function(String, int, int)? onPoster;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;

  const PageReader({
    super.key,
    required this.slices,
    required this.allSegments,
    this.blog,
    required this.settingsService,
    required this.annotationStore,
    required this.onAnnotate,
    this.onAddNote,
    this.onPoster,
    this.initialPage = 0,
    this.onPageChanged,
  });

  @override
  State<PageReader> createState() => _PageReaderState();
}

class _PageReaderState extends State<PageReader> {
  late PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
        initialPage: widget.initialPage.clamp(0, (widget.slices.length - 1).clamp(0, 9999)));
    _currentPage = _controller.initialPage;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get currentPage => _currentPage;
  int get totalPages => widget.slices.length;

  @override
  Widget build(BuildContext context) {
    final slices = widget.slices;
    if (slices.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: slices.length,
          physics: const BouncingScrollPhysics(
            parent: PageScrollPhysics(),
          ),
          onPageChanged: (page) {
            setState(() => _currentPage = page);
            widget.onPageChanged?.call(page);
          },
          itemBuilder: (context, index) {
            return ListenableBuilder(
              listenable: widget.settingsService,
              builder: (context, _) {
                return ListenableBuilder(
                  listenable: widget.annotationStore,
                  builder: (context, _) {
                    return PageContent(
                      slice: slices[index],
                      allSegments: widget.allSegments,
                      blog: slices[index].isFirstPage ? widget.blog : null,
                      settings: widget.settingsService,
                      annotationStore: widget.annotationStore,
                      onAnnotate: widget.onAnnotate,
                      onAddNote: widget.onAddNote,
                      onPoster: widget.onPoster,
                    );
                  },
                );
              },
            );
          },
        ),
        // Page indicator — bottom-right corner
        if (slices.length > 1)
          Positioned(
            bottom: Platform.isIOS ? 34 : 24,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_currentPage + 1} / ${slices.length}',
                style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
          ),
      ],
    );
  }
}
