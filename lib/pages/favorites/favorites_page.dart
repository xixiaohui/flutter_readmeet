import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/services.dart';
import '../../models/author.dart';
import '../../models/card_item.dart';
import '../../models/favorite.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import '../detail/detail_page.dart';
import '../list/widgets/blog_row.dart';

class FavoritesPage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const FavoritesPage({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    widget.favoriteService.load();
  }

  void _openDetail(Favorite fav) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (_) => DetailPage(
        apiService: widget.apiService,
        blogId: fav.blogId,
        settingsService: widget.settingsService,
          favoriteService: widget.favoriteService,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvas,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.canvasParchment,
        border: null,
        middle: Text(
            AppLocalizations.of(context)?.myFavorites ?? '我的收藏',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.ink)),
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.favoriteService,
          builder: (context, _) {
            final favs = widget.favoriteService.favorites;
            if (favs.isEmpty) {
              return Center(
                child: Text(
                    AppLocalizations.of(context)?.noFavorites ?? '暂无收藏',
                    style: const TextStyle(
                        fontSize: AppText.bodySize,
                        color: AppColors.inkMuted48)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              itemCount: favs.length,
              separatorBuilder: (_, _a) => const Divider(height: 0.5),
              itemBuilder: (_, i) {
                final fav = favs[i];
                final item = CardItem(
                  id: fav.blogId,
                  title: fav.title,
                  authors: [Author(name: fav.authorName)],
                  img: fav.coverImg,
                );
                return BlogRow(
                  item: item,
                  onTap: () => _openDetail(fav),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
