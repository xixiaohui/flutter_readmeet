import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';

/// Upgraded horizontal-scroll card with larger cover image and
/// circular author avatar. Used in language/author sections.
class HorizontalCard extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;
  static const double cardWidth = 160;
  static const double coverHeight = 140;
  static const double cardHeight = coverHeight + 77;

  const HorizontalCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.canvasParchment,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image (70% of card area)
            SizedBox(
              width: cardWidth,
              height: coverHeight,
              child: CachedNetworkImage(
                imageUrl: item.displayImg,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: AppColors.hairline),
                errorWidget: (_, _, _) => CachedNetworkImage(
                  imageUrl: CardItem.defaultImg,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: AppColors.hairline),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.hairline,
                    child: const Icon(CupertinoIcons.photo, color: AppColors.inkMuted48),
                  ),
                ),
              ),
            ),
            // Title + author with avatar
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Circular author avatar
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.hairline,
                          image: item.authorAvatar != null &&
                                  item.authorAvatar!.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      item.authorAvatar!),
                                  fit: BoxFit.cover,
                                  onError: (_, _) {},
                                )
                              : null,
                        ),
                        child: item.authorAvatar == null ||
                                item.authorAvatar!.isEmpty
                            ? const Icon(CupertinoIcons.person,
                                size: 11, color: AppColors.inkMuted48)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.authorName ??
                              AppLocalizations.of(context)?.unknownAuthor ??
                              '未知作者',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppText.finePrintSize,
                            color: AppColors.inkMuted48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
