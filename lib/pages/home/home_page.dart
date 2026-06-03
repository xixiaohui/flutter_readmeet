import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../models/card_item.dart';
import '../../../services/api_service.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/loading_indicator.dart';
import 'widgets/hero_tile.dart';
import 'widgets/featured_card.dart';
import '../list/list_page.dart';
import '../hot/hot_page.dart';
import '../detail/detail_page.dart';

class HomePage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;

  const HomePage({
    super.key,
    required this.apiService,
    required this.settingsService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CardItem>? _featuredBlogs;
  List<CardItem>? _zhBlogs;
  List<CardItem>? _jaBlogs;
  List<CardItem>? _shakespeareBlogs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
    _loadZh();
    _loadJa();
    _loadShakespeare();
  }

  Future<void> _loadFeatured() async {
    setState(() {
      _error = null;
      _featuredBlogs = null;
    });
    try {
      final result = await widget.apiService.getBlogs(page: 1, pageSize: 5);
      if (!mounted) return;
      setState(() => _featuredBlogs = result.data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _loadZh() async {
    try {
      final results = await widget.apiService.searchBlogs('zh', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _zhBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadJa() async {
    try {
      final results = await widget.apiService.searchBlogs('ja', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _jaBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadShakespeare() async {
    try {
      final results = await widget.apiService.searchAuthor('Shakespeare', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _shakespeareBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
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

  void _openList() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ListPage(
          apiService: widget.apiService,
          settingsService: widget.settingsService,
        ),
      ),
    );
  }

  void _openHotList(String title, String query) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => HotPage(
          apiService: widget.apiService,
          settingsService: widget.settingsService,
          title: title,
          query: query,
        ),
      ),
    );
  }

  void _openHotListAuthor(String title, String query) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => HotPage(
          apiService: widget.apiService,
          settingsService: widget.settingsService,
          title: title,
          query: query,
          useAuthorSearch: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvas,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceBlack,
        border: null,
        padding: EdgeInsetsDirectional.zero,
        leading: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            '情书',
            style: TextStyle(
              fontSize: AppText.taglineSize,
              fontWeight: FontWeight.w600,
              color: AppColors.onDark,
            ),
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(
            CupertinoIcons.search,
            color: AppColors.onDark,
            size: 20,
          ),
        ),
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _loadFeatured);
    }

    if (_featuredBlogs == null) {
      return const LoadingIndicator(message: '加载中...');
    }

    if (_featuredBlogs!.isEmpty) {
      return const EmptyView(message: '暂无文章');
    }

    final hero = _featuredBlogs!.first;
    final featured = _featuredBlogs!.length > 1
        ? _featuredBlogs!.sublist(1)
        : <CardItem>[];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero tile
            HeroTile(item: hero, onTap: () => _openDetail(hero)),

            // Featured cards section
            if (featured.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '最新文章',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: _openList,
                      child: const Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: AppText.bodySize,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (featured.isNotEmpty)
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: featured.length,
                  itemBuilder: (_, i) =>
                      FeaturedCard(item: featured[i], onTap: () => _openDetail(featured[i])),
                ),
              ),

            // ── 中文精选 section ──
            if (_zhBlogs != null && _zhBlogs!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '中文精选',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotList('中文精选', 'zh'),
                      child: const Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: AppText.bodySize,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _zhBlogs!.length,
                  itemBuilder: (_, i) =>
                      FeaturedCard(item: _zhBlogs![i], onTap: () => _openDetail(_zhBlogs![i])),
                ),
              ),
            ],

            // ── 日文精选 section ──
            if (_jaBlogs != null && _jaBlogs!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '日文精选',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotList('日文精选', 'ja'),
                      child: const Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: AppText.bodySize,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _jaBlogs!.length,
                  itemBuilder: (_, i) =>
                      FeaturedCard(item: _jaBlogs![i], onTap: () => _openDetail(_jaBlogs![i])),
                ),
              ),
            ],

            // ── Shakespeare section ──
            if (_shakespeareBlogs != null && _shakespeareBlogs!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shakespeare',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotListAuthor('Shakespeare', 'Shakespeare'),
                      child: const Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: AppText.bodySize,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _shakespeareBlogs!.length,
                  itemBuilder: (_, i) => FeaturedCard(
                    item: _shakespeareBlogs![i],
                    onTap: () => _openDetail(_shakespeareBlogs![i]),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
