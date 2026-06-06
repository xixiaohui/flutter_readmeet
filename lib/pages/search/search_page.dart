import 'package:flutter/cupertino.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/card_item.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../detail/detail_page.dart';
import '../list/widgets/blog_row.dart';

/// Search page with text input and result list.
class SearchPage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const SearchPage({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<CardItem>? _results;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-focus after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await widget.apiService.searchBlogs(query, limit: 30);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _error = e.toString();
      });
    }
  }

  void _openDetail(CardItem item) {
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
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)?.searchArticleHint ?? '搜索文章'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search input
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: CupertinoSearchTextField(
                controller: _controller,
                focusNode: _focusNode,
                placeholder: AppLocalizations.of(context)?.searchArticleHint ?? '搜索文章...',
                onSubmitted: (_) => _search(),
                onSuffixTap: () {
                  _controller.clear();
                  setState(() => _results = null);
                },
              ),
            ),
            // Results
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 16),
      );
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: _search,
      );
    }

    if (_results == null) {
      // Initial state - no search yet
      return Center(
        child: Text(
          AppLocalizations.of(context)?.enterSearchKeyword ?? '请输入搜索关键词',
          style: const TextStyle(
            color: AppColors.inkMuted48,
            fontSize: AppText.bodySize,
          ),
        ),
      );
    }

    if (_results!.isEmpty) {
      return EmptyView(
        message: AppLocalizations.of(context)?.noSearchResults ?? '未找到相关内容',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: _results!.length,
      itemBuilder: (_, i) => BlogRow(
        item: _results![i],
        onTap: () => _openDetail(_results![i]),
        favoriteService: widget.favoriteService,
      ),
    );
  }
}
