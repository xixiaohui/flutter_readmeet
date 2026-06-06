import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';

/// Card for the 2-column (iPhone) / 3-column (iPad) grid layout
/// used in the "Latest Articles" section.
class GridCard extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const GridCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.canvasParchment,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover image
            SizedBox(
              height: 120,
              width: double.infinity,
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
            // Text content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Small dot separator
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
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
                  if (item.tag != null && item.tag!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.tag!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMuted48,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
