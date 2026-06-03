import 'package:flutter/cupertino.dart';
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
  final VoidCallback onRetry;
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
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
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;
  const EmptyView({super.key, this.message = '暂无内容'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: AppText.bodySize,
          color: AppColors.inkMuted48,
        ),
      ),
    );
  }
}
