import 'package:flutter/cupertino.dart';
import '../../models/annotation.dart';
import '../../services/annotation_store.dart';
import '../../theme/app_theme.dart';

/// Lists all annotations for the current article.
/// Accessible from the detail page nav bar.
class AnnotationSummaryPage extends StatelessWidget {
  final AnnotationStore store;
  final VoidCallback? onDeleteAll;

  const AnnotationSummaryPage({
    super.key,
    required this.store,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvasParchment,
      navigationBar: CupertinoNavigationBar(
        middle: Text('我的标注 (${store.count})'),
        trailing: store.count > 0
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _confirmDeleteAll(context),
                child: const Text('清空',
                    style:
                        TextStyle(color: AppColors.inkMuted48, fontSize: 16)),
              )
            : null,
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final anns = store.annotations;
            if (anns.isEmpty) {
              return const Center(
                child: Text('暂无标注',
                    style: TextStyle(
                        fontSize: AppText.bodySize,
                        color: AppColors.inkMuted48)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: anns.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _AnnotationCard(
                annotation: anns[i],
                onDelete: () => store.delete(anns[i].id),
                onEditNote: (note) => store.update(anns[i].id, note: note),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('清空所有标注'),
        content: const Text('此操作不可撤销'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              for (final a in store.annotations.toList()) {
                store.delete(a.id);
              }
              Navigator.pop(context);
              onDeleteAll?.call();
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}

class _AnnotationCard extends StatelessWidget {
  final Annotation annotation;
  final VoidCallback onDelete;
  final ValueChanged<String> onEditNote;

  const _AnnotationCard({
    required this.annotation,
    required this.onDelete,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(
          left: BorderSide(
            color: Color(annotation.color),
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              annotation.selectedText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppText.bodySize,
                color: AppColors.ink,
                height: 1.4,
              ),
            ),
            if (annotation.hasNote) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '📝 ${annotation.note}',
                style: const TextStyle(
                  fontSize: AppText.finePrintSize,
                  color: AppColors.inkMuted48,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  onPressed: () => _editNote(context),
                  child: const Text('笔记',
                      style: TextStyle(
                          fontSize: AppText.finePrintSize,
                          color: AppColors.primary)),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  onPressed: onDelete,
                  child: const Text('删除',
                      style: TextStyle(
                          fontSize: AppText.finePrintSize,
                          color: CupertinoColors.destructiveRed)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editNote(BuildContext context) {
    final controller =
        TextEditingController(text: annotation.note ?? '');
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('笔记'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              onEditNote(controller.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
