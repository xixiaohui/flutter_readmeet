# Reader Settings Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a settings page that lets users customize reader typography (font size, line height, paragraph spacing, font family, background color), persisted via shared_preferences and applied immediately in the article reader.

**Architecture:** `ReaderSettingsService` (ChangeNotifier + shared_preferences) is the single source of truth. `SettingPage` writes settings through it. `MarkdownChunkList` reads settings via `ListenableBuilder` to rebuild the `MarkdownStyleSheet` reactively. `DetailPage` applies the background color. `app.dart` gains a 3rd tab.

**Tech Stack:** Flutter/Dart, `shared_preferences` (already a dependency), `flutter_markdown` (already a dependency), Cupertino widgets.

---

### File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `lib/services/reader_settings_service.dart` | Persist/load reader settings, notify listeners |
| Create | `lib/pages/setting/setting_page.dart` | Settings UI with sliders and segmented controls |
| Modify | `lib/pages/detail/widgets/markdown_chunk_list.dart` | Build MarkdownStyleSheet from live settings |
| Modify | `lib/pages/detail/detail_page.dart` | Apply background color from settings |
| Modify | `lib/app.dart` | Add 3rd tab "设置" |
| Create | `test/reader_settings_service_test.dart` | Unit tests for service |
| Create | `test/setting_page_test.dart` | Widget test for settings page |

---

### Task 1: ReaderSettingsService

**Files:**
- Create: `lib/services/reader_settings_service.dart`

