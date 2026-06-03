import 'package:flutter/cupertino.dart';
import '../../../theme/app_theme.dart';

class BlogSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const BlogSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvasParchment,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                CupertinoIcons.search,
                size: 16,
                color: AppColors.inkMuted48,
              ),
            ),
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                placeholder: '搜索文章...',
                placeholderStyle: const TextStyle(
                  color: AppColors.inkMuted48,
                  fontSize: AppText.bodySize,
                ),
                style: const TextStyle(
                  fontSize: AppText.bodySize,
                  color: AppColors.ink,
                ),
                decoration: const BoxDecoration(color: AppColors.canvas),
                padding: EdgeInsets.zero,
                clearButtonMode: OverlayVisibilityMode.editing,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
