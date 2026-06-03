import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';

class FeaturedCard extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;

  const FeaturedCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
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
            SizedBox(
              width: 140,
              height: 80,
              child: item.img != null && item.img!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.img!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppColors.hairline),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.hairline,
                        child: const Icon(CupertinoIcons.photo,
                            color: AppColors.inkMuted48),
                      ),
                    )
                  : Container(
                      color: AppColors.hairline,
                      child: const Icon(CupertinoIcons.photo,
                          color: AppColors.inkMuted48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppText.finePrintSize,
                      color: AppColors.inkMuted48,
                    ),
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
