import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import '../../l10n/generated/app_localizations.dart';
import '../../services/reader_settings_service.dart';
import '../../theme/app_theme.dart';

class SettingPage extends StatefulWidget {
  final ReaderSettingsService settingsService;

  const SettingPage({super.key, required this.settingsService});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ReaderSettingsService get _s => widget.settingsService;

  double? _dragFontSize;
  double? _dragLineHeight;
  double? _dragParagraphSpacing;

  @override
  void initState() {
    super.initState();
    _s.load();
  }

  void _confirmReset() {
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n?.resetSettings ?? '恢复默认设置'),
        content: Text(l10n?.resetSettingsMsg ?? '所有设置将恢复为默认值'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.cancel ?? '取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              if (mounted) _s.resetToDefaults();
            },
            child: Text(l10n?.confirm ?? '确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.surfacePeach,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        middle: Text(
          l10n?.readingSettings ?? '阅读设置',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _confirmReset,
          child: Text(
            l10n?.reset ?? '恢复',
            style: const TextStyle(
              fontSize: AppText.bodySize,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── 实时预览 ──
            _PreviewCard(settings: _s),
            const SizedBox(height: AppSpacing.md),

            // ── 排版卡片 ──
            _SettingsCard(
              title: l10n?.typography ?? '排版',
              children: [
                _SliderRow(
                  value: _dragFontSize ?? _s.fontSize,
                  min: 14.0,
                  max: 24.0,
                  formatLabel: (v) => '${v.round()}',
                  onChanged: (v) => setState(() => _dragFontSize = v),
                  onChangeEnd: (v) {
                    _s.setFontSize(v);
                    setState(() => _dragFontSize = null);
                  },
                ),
                const _CardDivider(),
                _SliderRow(
                  value: _dragLineHeight ?? _s.lineHeight,
                  min: 1.2,
                  max: 2.4,
                  formatLabel: (v) => v.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _dragLineHeight = v),
                  onChangeEnd: (v) {
                    _s.setLineHeight(v);
                    setState(() => _dragLineHeight = null);
                  },
                ),
                const _CardDivider(),
                _SliderRow(
                  value: _dragParagraphSpacing ?? _s.paragraphSpacing,
                  min: 8.0,
                  max: 32.0,
                  formatLabel: (v) => '${v.round()}',
                  onChanged: (v) =>
                      setState(() => _dragParagraphSpacing = v),
                  onChangeEnd: (v) {
                    _s.setParagraphSpacing(v);
                    setState(() => _dragParagraphSpacing = null);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── 外观卡片 ──
            _SettingsCard(
              title: l10n?.appearance ?? '外观',
              children: [
                _SegmentedRow<String>(
                  value: _s.fontFamily ?? 'system',
                  options: const ['system', 'serif', 'monospace'],
                  labels: [
                    l10n?.systemDefault ?? '系统默认',
                    l10n?.serif ?? '宋体',
                    l10n?.monospace ?? '等宽',
                  ],
                  labelFontFamilies: const [null, 'serif', 'monospace'],
                  onChanged: (v) =>
                      _s.setFontFamily(v == 'system' ? null : v),
                ),
                const SizedBox(height: AppSpacing.md),
                _SegmentedRow<String>(
                  value: _s.backgroundColor,
                  options: const ['auto', 'white', 'parchment', 'dark'],
                  labels: [
                    l10n?.auto ?? '自动',
                    l10n?.white ?? '白色',
                    l10n?.parchment ?? '米色',
                    l10n?.dark ?? '深色',
                  ],
                  onChanged: _s.setBackgroundColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── 语言卡片 ──
            _SettingsCard(
              title: l10n?.language ?? '语言',
              children: [
                _CheckRow(
                  label: l10n?.followSystem ?? '跟随系统',
                  selected: _s.localeCode == null,
                  onTap: () => _s.setLocale(null),
                ),
                const _CardDivider(),
                _CheckRow(
                  label: l10n?.chineseSimplified ?? '中文简体',
                  selected: _s.localeCode == 'zh',
                  onTap: () => _s.setLocale('zh'),
                ),
                const _CardDivider(),
                _CheckRow(
                  label: l10n?.chineseTraditional ?? '中文繁體',
                  selected: _s.localeCode == 'zh_Hant',
                  onTap: () => _s.setLocale('zh_Hant'),
                ),
                const _CardDivider(),
                _CheckRow(
                  label: l10n?.japaneseLang ?? '日本語',
                  selected: _s.localeCode == 'ja',
                  onTap: () => _s.setLocale('ja'),
                ),
                const _CardDivider(),
                _CheckRow(
                  label: 'English',
                  selected: _s.localeCode == 'en',
                  onTap: () => _s.setLocale('en'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ── 实时预览卡片 ──

class _PreviewCard extends StatelessWidget {
  final ReaderSettingsService settings;
  const _PreviewCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final bg = settings.backgroundColor;
        final fontFamily = settings.fontFamily;
        final effectiveBg = bg == 'auto'
            ? (MediaQuery.of(context).platformBrightness == Brightness.dark ? 'dark' : 'white')
            : bg;
        final bgColor = switch (effectiveBg) {
          'white' => AppColors.canvas,
          'dark' => AppColors.surfaceBlack,
          _ => AppColors.canvasParchment,
        };
        final textColor =
            effectiveBg == 'dark' ? AppColors.onDark : AppColors.ink;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            '天地玄黄，宇宙洪荒。\nThe quick brown fox jumps over the lazy dog.\n日月盈昃，辰宿列张。',
            style: TextStyle(
              fontSize: settings.fontSize,
              height: settings.lineHeight,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
        );
      },
    );
  }
}

// ── 卡片容器 ──

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppText.finePrintSize,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMuted48,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ── 卡片内分隔线 ──

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Divider(height: 1, color: AppColors.hairline),
    );
  }
}

// ── 滑块行 ──

class _SliderRow extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String Function(double) formatLabel;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const _SliderRow({
    required this.value,
    required this.min,
    required this.max,
    required this.formatLabel,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: CupertinoSlider(
              value: value,
              min: min,
              max: max,
              activeColor: AppColors.primary,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              formatLabel(value),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: AppText.bodySize,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 分段选择行 ──

class _SegmentedRow<T extends Object> extends StatelessWidget {
  final T value;
  final List<T> options;
  final List<String> labels;
  final ValueChanged<T> onChanged;
  final List<String?>? labelFontFamilies;

  const _SegmentedRow({
    required this.value,
    required this.options,
    required this.labels,
    required this.onChanged,
    this.labelFontFamilies,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: value,
        backgroundColor: AppColors.canvasParchment,
        thumbColor: AppColors.canvas,
        padding: const EdgeInsets.all(2),
        children: Map.fromIterables(
          options,
          List.generate(labels.length, (i) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: AppText.finePrintSize,
                  fontFamily: labelFontFamilies != null &&
                          i < labelFontFamilies!.length
                      ? labelFontFamilies![i]
                      : null,
                ),
              ),
            );
          }),
        ),
        onValueChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

// ── 勾选行（语言选择等） ──

class _CheckRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CheckRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: AppText.bodySize,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (selected)
              const Icon(
                CupertinoIcons.check_mark,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
