import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/card_item.dart';
import '../../../services/api_service.dart';
import '../../../services/favorite_service.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../utils/responsive.dart';
import 'widgets/hero_tile.dart';
import 'widgets/featured_card.dart';
import '../hot/hot_page.dart';
import '../detail/detail_page.dart';

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
  CardItem? _heroBlog;
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
    _loadHero();
    _loadFeatured();
    _loadZh();
    _loadJa();
    _loadShakespeare();
    _loadTwain();
    _loadByron();
    _loadJefferson();
    _loadLincoln();
    _loadSand();
    _loadBurnand();
  }

  Future<void> _loadHero() async {

    const heroId = '23876'; // 徐霞客游记blog_index=23876
    try {
      final blog = await widget.apiService.getHeroBlog(heroId);
      if (!mounted) return;
      setState(() => _heroBlog = blog);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadFeatured() async {
    setState(() {
      _error = null;
      _featuredBlogs = null;
    });
    try {
      final results = await widget.apiService.searchBlogs('最新', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _featuredBlogs = results);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _errorCode = (e is ApiException) ? e.errorCode : null;
      });
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

  Future<void> _loadTwain() async {
    try {
      final results = await widget.apiService.searchAuthor('Twain, Mark', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _twainBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadByron() async {
    try {
      final results = await widget.apiService.searchAuthor('Byron', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _byronBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadJefferson() async {
    try {
      final results = await widget.apiService.searchAuthor('Jefferson, Thomas', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _jeffersonBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadLincoln() async {
    try {
      final results = await widget.apiService.searchAuthor('Lincoln, Abraham', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _lincolnBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadSand() async {
    try {
      final results = await widget.apiService.searchAuthor('Sand, George', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _sandBlogs = results);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _loadBurnand() async {
    try {
      final results = await widget.apiService.searchAuthor('Burnand, F. C.', limit: 6, offset: 0);
      if (!mounted) return;
      setState(() => _burnandBlogs = results);
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.surfaceBlack,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceBlack,
        border: null,
        padding: EdgeInsetsDirectional.zero,
        leading: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            AppLocalizations.of(context)?.appTitle ?? 'ReadMeet',
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
      child: SafeArea(
        top: false,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _featuredBlogs == null && _heroBlog == null) {
      return ErrorView(message: _error!, errorCode: _errorCode, onRetry: _loadFeatured);
    }

    final featured = _featuredBlogs ?? [];

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_heroBlog != null)
              HeroTile(item: _heroBlog!, onTap: () => _openDetail(_heroBlog!))
            else
              const _HeroSkeleton(),

            Container(
              color: AppColors.canvas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardSection(
                    title: AppLocalizations.of(context)?.latestArticles ?? '最新文章',
                    query: '最新',
                    items: featured,
                    isFirst: true,
                  ),

                  if (_zhBlogs != null && _zhBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: AppLocalizations.of(context)?.chineseFeatured ?? '中文精选',
                      query: 'zh',
                      items: _zhBlogs!,
                    ),
                  if (_jaBlogs != null && _jaBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: AppLocalizations.of(context)?.japaneseFeatured ?? '日文精选',
                      query: 'ja',
                      items: _jaBlogs!,
                    ),
                  if (_shakespeareBlogs != null && _shakespeareBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: 'Shakespeare',
                      query: 'Shakespeare',
                      items: _shakespeareBlogs!,
                      useAuthor: true,
                    ),
                  if (_twainBlogs != null && _twainBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: 'Twain, Mark',
                      query: 'Twain, Mark',
                      items: _twainBlogs!,
                      useAuthor: true,
                    ),
                  if (_byronBlogs != null && _byronBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: 'Byron',
                      query: 'Byron',
                      items: _byronBlogs!,
                      useAuthor: true,
                    ),
                  if (_jeffersonBlogs != null && _jeffersonBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: 'Jefferson, Thomas',
                      query: 'Jefferson, Thomas',
                      items: _jeffersonBlogs!,
                      useAuthor: true,
                    ),
                  if (_lincolnBlogs != null && _lincolnBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: 'Lincoln, Abraham',
                      query: 'Lincoln, Abraham',
                      items: _lincolnBlogs!,
                      useAuthor: true,
                    ),
                  if (_sandBlogs != null && _sandBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: 'Sand, George',
                      query: 'Sand, George',
                      items: _sandBlogs!,
                      useAuthor: true,
                    ),
                  if (_burnandBlogs != null && _burnandBlogs!.isNotEmpty)
                    _buildCardSection(
                      title: 'Burnand, F. C.',
                      query: 'Burnand, F. C.',
                      items: _burnandBlogs!,
                      useAuthor: true,
                    ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCardSection({
    required String title,
    required String query,
    required List<CardItem> items,
    bool isFirst = false,
    bool useAuthor = false,
  }) {
    final onOpenList = useAuthor
        ? () => _openHotListAuthor(title, query)
        : () => _openHotList(title, query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst) const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppText.bodySize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              GestureDetector(
                onTap: onOpenList,
                child: Text(
                  AppLocalizations.of(context)?.viewAll ?? '查看全部',
                  style: const TextStyle(
                    fontSize: AppText.bodySize,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildCardList(items),
      ],
    );
  }

  Widget _buildCardList(List<CardItem> items) {
    final isTablet = Responsive.isTablet(context);
    if (isTablet) {
      // iPad: grid layout fills available width
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: items
              .map((item) => FeaturedCard(item: item, onTap: () => _openDetail(item)))
              .toList(),
        ),
      );
    }
    // iPhone: horizontal scroll
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: items.length,
        itemBuilder: (_, i) =>
            FeaturedCard(item: items[i], onTap: () => _openDetail(items[i])),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.heroSkeletonHeight(context),
      color: AppColors.surfaceTile1,
      child: const Center(
        child: CupertinoActivityIndicator(color: AppColors.onDark),
      ),
    );
  }
}
