import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/services.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/card_item.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/grid_card.dart';
import 'widgets/horizontal_card.dart';
import '../hot/hot_page.dart';
import '../detail/detail_page.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const HomePage({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Hero carousel articles (replaces single hero)
  List<CardItem>? _heroItems;
  List<CardItem>? _featuredBlogs;
  List<CardItem>? _zhBlogs;
  List<CardItem>? _jaBlogs;
  List<CardItem>? _shakespeareBlogs;
  List<CardItem>? _twainBlogs;
  List<CardItem>? _byronBlogs;
  List<CardItem>? _jeffersonBlogs;
  List<CardItem>? _lincolnBlogs;
  List<CardItem>? _sandBlogs;
  List<CardItem>? _burnandBlogs;

  String? _error;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _error = null;
    });

    try {
      final results = await Future.wait([
        _safeFetch(() => widget.apiService.getBlogs(page: 1, pageSize: 5).then((r) => r.data)),
        _safeFetch(() => widget.apiService.searchBlogs('最新', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchBlogs('zh', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchBlogs('ja', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchAuthor('Shakespeare', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchAuthor('Twain, Mark', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchAuthor('Byron', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchAuthor('Jefferson, Thomas', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchAuthor('Lincoln, Abraham', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchAuthor('Sand, George', limit: 6, offset: 0)),
        _safeFetch(() => widget.apiService.searchAuthor('Burnand, F. C.', limit: 6, offset: 0)),
      ]);

      if (!mounted) return;
      setState(() {
        _heroItems = results[0];
        _featuredBlogs = results[1];
        _zhBlogs = results[2];
        _jaBlogs = results[3];
        _shakespeareBlogs = results[4];
        _twainBlogs = results[5];
        _byronBlogs = results[6];
        _jeffersonBlogs = results[7];
        _lincolnBlogs = results[8];
        _sandBlogs = results[9];
        _burnandBlogs = results[10];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _errorCode = (e is ApiException) ? e.errorCode : null;
      });
    }
  }

  /// Helper to safely fetch a list, returning empty list on error.
  Future<List<CardItem>> _safeFetch(Future<List<CardItem>> Function() fetcher) async {
    try {
      return await fetcher();
    } catch (_) {
      return [];
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

  void _openHotList(String title, String query) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => HotPage(
          apiService: widget.apiService,
          settingsService: widget.settingsService,
          favoriteService: widget.favoriteService,
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
          favoriteService: widget.favoriteService,
          title: title,
          query: query,
          useAuthorSearch: true,
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => SearchPage(
          apiService: widget.apiService,
          settingsService: widget.settingsService,
          favoriteService: widget.favoriteService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.surfaceBlack,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceBlack,
        border: null,
        padding: EdgeInsetsDirectional.zero,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            AppLocalizations.of(context)?.appTitle ?? 'ReadMeet',
            style: const TextStyle(
              fontSize: AppText.taglineSize,
              fontWeight: FontWeight.w600,
              color: AppColors.onDark,
            ),
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _openSearch,
            child: const Icon(
              CupertinoIcons.search,
              color: AppColors.onDark,
              size: 20,
            ),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _heroItems == null) {
      return ErrorView(
        message: _error!,
        errorCode: _errorCode,
        onRetry: _loadAll,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Carousel ──
            if (_heroItems != null && _heroItems!.isNotEmpty)
              HeroCarousel(
                items: _heroItems!,
                onTap: _openDetail,
              )
            else
              ShimmerHero(height: Responsive.heroSkeletonHeight(context)),

            // ── Content Sections ──
            Container(
              color: AppColors.canvas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Latest Articles (grid layout) ──
                  const SizedBox(height: AppSpacing.md),
                  _buildGridSection(
                    title: AppLocalizations.of(context)?.latestArticles ?? '最新文章',
                    query: '最新',
                    items: _featuredBlogs,
                  ),

                  // ── Language & Author Sections (horizontal scroll) ──
                  if (_zhBlogs != null && _zhBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: AppLocalizations.of(context)?.chineseFeatured ?? '中文精选',
                      query: 'zh',
                      items: _zhBlogs!,
                    ),
                  ],
                  if (_jaBlogs != null && _jaBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: AppLocalizations.of(context)?.japaneseFeatured ?? '日文精选',
                      query: 'ja',
                      items: _jaBlogs!,
                    ),
                  ],
                  if (_shakespeareBlogs != null && _shakespeareBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: 'Shakespeare',
                      query: 'Shakespeare',
                      items: _shakespeareBlogs!,
                      useAuthor: true,
                    ),
                  ],
                  if (_twainBlogs != null && _twainBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: 'Twain, Mark',
                      query: 'Twain, Mark',
                      items: _twainBlogs!,
                      useAuthor: true,
                    ),
                  ],
                  if (_byronBlogs != null && _byronBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: 'Byron',
                      query: 'Byron',
                      items: _byronBlogs!,
                      useAuthor: true,
                    ),
                  ],
                  if (_jeffersonBlogs != null && _jeffersonBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: 'Jefferson, Thomas',
                      query: 'Jefferson, Thomas',
                      items: _jeffersonBlogs!,
                      useAuthor: true,
                    ),
                  ],
                  if (_lincolnBlogs != null && _lincolnBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: 'Lincoln, Abraham',
                      query: 'Lincoln, Abraham',
                      items: _lincolnBlogs!,
                      useAuthor: true,
                    ),
                  ],
                  if (_sandBlogs != null && _sandBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: 'Sand, George',
                      query: 'Sand, George',
                      items: _sandBlogs!,
                      useAuthor: true,
                    ),
                  ],
                  if (_burnandBlogs != null && _burnandBlogs!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildHorizontalSection(
                      title: 'Burnand, F. C.',
                      query: 'Burnand, F. C.',
                      items: _burnandBlogs!,
                      useAuthor: true,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid Section (Latest Articles) ──

  Widget _buildGridSection({
    required String title,
    required String query,
    List<CardItem>? items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onViewAll: () => _openHotList(title, query),
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
        ),
        if (items != null)
          _buildGrid(items)
        else
          _buildGridSkeleton(),
      ],
    );
  }

  Widget _buildGrid(List<CardItem> items) {
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isTablet ? 3 : 2;
    // Tablet cards are wider with 3 columns; a higher aspect ratio keeps
    // them from becoming too tall relative to their natural content height.
    final childAspectRatio = isTablet ? 1.10 : 0.7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => GridCard(
          item: items[i],
          onTap: () => _openDetail(items[i]),
        ),
      ),
    );
  }

  Widget _buildGridSkeleton() {
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isTablet ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const ShimmerGridCard(),
      ),
    );
  }

  // ── Horizontal Section (Language / Author) ──

  Widget _buildHorizontalSection({
    required String title,
    required String query,
    required List<CardItem> items,
    bool useAuthor = false,
  }) {
    final onViewAll = useAuthor
        ? () => _openHotListAuthor(title, query)
        : () => _openHotList(title, query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onViewAll: onViewAll,
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xs),
        ),
        SizedBox(
          height: HorizontalCard.cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (_, i) => HorizontalCard(
              item: items[i],
              onTap: () => _openDetail(items[i]),
            ),
          ),
        ),
        // Fade hint at right edge
        if (items.length > 3)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 32,
              height: 17,
              margin: const EdgeInsets.only(right: AppSpacing.lg),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [AppColors.canvas, Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
