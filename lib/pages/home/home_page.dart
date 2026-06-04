import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../models/card_item.dart';
import '../../../services/api_service.dart';
import '../../../services/favorite_service.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/loading_indicator.dart';
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
    try {
      final blog = await widget.apiService.getHeroBlog('23876');
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
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.surfaceBlack,
        border: null,
        padding: EdgeInsetsDirectional.zero,
        leading: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'ReadMeet',
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
    if (_error != null && _featuredBlogs == null && _heroBlog == null) {
      return ErrorView(message: _error!, onRetry: _loadFeatured);
    }

    final featured = _featuredBlogs ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero tile — shows skeleton while loading
          if (_heroBlog != null)
            HeroTile(item: _heroBlog!, onTap: () => _openDetail(_heroBlog!))
          else
            const _HeroSkeleton(),

          // ── Below-hero content (white background) ──
          Container(
            color: AppColors.canvas,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          onTap: () => _openHotList('最新文章', '最新'),
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

            // ── Twain, Mark section ──
            if (_twainBlogs != null && _twainBlogs!.isNotEmpty) ...[
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
                      'Twain, Mark',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotListAuthor('Twain, Mark', 'Twain, Mark'),
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
                  itemCount: _twainBlogs!.length,
                  itemBuilder: (_, i) => FeaturedCard(
                    item: _twainBlogs![i],
                    onTap: () => _openDetail(_twainBlogs![i]),
                  ),
                ),
              ),
            ],

            // ── Byron section ──
            if (_byronBlogs != null && _byronBlogs!.isNotEmpty) ...[
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
                      'Byron',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotListAuthor('Byron', 'Byron'),
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
                  itemCount: _byronBlogs!.length,
                  itemBuilder: (_, i) => FeaturedCard(
                    item: _byronBlogs![i],
                    onTap: () => _openDetail(_byronBlogs![i]),
                  ),
                ),
              ),
            ],

            // ── Jefferson, Thomas section ──
            if (_jeffersonBlogs != null && _jeffersonBlogs!.isNotEmpty) ...[
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
                      'Jefferson, Thomas',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotListAuthor('Jefferson, Thomas', 'Jefferson, Thomas'),
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
                  itemCount: _jeffersonBlogs!.length,
                  itemBuilder: (_, i) => FeaturedCard(
                    item: _jeffersonBlogs![i],
                    onTap: () => _openDetail(_jeffersonBlogs![i]),
                  ),
                ),
              ),
            ],

            // ── Lincoln, Abraham section ──
            if (_lincolnBlogs != null && _lincolnBlogs!.isNotEmpty) ...[
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
                      'Lincoln, Abraham',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotListAuthor('Lincoln, Abraham', 'Lincoln, Abraham'),
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
                  itemCount: _lincolnBlogs!.length,
                  itemBuilder: (_, i) => FeaturedCard(
                    item: _lincolnBlogs![i],
                    onTap: () => _openDetail(_lincolnBlogs![i]),
                  ),
                ),
              ),
            ],

            // ── Sand, George section ──
            if (_sandBlogs != null && _sandBlogs!.isNotEmpty) ...[
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
                      'Sand, George',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotListAuthor('Sand, George', 'Sand, George'),
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
                  itemCount: _sandBlogs!.length,
                  itemBuilder: (_, i) => FeaturedCard(
                    item: _sandBlogs![i],
                    onTap: () => _openDetail(_sandBlogs![i]),
                  ),
                ),
              ),
            ],

            // ── Burnand, F. C. section ──
            if (_burnandBlogs != null && _burnandBlogs!.isNotEmpty) ...[
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
                      'Burnand, F. C.',
                      style: TextStyle(
                        fontSize: AppText.bodySize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openHotListAuthor('Burnand, F. C.', 'Burnand, F. C.'),
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
                  itemCount: _burnandBlogs!.length,
                  itemBuilder: (_, i) => FeaturedCard(
                    item: _burnandBlogs![i],
                    onTap: () => _openDetail(_burnandBlogs![i]),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: AppColors.surfaceTile1,
      child: const Center(
        child: CupertinoActivityIndicator(color: AppColors.onDark),
      ),
    );
  }
}
