import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../models/card_item.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../detail/detail_page.dart';
import 'widgets/search_bar.dart';
import 'widgets/blog_row.dart';

class ListPage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const ListPage({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<CardItem> _blogs = [];
  int _total = 0;
  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Search state
  bool _isSearching = false;
  List<CardItem> _searchResults = [];
  int _searchOffset = 0;
  bool _hasMoreSearch = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_isSearching) {
        _loadMoreSearch();
      } else {
        _loadMore();
      }
    }
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await widget.apiService.getBlogs(page: 1, pageSize: 20);
      if (!mounted) return;
      setState(() {
        _blogs = result.data;
        _total = result.total;
        _page = 1;
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
    if (_isLoadingMore) return;
    if (_blogs.length >= _total) return;

    setState(() => _isLoadingMore = true);
    try {
      final result =
          await widget.apiService.getBlogs(page: _page + 1, pageSize: 20);
      if (!mounted) return;
      setState(() {
        _blogs.addAll(result.data);
        _total = result.total;
        _page++;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _searchOffset = 0;
      _hasMoreSearch = true;
    });

    try {
      final results =
          await widget.apiService.searchBlogs(query, limit: 20, offset: 0);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isLoading = false;
        _hasMoreSearch = results.length >= 20;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreSearch() async {
    if (_isLoadingMore || !_hasMoreSearch) return;

    setState(() => _isLoadingMore = true);
    final nextOffset = _searchOffset + 20;
    try {
      final results = await widget.apiService.searchBlogs(
        _searchController.text,
        limit: 20,
        offset: nextOffset,
      );
      if (!mounted) return;
      setState(() {
        _searchResults.addAll(results);
        _searchOffset = nextOffset;
        _isLoadingMore = false;
        _hasMoreSearch = results.length >= 20;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
  }

  void _openDetail(CardItem item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DetailPage(
          apiService: widget.apiService,
          blogId: item.id,
          settingsService: widget.settingsService,
          favoriteService: widget.favoriteService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _isSearching ? _searchResults : _blogs;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvas,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.canvasParchment,
        border: null,
        middle: Text(
          '全部文章',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            BlogSearchBar(
              controller: _searchController,
              onChanged: _onSearch,
              onClear: _clearSearch,
            ),
            Expanded(child: _buildContent(displayList)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<CardItem> displayList) {
    if (_isLoading) {
      return const LoadingIndicator(message: '加载中...');
    }

    if (_error != null && displayList.isEmpty) {
      return ErrorView(message: _error!, onRetry: _loadBlogs);
    }

    if (displayList.isEmpty) {
      if (_isSearching) {
        return const EmptyView(message: '未找到相关内容');
      }
      return const EmptyView(message: '暂无文章');
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: displayList.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= displayList.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: CupertinoActivityIndicator(),
          );
        }
        return BlogRow(
          item: displayList[index],
          onTap: () => _openDetail(displayList[index]),
        );
      },
    );
  }
}
