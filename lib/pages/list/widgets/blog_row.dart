import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/card_item.dart';
import '../../../services/favorite_service.dart';
import '../../../theme/app_theme.dart';

class BlogRow extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;
  final String? highlightQuery;
  final FavoriteService? favoriteService;

  const BlogRow({
    super.key,
    required this.item,
    required this.onTap,
    this.highlightQuery,
    this.favoriteService,
  });

  Widget _buildTitle(String title) {
    if (highlightQuery == null || highlightQuery!.isEmpty) {
      return Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.2,
        ),
      );
    }

    final spans = <TextSpan>[];
    final lowerTitle = title.toLowerCase();
    final lowerQuery = highlightQuery!.toLowerCase();
    int start = 0;

    while (start < title.length) {
      final idx = lowerTitle.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: title.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: title.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: title.substring(idx, idx + highlightQuery!.length),
        style: const TextStyle(
          color: AppColors.primary,
          backgroundColor: Color(0x330074FF),
          fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + highlightQuery!.length;
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.2,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          border: Border(
            bottom: BorderSide(color: AppColors.dividerSoft, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: CachedNetworkImage(
                imageUrl: item.displayImg,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 90, height: 90, color: AppColors.hairline,
                ),
                errorWidget: (_, _, _) => CachedNetworkImage(
                  imageUrl: CardItem.defaultImg,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 90, height: 90, color: AppColors.hairline,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 90,
                    height: 90,
                    color: AppColors.hairline,
                    child: const Icon(CupertinoIcons.photo,
                        color: AppColors.inkMuted48),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(item.title),

                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted48,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Author + tag row
                  Row(
                    children: [
                      if (item.authorAvatar != null)
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: item.authorAvatar!,
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Container(
                              width: 18,
                              height: 18,
                              color: AppColors.hairline,
                            ),
                          ),
                        ),
                      if (item.authorAvatar != null)
                        const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.authorName ?? AppLocalizations.of(context)?.unknownAuthor ?? '未知作者',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppText.finePrintSize,
                            color: AppColors.inkMuted48,
                          ),
                        ),
                      ),
                      if (item.tag != null && item.tag!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.canvasParchment,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            item.tag!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.inkMuted48,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (favoriteService != null) ...[
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  favoriteService!.toggle(
                    blogId: item.id,
                    title: item.title,
                    authorName:
                        item.authorName ?? '未知作者',
                    coverImg: item.img,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: ListenableBuilder(
                    listenable: favoriteService!,
                    builder: (_, _) {
                      final isFav =
                          favoriteService!.isFavorited(item.id);
                      return Icon(
                        isFav
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: isFav
                            ? CupertinoColors.destructiveRed
                            : AppColors.inkMuted48,
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
