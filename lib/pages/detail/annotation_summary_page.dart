import 'package:flutter/cupertino.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/annotation.dart';
import '../../services/annotation_store.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/poster_generator.dart';

/// Lists all annotations for the current article.
/// Accessible from the detail page nav bar.
class AnnotationSummaryPage extends StatelessWidget {
  final AnnotationStore store;
  final ReaderSettingsService settings;
  final String articleTitle;
  final String authorName;
  final String date;
  final VoidCallback? onDeleteAll;

  const AnnotationSummaryPage({
    super.key,
    required this.store,
    required this.settings,
    required this.articleTitle,
    required this.authorName,
    required this.date,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final s = settings;
    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvasParchment,
      navigationBar: CupertinoNavigationBar(
        middle: Text('$articleTitle · ${store.count}',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: s.fontSize,
                color: AppColors.ink)),
        trailing: store.count > 0
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _confirmDeleteAll(context),
                child: Text(AppLocalizations.of(context)?.clear ?? '清空',
                    style: TextStyle(
                        color: AppColors.inkMuted48,
                        fontSize: s.fontSize - 1)),
              )
            : null,
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final anns = store.annotations;
            if (anns.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)?.noAnnotations ?? '暂无标注',
                    style: TextStyle(
                        fontSize: s.fontSize,
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
                settings: s,
                articleTitle: articleTitle,
                authorName: authorName,
                date: date,
                onDelete: () => store.delete(anns[i].id),
                onEditNotes: (notes) =>
                    store.update(anns[i].id, notes: notes),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)?.confirmDeleteAll ?? '清空所有标注'),
        content: Text(AppLocalizations.of(context)?.irreversible ?? '此操作不可撤销'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              if (navigator.canPop()) navigator.pop();
            },
            child: Text(AppLocalizations.of(context)?.cancel ?? '取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              if (navigator.canPop()) navigator.pop();
              for (final a in store.annotations.toList()) {
                store.delete(a.id);
              }
              onDeleteAll?.call();
            },
            child: Text(AppLocalizations.of(context)?.clear ?? '清空'),
          ),
        ],
      ),
    );
  }
}

class _AnnotationCard extends StatefulWidget {
  final Annotation annotation;
  final ReaderSettingsService settings;
  final String articleTitle;
  final String authorName;
  final String date;
  final VoidCallback onDelete;
  final ValueChanged<List<String>> onEditNotes;

  const _AnnotationCard({
    required this.annotation,
    required this.settings,
    required this.articleTitle,
    required this.authorName,
    required this.date,
    required this.onDelete,
    required this.onEditNotes,
  });

  @override
  State<_AnnotationCard> createState() => _AnnotationCardState();
}

class _AnnotationCardState extends State<_AnnotationCard> {
  @override
  Widget build(BuildContext context) {
    final ann = widget.annotation;
    final s = widget.settings;
    final bodySize = s.fontSize;
    final smallSize = s.fontSize - 3;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(
          left: BorderSide(color: Color(ann.color), width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ann.selectedText,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.ink,
                    height: 1.4)),
            if (ann.hasNote) ...[
              const SizedBox(height: AppSpacing.xs),
              ...ann.notes.map((n) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text('📝 $n',
                        style: TextStyle(
                            fontSize: smallSize,
                            color: AppColors.inkMuted48)),
                  )),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  onPressed: () => _openPoster(context),
                  child: Text(AppLocalizations.of(context)?.poster ?? '海报',
                      style: TextStyle(
                          fontSize: smallSize,
                          color: AppColors.primary)),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  onPressed: () => _addNote(context),
                  child: Text(AppLocalizations.of(context)?.note ?? '笔记',
                      style: TextStyle(
                          fontSize: smallSize,
                          color: AppColors.primary)),
                ),
                if (ann.hasNote)
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    onPressed: () => _clearNotes(),
                    child: Text(AppLocalizations.of(context)?.clearNotes ?? '清空笔记',
                        style: TextStyle(
                            fontSize: smallSize,
                            color: AppColors.inkMuted48)),
                  ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  onPressed: widget.onDelete,
                  child: Text(AppLocalizations.of(context)?.delete ?? '删除',
                      style: TextStyle(
                          fontSize: smallSize,
                          color: CupertinoColors.destructiveRed)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNote(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final controller = TextEditingController();
    showCupertinoDialog(
      context: navigator.context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)?.addNote ?? '添加笔记'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            placeholder: AppLocalizations.of(context)?.writeNote ?? '写下你的想法...',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              if (navigator.canPop()) navigator.pop();
            },
            child: Text(AppLocalizations.of(context)?.cancel ?? '取消'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              final text = controller.text.trim();
              if (navigator.canPop()) navigator.pop();
              if (text.isNotEmpty) {
                final updated = [
                  ...widget.annotation.notes,
                  text,
                ];
                widget.onEditNotes(updated);
              }
            },
            child: Text(AppLocalizations.of(context)?.save ?? '保存'),
          ),
        ],
      ),
    );
  }

  void _openPoster(BuildContext context) {
    final ann = widget.annotation;
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (_) => PosterPreview(
        quote: ann.selectedText,
        articleTitle: widget.articleTitle,
        authorName: widget.authorName,
        date: widget.date,
        settings: widget.settings,
        highlightColor: ann.color,
      ),
    ));
  }

  void _clearNotes() {
    widget.onEditNotes([]);
  }
}
