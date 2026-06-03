import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';

class BlogRow extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;

  const BlogRow({super.key, required this.item, required this.onTap});

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
              child: item.img != null && item.img!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.img!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        width: 90,
                        height: 90,
                        color: AppColors.hairline,
                      ),
                      errorWidget: (_, _, _) => Container(
                        width: 90,
                        height: 90,
                        color: AppColors.hairline,
                        child: const Icon(CupertinoIcons.photo,
                            color: AppColors.inkMuted48),
                      ),
                    )
                  : Container(
                      width: 90,
                      height: 90,
                      color: AppColors.hairline,
                      child: const Icon(CupertinoIcons.photo,
                          color: AppColors.inkMuted48),
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.2,
                    ),
                  ),
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
                          item.authorName,
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
          ],
        ),
      ),
    );
  }
}
