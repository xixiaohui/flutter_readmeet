import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/annotation.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';
import '../detail/detail_page.dart';

class GlobalAnnotationsPage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const GlobalAnnotationsPage({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  State<GlobalAnnotationsPage> createState() => _GlobalAnnotationsPageState();
}

class _GlobalAnnotationsPageState extends State<GlobalAnnotationsPage> {
  List<_AnnotationGroup> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _refreshOnVisible() {
    // Reload annotations every time this tab becomes visible.
    // Called from build() via post-frame callback.
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('annotations_'));
      final groups = <_AnnotationGroup>[];

      for (final key in keys) {
        final blogId = key.replaceFirst('annotations_', '');
        final raw = prefs.getString(key);
        if (raw == null) continue;

        final list = (json.decode(raw) as List<dynamic>)
            .map((e) => Annotation.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          groups.add(_AnnotationGroup(blogId: blogId, annotations: list));
        }
      }

      // Sort by most recent annotation first
      groups.sort((a, b) => b.latestTime.compareTo(a.latestTime));

      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reload data every time this tab is selected (build is called on tab switch)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshOnVisible();
    });
    return CupertinoPageScaffold(
      backgroundColor: AppColors.canvasParchment,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.canvas,
        border: null,
        middle: Text('标注列表',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _groups.isEmpty
                ? const Center(
                    child: Text('暂无标注',
                        style: TextStyle(
                            fontSize: AppText.bodySize,
                            color: AppColors.inkMuted48)))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _groups.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) => _GroupCard(
                      group: _groups[i],
                      onTap: (ann) => _openDetail(ann),
                    ),
                  ),
      ),
    );
  }

  void _openDetail(Annotation ann) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DetailPage(
          apiService: widget.apiService,
          blogId: ann.blogId,
          settingsService: widget.settingsService,
          favoriteService: widget.favoriteService,
        ),
      ),
    );
  }
}

class _AnnotationGroup {
  final String blogId;
  final List<Annotation> annotations;

  _AnnotationGroup({required this.blogId, required this.annotations});

  DateTime get latestTime =>
      annotations.map((a) => a.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
}

class _GroupCard extends StatelessWidget {
  final _AnnotationGroup group;
  final ValueChanged<Annotation> onTap;

  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: Text(
              group.annotations.first.blogTitle ?? group.blogId,
              style: const TextStyle(
                  fontSize: AppText.finePrintSize,
                  color: AppColors.inkMuted48,
                  fontWeight: FontWeight.w600),
            ),
          ),
          ...group.annotations.map((ann) => GestureDetector(
                onTap: () => onTap(ann),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Color(ann.color), width: 3),
                    ),
                  ),
                  margin: const EdgeInsets.only(
                      left: AppSpacing.md, top: AppSpacing.xxs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ann.selectedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: AppText.captionSize,
                            color: AppColors.ink,
                            height: 1.3),
                      ),
                      if (ann.hasNote)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('📝 ${ann.notes.first}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: AppText.finePrintSize,
                                  color: AppColors.inkMuted48)),
                        ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
