import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../models/card_item.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/loading_indicator.dart';
import 'widgets/hero_tile.dart';
import 'widgets/featured_card.dart';
import '../list/list_page.dart';
import '../detail/detail_page.dart';

class HomePage extends StatefulWidget {
  final ApiService apiService;

  const HomePage({super.key, required this.apiService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CardItem>? _featuredBlogs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
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

  void _openDetail(CardItem item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) =>
            DetailPage(apiService: widget.apiService, blogId: item.id),
      ),
    );
  }

  void _openList() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ListPage(apiService: widget.apiService),
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

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
