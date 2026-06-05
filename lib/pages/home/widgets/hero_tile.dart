import 'package:flutter/cupertino.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';

class HeroTile extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;

  const HeroTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxl,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceTile1,
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.network(
                  item.displayImg,
                  key: ValueKey(item.displayImg),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.network(
                    CardItem.defaultImg,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
                const SizedBox(height: AppSpacing.lg),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppText.displayMdSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),
              if (item.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    item.description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppText.bodySize,
                      fontWeight: FontWeight.w400,
                      color: AppColors.bodyMuted,
                      height: 1.3,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              CupertinoButton(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
                onPressed: onTap,
                child: const Text(
                  '开始阅读',
                  style: TextStyle(
                    fontSize: AppText.bodySize,
                    fontWeight: FontWeight.w400,
                    color: AppColors.canvas,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
