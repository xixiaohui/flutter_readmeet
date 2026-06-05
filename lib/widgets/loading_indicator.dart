import 'package:flutter/cupertino.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 16),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message!,
              style: const TextStyle(
                fontSize: AppText.captionSize,
                color: AppColors.inkMuted48,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final String? errorCode;
  final VoidCallback onRetry;
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.errorCode,
  });

  static String? _localizeError(AppLocalizations l10n, String errorCode) {
    return switch (errorCode) {
      'requestFailed' => l10n.requestFailed,
      'articleNotFound' => l10n.articleNotFound,
      'enterSearchKeyword' => l10n.enterSearchKeyword,
      'searchFailed' => l10n.searchFailed,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayMessage = errorCode != null && l10n != null
        ? _localizeError(l10n, errorCode!) ?? message
        : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppText.bodySize,
                color: AppColors.inkMuted48,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CupertinoButton(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onPressed: onRetry,
              child: Text(l10n?.retry ?? '重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String? message;
  const EmptyView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message ?? AppLocalizations.of(context)?.noContent ?? '暂无内容',
        style: const TextStyle(
          fontSize: AppText.bodySize,
          color: AppColors.inkMuted48,
        ),
      ),
    );
  }
}
