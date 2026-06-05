import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../models/card_item.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../detail/detail_page.dart';
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
  final _scrollController = ScrollController();

  List<CardItem> _blogs = [];
  int _total = 0;
  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    widget.favoriteService.load();
    _loadBlogs();
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
        _errorCode = (e is ApiException) ? e.errorCode : null;
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
    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvas,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.canvasParchment,
        border: null,
        middle: Text(
          AppLocalizations.of(context)?.allArticlesTab ?? '全部文章',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      child: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return LoadingIndicator(message: AppLocalizations.of(context)?.loading ?? '加载中...');
    }

    if (_error != null && _blogs.isEmpty) {
      return ErrorView(message: _error!, errorCode: _errorCode, onRetry: _loadBlogs);
    }

    if (_blogs.isEmpty) {
      return EmptyView(message: AppLocalizations.of(context)?.noArticles ?? '暂无文章');
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
          favoriteService: widget.favoriteService,
          onTap: () => _openDetail(_blogs[index]),
        );
      },
    );
  }
}
