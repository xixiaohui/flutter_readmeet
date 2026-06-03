import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../models/card_item.dart';
import '../../services/api_service.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../detail/detail_page.dart';
import '../list/widgets/blog_row.dart';

/// A paginated list page for featured content, driven by a search query.
///
/// [title] — navigation bar title (e.g. "中文精选", "日文精选").
/// [query] — the `q` parameter sent to `searchBlogs` (e.g. "zh", "ja").
class HotPage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final String title;
  final String query;
  final bool useAuthorSearch;

  const HotPage({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.title,
    required this.query,
    this.useAuthorSearch = false,
  });

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final _scrollController = ScrollController();

  List<CardItem> _blogs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _offset = 0;
  bool _hasMore = true;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<List<CardItem>> _fetch(int limit, int offset) {
    if (widget.useAuthorSearch) {
      return widget.apiService.searchAuthor(widget.query, limit: limit, offset: offset);
    }
    return widget.apiService.searchBlogs(widget.query, limit: limit, offset: offset);
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await _fetch(_pageSize, 0);
      if (!mounted) return;
      setState(() {
        _blogs = results;
        _offset = results.length;
        _hasMore = results.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    try {
      final results = await _fetch(_pageSize, _offset);
      if (!mounted) return;
      setState(() {
        _blogs.addAll(results);
        _offset += results.length;
        _hasMore = results.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _openDetail(CardItem item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DetailPage(
          apiService: widget.apiService,
          blogId: item.id,
          settingsService: widget.settingsService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvas,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.canvasParchment,
        border: null,
        middle: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: '加载中...');
    }

    if (_error != null && _blogs.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    if (_blogs.isEmpty) {
      return const EmptyView(message: '暂无精选内容');
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _blogs.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _blogs.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: CupertinoActivityIndicator(),
          );
        }
        return BlogRow(
          item: _blogs[index],
          onTap: () => _openDetail(_blogs[index]),
        );
      },
    );
  }
}
