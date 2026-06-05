import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/reader_settings_service.dart';
import '../../../theme/app_theme.dart';

/// Shows a poster preview sheet and saves the poster PNG to the phone gallery.
class PosterPreview extends StatelessWidget {
  final String quote;
  final String articleTitle;
  final String authorName;
  final String date;
  final int? highlightColor;
  final ReaderSettingsService settings;

  const PosterPreview({
    super.key,
    required this.quote,
    required this.articleTitle,
    required this.authorName,
    required this.date,
    required this.settings,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    final s = settings;
    final quoteSize = s.fontSize + 4;
    final metaSize = s.fontSize - 3;
    final tinySize = s.fontSize - 5;
    final fontFam = s.fontFamily;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvasParchment,
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)?.generatePoster ?? '生成海报'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _onSave(context, key),
          child: Text(AppLocalizations.of(context)?.save ?? '保存',
              style: TextStyle(color: AppColors.primary, fontSize: 17)),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: double.infinity,
              color: AppColors.canvas,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quote block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: highlightColor != null
                              ? Color(highlightColor!)
                              : AppColors.primary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      quote,
                      style: TextStyle(
                        fontSize: quoteSize,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                        height: 1.6,
                        fontFamily: fontFam,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    '${AppLocalizations.of(context)?.posterTitlePrefix ?? '—— '}$articleTitle',
                    style: TextStyle(
                        fontSize: metaSize,
                        color: AppColors.inkMuted48,
                        fontFamily: fontFam),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$authorName · $date',
                    style: TextStyle(
                        fontSize: tinySize,
                        color: AppColors.inkMuted48,
                        fontStyle: FontStyle.italic,
                        fontFamily: fontFam),
                  ),
                  const SizedBox(height: 32),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text('READMEET',
                        style: TextStyle(
                            fontSize: tinySize,
                            color: AppColors.hairline,
                            letterSpacing: 2,
                            fontFamily: fontFam)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSave(BuildContext context, GlobalKey key) async {
    final navigator = Navigator.of(context);
    try {
      await Permission.storage.request();

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      await Gal.putImageBytes(
        bytes,
        name: 'readmeet_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (navigator.context.mounted) {
        showCupertinoDialog(
          context: navigator.context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)?.savedToGallery ?? '已保存'),
            content: Text(AppLocalizations.of(context)?.savedToGalleryMsg ?? '海报已保存到相册'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => navigator.pop(),
                child: Text(AppLocalizations.of(context)?.confirm ?? '确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (navigator.context.mounted) {
        showCupertinoDialog(
          context: navigator.context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)?.saveFailed ?? '保存失败'),
            content: Text(AppLocalizations.of(context)?.checkPermission ?? '请检查相册权限'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => navigator.pop(),
                child: Text(AppLocalizations.of(context)?.confirm ?? '确定'),
              ),
            ],
          ),
        );
      }
    }
  }
}
