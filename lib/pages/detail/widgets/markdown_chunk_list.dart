import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';

class MarkdownChunkList extends StatelessWidget {
  final List<String> chunks;
  final ReaderSettingsService settingsService;

  const MarkdownChunkList({
    super.key,
    required this.chunks,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    if (chunks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, _) {
        final s = settingsService;
        final style = _buildStyle(s);
        return SliverList.separated(
          itemCount: chunks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MarkdownBody(
                data: chunks[index],
                selectable: true,
                styleSheet: style,
              ),
            );
          },
          separatorBuilder: (_, _) => SizedBox(height: s.paragraphSpacing),
        );
      },
    );
  }

  MarkdownStyleSheet _buildStyle(ReaderSettingsService s) {
    final scale = s.fontSize / ReaderSettingsService.defaultFontSize;
    final isDark = s.backgroundColor == 'dark';
    final textColor = isDark ? AppColors.onDark : AppColors.ink;

    return MarkdownStyleSheet(
      p: TextStyle(
        fontSize: s.fontSize,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: s.lineHeight,
        fontFamily: s.fontFamily,
      ),
      pPadding: EdgeInsets.zero,
      h1: TextStyle(
        fontSize: AppText.displayMdSize * scale,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: -0.3,
        height: 1.15,
        fontFamily: s.fontFamily,
      ),
      h1Padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      h2: TextStyle(
        fontSize: AppText.taglineSize * scale,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.2,
        fontFamily: s.fontFamily,
      ),
      h2Padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      h3: TextStyle(
        fontSize: AppText.bodySize * scale,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
        fontFamily: s.fontFamily,
      ),
      h3Padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxs),
      strong: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      blockquote: TextStyle(
        fontSize: s.fontSize,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        color: textColor,
        height: s.lineHeight,
        fontFamily: s.fontFamily,
      ),
      blockquoteDecoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: AppSpacing.md),
      code: TextStyle(
        fontSize: 15,
        backgroundColor: isDark ? AppColors.inkMuted80 : AppColors.canvasParchment,
        color: textColor,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? AppColors.inkMuted80 : AppColors.canvasParchment,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