- [ ] **Step 1: Write the service class**

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderSettingsService extends ChangeNotifier {
  // Storage keys
  static const _keyFontSize = 'reader_font_size';
  static const _keyLineHeight = 'reader_line_height';
  static const _keyParagraphSpacing = 'reader_paragraph_spacing';
  static const _keyFontFamily = 'reader_font_family';
  static const _keyBackgroundColor = 'reader_background_color';

  // Defaults matching existing AppText / AppSpacing design tokens
  static const double defaultFontSize = 17.0;
  static const double defaultLineHeight = 1.8;
  static const double defaultParagraphSpacing = 17.0;
  static const String defaultBackgroundColor = 'parchment';

  double _fontSize = defaultFontSize;
  double _lineHeight = defaultLineHeight;
  double _paragraphSpacing = defaultParagraphSpacing;
  String? _fontFamily = null; // null = system default
  String _backgroundColor = defaultBackgroundColor;

  // Getters
  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  double get paragraphSpacing => _paragraphSpacing;
  String? get fontFamily => _fontFamily;
  String get backgroundColor => _backgroundColor;

  // Human-readable labels for UI
  static const Map<String?, String> fontFamilyLabels = {
    null: '系统默认',
    'serif': '宋体',
    'monospace': '等宽',
  };

  static const Map<String, String> backgroundColorLabels = {
    'white': '白色',
    'parchment': '米色',
    'dark': '深色',
  };

  /// Load persisted settings (or use defaults on first run / error).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontSize = prefs.getDouble(_keyFontSize) ?? defaultFontSize;
      _lineHeight = prefs.getDouble(_keyLineHeight) ?? defaultLineHeight;
      _paragraphSpacing =
          prefs.getDouble(_keyParagraphSpacing) ?? defaultParagraphSpacing;
      _fontFamily = prefs.getString(_keyFontFamily);
      _backgroundColor =
          prefs.getString(_keyBackgroundColor) ?? defaultBackgroundColor;
      notifyListeners();
    } catch (_) {
      // Fall back to defaults silently
    }
  }

  // --- Setters (persist + notify) ---

  Future<void> setFontSize(double value) async {
    if (value == _fontSize) return;
    _fontSize = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLineHeight(double value) async {
    if (value == _lineHeight) return;
    _lineHeight = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setParagraphSpacing(double value) async {
    if (value == _paragraphSpacing) return;
    _paragraphSpacing = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setFontFamily(String? value) async {
    if (value == _fontFamily) return;
    _fontFamily = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setBackgroundColor(String value) async {
    if (value == _backgroundColor) return;
    _backgroundColor = value;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSize, _fontSize);
      await prefs.setDouble(_keyLineHeight, _lineHeight);
      await prefs.setDouble(_keyParagraphSpacing, _paragraphSpacing);
      if (_fontFamily != null) {
        await prefs.setString(_keyFontFamily, _fontFamily!);
      } else {
        await prefs.remove(_keyFontFamily);
      }
      await prefs.setString(_keyBackgroundColor, _backgroundColor);
    } catch (_) {
      // Silently ignore persistence failures
    }
  }
}
```

This is the complete file — no further steps needed for the service itself. The class extends `ChangeNotifier`, loads on-demand, and each setter does an early-return if the value hasn't changed, then notifies listeners and persists.

---

### Task 2: SettingPage

**Files:**
- Create: `lib/pages/setting/setting_page.dart`

- [ ] **Step 1: Write the setting page widget**

```dart
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

  @override
  void initState() {
    super.initState();
    // Ensure settings are loaded from disk
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            // ── Typography section ──
            _SectionLabel('字体大小'),
            _SliderRow(
              value: _s.fontSize,
              min: 14.0,
              max: 24.0,
              formatLabel: (v) => '${v.round()}',
              onChanged: _s.setFontSize,
            ),

            _SectionLabel('行间距'),
            _SliderRow(
              value: _s.lineHeight,
              min: 1.2,
              max: 2.4,
              formatLabel: (v) => v.toStringAsFixed(1),
              onChanged: _s.setLineHeight,
            ),

            _SectionLabel('段落间距'),
            _SliderRow(
              value: _s.paragraphSpacing,
              min: 8.0,
              max: 32.0,
              formatLabel: (v) => '${v.round()}',
              onChanged: _s.setParagraphSpacing,
            ),

            _SectionLabel('字体样式'),
            _SegmentedRow<String?>(
              value: _s.fontFamily,
              options: const [null, 'serif', 'monospace'],
              labels: const ['系统默认', '宋体', '等宽'],
              onChanged: _s.setFontFamily,
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Background section ──
            _SectionLabel('阅读背景'),
            _SegmentedRow<String>(
              value: _s.backgroundColor,
              options: const ['white', 'parchment', 'dark'],
              labels: const ['白色', '米色', '深色'],
              onChanged: _s.setBackgroundColor,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
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

  const _SliderRow({
    required this.value,
    required this.min,
    required this.max,
    required this.formatLabel,
    required this.onChanged,
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

class _SegmentedRow<T> extends StatelessWidget {
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
```

---

### Task 3: Modify MarkdownChunkList — dynamic stylesheet

**Files:**
- Modify: `lib/pages/detail/widgets/markdown_chunk_list.dart`

- [ ] **Step 1: Replace the static stylesheet with a dynamic builder**

Replace the entire file content:

```dart
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
            return MarkdownBody(
              data: chunks[index],
              selectable: true,
              styleSheet: style,
            );
          },
          separatorBuilder: (_, _) => SizedBox(height: s.paragraphSpacing),
        );
      },
    );
  }

  MarkdownStyleSheet _buildStyle(ReaderSettingsService s) {
    final scale = s.fontSize / ReaderSettingsService.defaultFontSize;

    return MarkdownStyleSheet(
      p: TextStyle(
        fontSize: s.fontSize,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: s.lineHeight,
        fontFamily: s.fontFamily,
      ),
      h1: TextStyle(
        fontSize: AppText.displayMdSize * scale,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        letterSpacing: -0.3,
        height: 1.15,
        fontFamily: s.fontFamily,
      ),
      h2: TextStyle(
        fontSize: AppText.taglineSize * scale,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.2,
        fontFamily: s.fontFamily,
      ),
      h3: TextStyle(
        fontSize: AppText.bodySize * scale,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.3,
        fontFamily: s.fontFamily,
      ),
      strong: const TextStyle(fontWeight: FontWeight.w600),
      blockquote: TextStyle(
        fontSize: s.fontSize,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        color: AppColors.ink,
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
        backgroundColor: AppColors.canvasParchment,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.canvasParchment,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
```

Key changes:
- `MarkdownChunkList` now takes `ReaderSettingsService` as a required parameter.
- Wraps the `SliverList` in `ListenableBuilder` so it rebuilds whenever settings change.
- `_buildStyle` method computes `scale` from fontSize/defaultFontSize and scales headings proportionally.
- `paragraphSpacing` replaces the hardcoded `AppSpacing.md` in the separator.
- `fontFamily` is applied to paragraph, headings, and blockquote text styles.

---

### Task 4: Modify DetailPage — background color

**Files:**
- Modify: `lib/pages/detail/detail_page.dart`

- [ ] **Step 1: Accept ReaderSettingsService and apply background color**

In `lib/pages/detail/detail_page.dart`, make these changes:

**a) Add import:**
```dart
import '../../services/reader_settings_service.dart';
```

**b) Add field to class:**
```dart
class DetailPage extends StatefulWidget {
  final ApiService apiService;
  final String blogId;
  final ReaderSettingsService settingsService;  // NEW

  const DetailPage({
    super.key,
    required this.apiService,
    required this.blogId,
    required this.settingsService,  // NEW
  });
```

**c) Change the build method background:**
Replace:
```dart
return CupertinoPageScaffold(
  backgroundColor: AppColors.canvasParchment,
```
With:
```dart
return CupertinoPageScaffold(
  backgroundColor: _bgColor(),
```

**d) Add the `_bgColor` helper and wrap the body in ListenableBuilder:**
```dart
Color _bgColor() {
  switch (widget.settingsService.backgroundColor) {
    case 'white':
      return AppColors.canvas;
    case 'dark':
      return AppColors.surfaceTile1;
    case 'parchment':
    default:
      return AppColors.canvasParchment;
  }
}
```

**e) In `_buildBody`, pass settingsService to MarkdownChunkList:**
Replace:
```dart
MarkdownChunkList(chunks: chunks)
```
With:
```dart
MarkdownChunkList(
  chunks: chunks,
  settingsService: widget.settingsService,
)
```

**f) Wrap the SafeArea in a ListenableBuilder for reactive background:**
Replace:
```dart
return SafeArea(
  child: CustomScrollView(
```
With:
```dart
return ListenableBuilder(
  listenable: widget.settingsService,
  builder: (context, _) {
    return SafeArea(
      child: CustomScrollView(
```
And add the corresponding closing `)` after the last `SliverToBoxAdapter`.

The full modified `_buildBody` method will look like:

```dart
Widget _buildBody() {
  if (_error != null) {
    return ErrorView(message: _error!, onRetry: _loadDetail);
  }

  if (_blog == null) {
    return const LoadingIndicator(message: '加载中...');
  }

  final blog = _blog!;
  final hasCover = blog.img != null && blog.img!.isNotEmpty;
  final chunks = _chunks ?? [];

  return ListenableBuilder(
    listenable: widget.settingsService,
    builder: (context, _) {
      return SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: DetailHeroImage(imageUrl: blog.img),
            ),
            SliverToBoxAdapter(
              child: ContentHeader(blog: blog, hasCover: hasCover),
            ),
            if (chunks.isNotEmpty)
              MarkdownChunkList(
                chunks: chunks,
                settingsService: widget.settingsService,
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      );
    },
  );
}
```

---

### Task 5: Add 3rd tab in App

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Wire ReaderSettingsService and SettingPage into the app**

**a) Add import:**
```dart
import 'services/reader_settings_service.dart';
import 'pages/setting/setting_page.dart';
```

**b) Create the service instance (singleton) before the CupertinoApp:**

Change the `App` class to:
```dart
class App extends StatelessWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService = ReaderSettingsService();

  App({super.key, required this.apiService});
```

Wait — `StatelessWidget` can't have non-final fields. Let me adjust. Actually, the service should be created in `main.dart` or passed in like `apiService`. But since `StatelessWidget` requires all fields to be final, and we want a single instance, let me create it inline or pass it from main.dart.

Simplest approach: create it in `main.dart` and pass it in:

**main.dart:**
```dart
import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/reader_settings_service.dart';

void main() {
  final apiService = ApiService();
  final settingsService = ReaderSettingsService();
  runApp(App(apiService: apiService, settingsService: settingsService));
}
```

**app.dart — add field, modify tab bar:**
```dart
class App extends StatelessWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;

  const App({
    super.key,
    required this.apiService,
    required this.settingsService,
  });
```

**c) Add 3rd tab item:**
```dart
BottomNavigationBarItem(
  icon: Icon(CupertinoIcons.settings),
  activeIcon: Icon(CupertinoIcons.settings_solid),
  label: '设置',
),
```

**d) Add case 2 in tabBuilder:**
```dart
case 2:
  return CupertinoTabView(
    builder: (_) => SettingPage(settingsService: settingsService),
  );
```

**e) Pass settingsService to pages that need it for navigation to detail:**

The `HomePage` and `ListPage` navigate to `DetailPage` — they'll need `settingsService` too. Let me update their constructors:

In `app.dart` tabBuilder:
```dart
case 0:
  return CupertinoTabView(
    builder: (_) => HomePage(
      apiService: apiService,
      settingsService: settingsService,
    ),
  );
case 1:
  return CupertinoTabView(
    builder: (_) => ListPage(
      apiService: apiService,
      settingsService: settingsService,
    ),
  );
```

---

### Task 6: Update HomePage and ListPage to pass settingsService to DetailPage

**Files:**
- Modify: `lib/pages/home/home_page.dart`
- Modify: `lib/pages/list/list_page.dart`

- [ ] **Step 1: Update HomePage**

Add import:
```dart
import '../../services/reader_settings_service.dart';
```

Add field:
```dart
class HomePage extends StatefulWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;

  const HomePage({
    super.key,
    required this.apiService,
    required this.settingsService,
  });
```

Where it navigates to `DetailPage`, add the parameter:
```dart
DetailPage(
  apiService: apiService,
  blogId: id,
  settingsService: settingsService,
)
```

- [ ] **Step 2: Update ListPage**

Same changes as HomePage — add `ReaderSettingsService` field, update constructor, pass to `DetailPage`.

---

### Task 7: Unit test — ReaderSettingsService

**Files:**
- Create: `test/reader_settings_service_test.dart`

- [ ] **Step 1: Write the tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:readmeet/services/reader_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default values are correct', () async {
    final service = ReaderSettingsService();
    expect(service.fontSize, ReaderSettingsService.defaultFontSize);
    expect(service.lineHeight, ReaderSettingsService.defaultLineHeight);
    expect(service.paragraphSpacing,
        ReaderSettingsService.defaultParagraphSpacing);
    expect(service.fontFamily, isNull);
    expect(service.backgroundColor,
        ReaderSettingsService.defaultBackgroundColor);
  });

  test('setFontSize notifies and persists', () async {
    final service = ReaderSettingsService();
    bool notified = false;
    service.addListener(() => notified = true);

    await service.setFontSize(20.0);
    expect(notified, isTrue);
    expect(service.fontSize, 20.0);

    // Reload from "disk"
    final service2 = ReaderSettingsService();
    await service2.load();
    expect(service2.fontSize, 20.0);
  });

  test('setFontFamily null works', () async {
    final service = ReaderSettingsService();
    await service.setFontFamily('serif');
    expect(service.fontFamily, 'serif');

    await service.setFontFamily(null);
    expect(service.fontFamily, isNull);
  });

  test('setBackgroundColor works', () async {
    final service = ReaderSettingsService();
    await service.setBackgroundColor('dark');
    expect(service.backgroundColor, 'dark');
  });
}
```

---

### Task 8: Widget test — SettingPage

**Files:**
- Create: `test/setting_page_test.dart`

- [ ] **Step 1: Write the widget test**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readmeet/pages/setting/setting_page.dart';
import 'package:readmeet/services/reader_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReaderSettingsService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = ReaderSettingsService();
  });

  testWidgets('renders all setting sections', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: SettingPage(settingsService: service),
      ),
    );

    expect(find.text('阅读设置'), findsOneWidget);
    expect(find.text('字体大小'), findsOneWidget);
    expect(find.text('行间距'), findsOneWidget);
    expect(find.text('段落间距'), findsOneWidget);
    expect(find.text('字体样式'), findsOneWidget);
    expect(find.text('阅读背景'), findsOneWidget);
  });

  testWidgets('slider changes font size', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: SettingPage(settingsService: service),
      ),
    );

    // Find the first CupertinoSlider and verify it exists
    expect(find.byType(CupertinoSlider), findsNWidgets(3));
  });

  testWidgets('segmented controls exist', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: SettingPage(settingsService: service),
      ),
    );

    expect(find.byType(CupertinoSlidingSegmentedControl<String?>),
        findsOneWidget);
    expect(find.byType(CupertinoSlidingSegmentedControl<String>),
        findsOneWidget);
  });
}
```

---

### Execution Order

Tasks 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

- Task 1 (Service) must come first — everything depends on it.
- Tasks 3, 4, 5, 6 can be done together after Task 2 — they all wire the service into existing code.
- Tasks 7, 8 (Tests) come last to verify everything works.
