import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.surfacePeach,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        middle: Text(
          '阅读设置',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: _s,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            _SectionLabel('字体大小'),
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

            _SectionLabel('行间距'),
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

            _SectionLabel('段落间距'),
            _SliderRow(
              value: _dragParagraphSpacing ?? _s.paragraphSpacing,
              min: 8.0,
              max: 32.0,
              formatLabel: (v) => '${v.round()}',
              onChanged: (v) => setState(() => _dragParagraphSpacing = v),
              onChangeEnd: (v) {
                _s.setParagraphSpacing(v);
                setState(() => _dragParagraphSpacing = null);
              },
            ),

            _SectionLabel('字体样式'),
            _SegmentedRow<String>(
              value: _s.fontFamily ?? 'system',
              options: const ['system', 'serif', 'monospace'],
              labels: ReaderSettingsService.fontFamilyLabels.values.toList(),
              onChanged: (v) => _s.setFontFamily(v == 'system' ? null : v),
            ),

            const SizedBox(height: AppSpacing.md),

            _SectionLabel('阅读背景'),
            _SegmentedRow<String>(
              value: _s.backgroundColor,
              options: ReaderSettingsService.backgroundColorLabels.keys.toList(),
              labels: ReaderSettingsService.backgroundColorLabels.values.toList(),
              onChanged: _s.setBackgroundColor,
            ),

            const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Reusable row widgets ──

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppText.finePrintSize,
          fontWeight: FontWeight.w600,
          color: AppColors.inkMuted48,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

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

class _SegmentedRow<T extends Object> extends StatelessWidget {
  final T value;
  final List<T> options;
  final List<String> labels;
  final ValueChanged<T> onChanged;

  const _SegmentedRow({
    required this.value,
    required this.options,
    required this.labels,
    required this.onChanged,
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
          labels.map(
            (label) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                label,
                style: const TextStyle(fontSize: AppText.finePrintSize),
              ),
            ),
          ),
        ),
        onValueChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
