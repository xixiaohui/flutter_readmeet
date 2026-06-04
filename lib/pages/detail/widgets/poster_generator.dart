import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../theme/app_theme.dart';

/// Shows a poster preview sheet and saves the poster PNG to the phone gallery.
class PosterPreview extends StatelessWidget {
  final String quote;
  final String articleTitle;
  final String authorName;
  final String date;
  final int? highlightColor;

  const PosterPreview({
    super.key,
    required this.quote,
    required this.articleTitle,
    required this.authorName,
    required this.date,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvasParchment,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('生成海报'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _onSave(context, key),
          child: const Text('保存',
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
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    '—— $articleTitle',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.inkMuted48),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$authorName · $date',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted48,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 32),

                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text('READMEET',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.hairline,
                            letterSpacing: 2)),
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
    try {
      // Request permission
      await Permission.storage.request();

      // Capture the RepaintBoundary
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        name: 'readmeet_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );

      if (context.mounted) {
        final success = result['isSuccess'] == true;
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(success ? '已保存' : '保存失败'),
            content: Text(success ? '海报已保存到相册' : '请检查存储权限'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('保存失败'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    }
  }
}
