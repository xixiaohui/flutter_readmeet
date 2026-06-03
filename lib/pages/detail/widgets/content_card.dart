import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';

class ContentHeader extends StatelessWidget {
  final CardItem blog;
  final bool hasCover;

  const ContentHeader({
    super.key,
    required this.blog,
    required this.hasCover,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(blog.createdAt);

    return Transform.translate(
      offset: Offset(0, hasCover ? -12 : 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground,
            context,
          ),
          borderRadius: hasCover
              ? const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg))
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (blog.tag != null && blog.tag!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  blog.tag!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.canvas,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              blog.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.15,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (blog.authorAvatar != null)
                  ClipOval(
                    child: Image.network(
                      blog.authorAvatar!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 24,
                        height: 24,
                        color: AppColors.hairline,
                      ),
                    ),
                  ),
                if (blog.authorAvatar != null)
                  const SizedBox(width: 8),
                Text(
                  blog.authorName,
                  style: const TextStyle(
                    fontSize: AppText.captionSize,
                    color: AppColors.inkMuted48,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '· $date',
                    style: const TextStyle(
                      fontSize: AppText.finePrintSize,
                      color: AppColors.inkMuted48,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
