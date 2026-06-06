import 'package:flutter/cupertino.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

/// Reusable section header with title and optional "view all" action.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.padding = const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppText.bodySize,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                AppLocalizations.of(context)?.viewAll ?? '查看全部',
                style: const TextStyle(
                  fontSize: AppText.bodySize,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
